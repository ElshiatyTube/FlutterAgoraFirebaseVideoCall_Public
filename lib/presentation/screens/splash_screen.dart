import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:youtube/shared/network/cache_helper.dart';

import '../../../main.dart';
import '../../routes.dart';
import '../../shared/constats.dart';
import '../../shared/utilites.dart';
import '../../shared/theme.dart';
import '../cubit/auth/auth_cubit.dart';
import '../cubit/auth/auth_state.dart';


class SplashScreen extends StatefulWidget {
  final EnterStates enterStates;

  const SplashScreen({Key? key, required this.enterStates}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.enterStates == EnterStates.home) {
      AuthCubit.get(context).getUserData(uId: CacheHelper.getString(key: 'uId'));
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.of(context)
            .pushNamedAndRemoveUntil(authScreen, (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.enterStates == EnterStates.home
        ? BlocListener<AuthCubit, AuthState>(
      listener: (BuildContext context, state) {
        if (state is ErrorGetUserDataState) {
          showToast(msg: state.errorMessage.toString());
        }
        if (state is SuccessGetUserDataState) {
          Navigator.pushNamedAndRemoveUntil(
              context, homeScreen, (route) => false);
        }
      },
      child: body(),
    )
        : body();
  }

  Widget body() {
    return SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color: Colors.white,
              child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/splash_logo.png',
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.height * 0.30,
                      height: MediaQuery.of(context).size.height * 0.30,
                    ),
                  )),
            ),
            if (widget.enterStates == EnterStates.home)
              Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 20),
                child: const CircularProgressIndicator(
                  color: defaultColor,
                ),
              ),

          ],
        ));
  }
}
