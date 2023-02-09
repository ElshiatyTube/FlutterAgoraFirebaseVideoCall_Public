import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/data/connectivity/connectivity_cubit.dart';
import 'package:youtube/presentation/cubit/auth/auth_cubit.dart';
import 'package:youtube/presentation/cubit/home/home_cubit.dart';
import 'package:youtube/routes.dart';
import 'package:youtube/services/fcm/firebase_notification_handler.dart';
import 'package:youtube/shared/dio_helper.dart';
import 'package:youtube/shared/network/cache_helper.dart';
import 'package:youtube/shared/theme.dart';
import 'package:youtube/shared/utilites.dart';
import 'package:one_context/one_context.dart';

import 'data/api/auth_api.dart';
import 'shared/bloc_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CacheHelper.init();

  await Firebase.initializeApp();

  DioHelper.init();

  //Handle FCM background
  FirebaseMessaging.onBackgroundMessage(
      FirebaseNotificationsHandler.backgroundHandler);

  Bloc.observer = AppBlocObserver();

  runZonedGuarded(() {
    runApp(OneNotification(
      builder: (_, __) => MyApp(
        appRouter: AppRouter(),
      ),
    ));
  }, (error, stackTrace) {
    printDebug('Error: ${error.toString()}');
  });
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({Key? key, required this.appRouter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ConnectivityCubit(),
        ),
        BlocProvider(
          create: (_) => AuthCubit(),
        ),
        BlocProvider(
          create: (_) => HomeCubit()
            ..listenToInComingCalls()
            ..getUsersRealTime()
            ..getCallHistoryRealTime()
            ..initFcm(context)
            ..updateFcmToken(uId: CacheHelper.getString(key: 'uId')),
        ),
      ],
      child: BlocListener<ConnectivityCubit, ConnectivityState>(
        listener: (context, state) {
          if (state is ConnectivityDisconnected) {
            printDebug('Disconnected');
            showToast(msg: 'Check your internet connection');
          }
          if (state is ConnectivityConnected) {
            printDebug('Connected');
            AuthApi().updateUserPresenceInRealtimeDB();
          }
        },
        child: MaterialApp(
          title: 'Firebase agora videochat',
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          onGenerateRoute: appRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
