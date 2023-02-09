import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



class NotificationHandler{
  static final flutterLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();
  static late BuildContext myContext;

  static void initNotification({required BuildContext context,required SelectNotificationCallback selectNotificationCallback}){ //customize
    myContext = context;
    var initAndroid = const AndroidInitializationSettings("@drawable/ic_notify");
    const IOSInitializationSettings initializationSettingsIOS =
     IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    var initSetting = InitializationSettings(android: initAndroid,iOS: initializationSettingsIOS);
    flutterLocalNotificationPlugin.initialize(initSetting,onSelectNotification: selectNotificationCallback);

  }


  static Future onDidReceiveLocalNotification(int? id,String? title,String? body,String? payload) async{
    showDialog(context: myContext, builder: (context)=> CupertinoAlertDialog(title: Text(title!),
    content: Text(body!),
    actions: [
      CupertinoDialogAction(
        isDefaultAction: true,
        child: const Text('OK'),
        onPressed: ()=> Navigator.of(context,rootNavigator: true,).pop(),
      )
    ],));
  }
}
