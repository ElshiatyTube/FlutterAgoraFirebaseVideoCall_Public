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

class LoginScreen extends StatefulWidget {
   LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: BlocConsumer<AuthCubit,AuthState>(
         listener: (BuildContext context, state) {
           if(state is ErrorLoginState){
             showToast(msg: state.errorMessage,);
           }
           if(state is SuccessLoginState){
             CacheHelper.saveData(key: 'uId', value: state.uId).then((value){
               Navigator.pushNamedAndRemoveUntil(context, homeScreen, (route) => false);
             });
           }
           if(state is ErrorGetUserDataState){
             showToast(msg: state.errorMessage,);
           }
           if(state is SuccessGetUserDataState){
             Navigator.pushNamedAndRemoveUntil(context, homeScreen, (route) => false);
           }
         },
         builder: (BuildContext context, Object? state) {
           AuthCubit authCubit = AuthCubit.get(context);
           return  Padding(
             padding: const EdgeInsets.all(8.0),
             child:state is! LoadingGetUserDataState ? Column(
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
                 const SizedBox(height: 10.0,),
                state is! LoadingLoginState ? ElevatedButton.icon(
                     onPressed: (){
                       if( emailController.text.isNotEmpty){
                         authCubit.login(email: emailController.text);
                       }else{
                        showToast(msg: 'Please enter fill req data');
                       }
                     }, icon: const Icon(Icons.login), label: const Text('Login'))
                    : const CircularProgressIndicator(),

               ],
             ) : const Center(child: CircularProgressIndicator()),
           );
         },
       ),
    );
  }


}
