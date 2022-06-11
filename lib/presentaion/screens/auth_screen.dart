import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:youtube/shared/constats.dart';

import '../../shared/network/cache_helper.dart';
import '../../shared/shared_widgets.dart';
import '../../shared/theme.dart';
import '../cubit/Auth/auth_cubit.dart';
import '../cubit/Auth/auth_state.dart';

enum AuthOptions {
  login('Login', LoginView()),
  register('Register', RegisterView());

  final String name;
  final Widget view;

  const AuthOptions(this.name, this.view);
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (BuildContext context, state) {
          if (state is SuccessLoginState) {
            CacheHelper.saveData(key: 'uId', value: state.uId).then((value) {
              Navigator.pushNamedAndRemoveUntil(
                  context, homeScreen, (route) => false);
            });
          }
          if (state is SuccessRegisterState) {
            CacheHelper.saveData(key: 'uId', value: state.uId).then((value) {
              Navigator.pushNamedAndRemoveUntil(
                  context, homeScreen, (route) => false);
            });
          }
          if (state is ErrorRegisterState) {
            showToast(
              msg: state.errorMessage,
            );
          }
          if (state is ErrorLoginState) {
            showToast(
              msg: state.errorMessage,
            );
          }
          if (state is ErrorGetUserDataState) {
            showToast(
              msg: state.errorMessage,
            );
          }
          if (state is SuccessGetUserDataState) {
            Navigator.pushNamedAndRemoveUntil(
                context, homeScreen, (route) => false);
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DefaultTabController(
              length: AuthOptions.values.length,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TabBar(
                    isScrollable: true,
                    unselectedLabelColor: Colors.grey[400],
                    indicatorColor: defaultColor,
                    labelColor: defaultColor,
                    tabs: AuthOptions.values
                        .map((e) => Tab(
                              child: Text(
                                e.name,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ))
                        .toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: AuthOptions.values.map((e) => e.view).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (BuildContext context, state) {
        var authCubit = AuthCubit.get(context);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              state is! LoadingLoginState
                  ? ElevatedButton.icon(
                      onPressed: () {
                        if (emailController.text.isNotEmpty &&
                            passwordController.text.isNotEmpty) {
                          authCubit.login(
                              email: emailController.text,
                              password: passwordController.text);
                        } else {
                          showToast(msg: 'Please fill req data');
                        }
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Login'))
                  : const CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (BuildContext context, state) {
        var authCubit = AuthCubit.get(context);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                  hintText: 'Enter your name',
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter your password',
                  )),
              const SizedBox(
                height: 10.0,
              ),
              state is! LoadingRegisterState
                  ? ElevatedButton.icon(
                      onPressed: () {
                        if (emailController.text.isNotEmpty &&
                            passwordController.text.isNotEmpty &&
                            nameController.text.isNotEmpty) {
                          authCubit.register(
                              email: emailController.text,
                              password: passwordController.text,
                              name: nameController.text);
                        } else {
                          showToast(msg: 'Please fill req data');
                        }
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Register'))
                  : const CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }
}
