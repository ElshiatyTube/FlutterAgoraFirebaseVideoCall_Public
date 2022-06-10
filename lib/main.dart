import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/presentaion/cubit/Auth/auth_cubit.dart';
import 'package:youtube/presentaion/cubit/home/home_cubit.dart';
import 'package:youtube/routes.dart';
import 'package:youtube/services/fcm/firebase_notification_handler.dart';
import 'package:youtube/shared/dio_helper.dart';
import 'package:youtube/shared/network/cache_helper.dart';
import 'package:youtube/shared/theme.dart';

import 'shared/bloc_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CacheHelper.init();

  await Firebase.initializeApp();

  DioHelper.init();

  //Handle FCM background
  FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

  BlocOverrides.runZoned(() => runApp(MyApp(appRouter: AppRouter(),)),blocObserver: AppBlocObserver());

}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

   MyApp({Key? key, required this.appRouter}) : super(key: key);

   @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit()..getUserData(uId: CacheHelper.getString(key: 'uId')),
        ),
        BlocProvider(
          create: (_) => HomeCubit()..listenToInComingCalls()..getUsersRealTime()..getCallHistoryRealTime()..initFcm(context)..updateFcmToken(uId:  CacheHelper.getString(key: 'uId')),
        ),
      ],
      child: MaterialApp(
        title: 'Firebase agora videochat',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        onGenerateRoute: appRouter.onGenerateRoute,
      ),
    );
  }
}

Future<void> _backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await CacheHelper.init();
  if (message.data['type'] == 'call'){
    Map<String, dynamic> bodyMap = jsonDecode(message.data['body']);
    await CacheHelper.saveData(key: 'terminateIncomingCallData',value: jsonEncode(bodyMap));
  }
  FirebaseNotifications.showNotification(title: message.data['title'],body: message.data['body'],type: message.data['type']);

}
