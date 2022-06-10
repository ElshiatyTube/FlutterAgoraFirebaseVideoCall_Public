import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube/data/models/call_model.dart';

import '../../shared/constats.dart';
import '../../shared/network/cache_helper.dart';
import 'notification_handler.dart';
import 'package:http/http.dart' as http;


class FirebaseNotifications{
  late FirebaseMessaging _messaging;
  late BuildContext myContext;

  void setUpFcm({required BuildContext context,required Function onForegroundClickCallNotify})
  {
    _messaging = FirebaseMessaging.instance;
    NotificationHandler.initNotification(context: context, selectNotificationCallback: (String? payload) {
      if(payload!=null){
        onForegroundClickCallNotify(payload);
      }
    });
    firebaseCloudMessageListener(context);
    myContext = context;

  }

  void firebaseCloudMessageListener(BuildContext context) async{

    final bool? result = await NotificationHandler.flutterLocalNotificationPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
    debugPrint('Setting ${settings.authorizationStatus} LocalPer ${result.toString()}');
    //Get Token
    //Handle message
    FirebaseMessaging.onMessage.listen((remoteMessage) { //Foreground Msg
      if(remoteMessage.data['type'] != 'call'){
        showNotification(title: remoteMessage.data['title'],body: remoteMessage.data['body'],type: remoteMessage.data['type']);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((remoteMessage) {
      debugPrint('Receive open app: $remoteMessage ');
      debugPrint('InOpenAppNotifyBody ${remoteMessage.data['body'].toString()}');
      if(Platform.isIOS) {
        showDialog(context: myContext, builder: (context)=> CupertinoAlertDialog(title: Text(remoteMessage.notification!.title??''),
          content:  Text(remoteMessage.notification!.body??''),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: ()=> Navigator.of(context,rootNavigator: true,).pop(),
            )
          ],));
      }
    });
  }


  static AndroidNotificationDetails callChannel = const AndroidNotificationDetails(
      'com.agora.videocall.youtube', 'call_channel',
      autoCancel: false,
      ongoing: true,
      importance: Importance.max,
      priority: Priority.max);
  static AndroidNotificationDetails normalChannel = const AndroidNotificationDetails(
      'com.agora.videocall.youtube', 'normal_channel',
      autoCancel: true,
      ongoing: false,
      importance: Importance.low,
      priority: Priority.low);

 static void showNotification({required String title,required String body,required String type}) async{
   debugPrint('callDataFromNotify $body');
   if(type == 'call'){
     Map<String, dynamic> bodyJson = jsonDecode(body);

     int notificationId =Random().nextInt(1000);
     var ios = const IOSNotificationDetails();
     var platform = NotificationDetails(
         android: callChannel,iOS: ios);
     await NotificationHandler.flutterLocalNotificationPlugin
         .show(notificationId, '📞Ringing...', '${CallModel.fromJson(bodyJson).callerName} is calling you', platform,payload: body);
     await Future.delayed(const Duration(seconds: callDurationInSec), () {
       NotificationHandler.flutterLocalNotificationPlugin.cancel(notificationId).then((value) {
         showMissedCallNotification(senderName: bodyJson['sender']['full_name']);
       });
     });
   }
   else{
     int notificationId =Random().nextInt(1000);
     var ios = const IOSNotificationDetails();
     var platform = NotificationDetails(
         android: normalChannel,iOS: ios);
     await NotificationHandler.flutterLocalNotificationPlugin
         .show(notificationId, title, body, platform,payload: body);
   }
  }

  static void showMissedCallNotification({required String senderName}) async{
    int notificationId =Random().nextInt(1000);
    var ios = const IOSNotificationDetails();
    var platform = NotificationDetails(
        android: normalChannel,iOS: ios);
    await NotificationHandler.flutterLocalNotificationPlugin
        .show(notificationId, '📞Missed Call', 'You have missed call from $senderName', platform,payload: 'missedCall');

  }


}