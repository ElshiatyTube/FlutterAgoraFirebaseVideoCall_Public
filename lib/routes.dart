import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/data/models/call_model.dart';

import 'package:youtube/presentation/cubit/call/call_cubit.dart';
import 'package:youtube/presentation/cubit/call/chat/live_chat_cubit.dart';
import 'package:youtube/presentation/screens/auth_screen.dart';
import 'package:youtube/presentation/screens/call_screen.dart';
import 'package:youtube/presentation/screens/home_screen.dart';
import 'package:youtube/presentation/screens/splash_screen.dart';

import 'package:youtube/shared/constats.dart';
import 'package:youtube/shared/network/cache_helper.dart';

enum EnterStates { auth, home }
class AppRouter {
  Route? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splashScreen:
        return MaterialPageRoute(
          builder: (_) {
            return SplashScreen(enterStates: CacheHelper.getString(key: 'uId').isNotEmpty ? EnterStates.home : EnterStates.auth,);
          },
        );
      case authScreen:
        return MaterialPageRoute(
          builder: (_) {
            return const AuthScreen();
          },
        );
      case homeScreen:
        return MaterialPageRoute(
          builder: (_) {
            return const HomeScreen();
          },
        );

      case callScreen:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        final isReceiver = args[0] as bool;
        final callModel = args[1] as CallModel;
        final context = args[2] as BuildContext;
        return MaterialPageRoute(
          builder: (_) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                    create: (_) => CallCubit(context: context,callModel: callModel)),
                BlocProvider(
                    create: (_) => LiveChatCubit(callId: callModel.id)),
              ],
              child: CallScreen(isReceiver: isReceiver),
            );
          },
        );
    }
    return null;
  }
}
