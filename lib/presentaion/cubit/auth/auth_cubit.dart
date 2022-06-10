import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:youtube/data/models/user_model.dart';
import 'package:youtube/shared/shared_widgets.dart';

import '../../../shared/constats.dart';
import 'auth_state.dart';



class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  static AuthCubit get(context) => BlocProvider.of(context);

  final auth = FirebaseAuth.instance;

  late UserModel currentUser;
  void login({required String email}) {
    emit(LoadingLoginState());
    FirebaseFirestore.instance
        .collection(userCollection)
        .where('email', isEqualTo: email)
        .get()
        .then((value){
          if(value.size!=0){
            for (var element in value.docs) {
              currentUser = UserModel.fromJsonMap(map: element.data(),uId: element.id);
              debugPrint('UserId: ${currentUser.id}');
            }
            emit(SuccessLoginState(currentUser.id));
          }else{
            emit(ErrorLoginState('Check your email'));
          }
    }).catchError((onError){
      emit(ErrorLoginState(onError.toString()));
    });
  }

  void getUserData({required String uId}){
    if(uId.isNotEmpty){
      emit(LoadingGetUserDataState());
      FirebaseFirestore.instance
          .collection(userCollection)
          .doc(uId)
          .get()
          .then((value) {
        if(value.exists){
          currentUser = UserModel.fromJsonMap(map: value.data()!,uId: value.id);
        }else{
          emit(ErrorGetUserDataState('User not found'));
        }
        emit(SuccessGetUserDataState());
      }).catchError((onError){
        emit(ErrorGetUserDataState(onError.toString()));
      });
    }

  }


}
