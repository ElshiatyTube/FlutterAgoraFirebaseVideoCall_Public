import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:youtube/data/models/user_model.dart';
import 'package:youtube/shared/shared_widgets.dart';

import '../../../data/api/auth_api.dart';
import '../../../shared/constats.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  static AuthCubit get(context) => BlocProvider.of(context);

  late UserModel currentUser;

  final _authApi = AuthApi();

  void login({required String email, required String password}) async {
    emit(LoadingLoginState());
    _authApi.login(email: email, password: password).then((value){
      debugPrint(value.user!.email);
      checkUserExistInFirebase(uId: value.user!.uid);
    }).catchError((onError){
      emit(ErrorLoginState(onError.toString()));
    });
  }

  void register(
      {required String email,
      required String password,
      required String name}) async {
    emit(LoadingRegisterState());
    _authApi.register(email: email, password: password, name: name).then((value){
      createUser(
        name: name,
        email: email,
        uId: value.user!.uid,
      );
    }).catchError((onError){
      emit(ErrorRegisterState(onError.toString()));
    });
  }

  void checkUserExistInFirebase({required String uId}) {
    _authApi.checkUserExistInFirebase(uId: uId).then((user) {
      if (user.exists) {
        currentUser = UserModel.fromJsonMap(map: user.data()!, uId: uId);
        emit(SuccessLoginState(uId));
      } else {
        emit(ErrorLoginState('Account not exist'));
      }
    }).catchError((onError){
      emit(ErrorLoginState(onError.toString()));
    });
  }

  void getUserData({required String uId}) {
    if (uId.isNotEmpty) {
      emit(LoadingGetUserDataState());
      _authApi.getUserData(uId: uId).then((value){
        if (value.exists) {
          currentUser =
              UserModel.fromJsonMap(map: value.data()!, uId: value.id);
        } else {
          emit(ErrorGetUserDataState('User not found'));
        }
        emit(SuccessGetUserDataState());
      }).catchError((onError){
        emit(ErrorGetUserDataState(onError.toString()));
      });
    }
  }

  void createUser(
      {required String name, required String email, required String uId}) {
    UserModel user = UserModel.resister(
        name: name, id: uId, email: email, avatar: 'https://i.pravatar.cc/300',busy: false);
    _authApi.createUser(user: user).then((value) {
      currentUser = user;
      emit(SuccessRegisterState(uId));
    }).catchError((onError){
      emit(ErrorRegisterState(onError.toString()));
    });
  }
}
