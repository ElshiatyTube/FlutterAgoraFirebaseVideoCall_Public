import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:youtube/data/api/call_api.dart';
import 'package:youtube/data/api/home_api.dart';
import 'package:youtube/data/models/user_model.dart';
import 'package:youtube/presentaion/cubit/auth/auth_cubit.dart';
import 'package:youtube/shared/constats.dart';

import '../../../data/models/call_model.dart';
import '../../../data/models/fcm_payload_model.dart';
import '../../../services/fcm/firebase_notification_handler.dart';
import '../../../shared/dio_helper.dart';
import '../../../shared/network/cache_helper.dart';
import '../../screens/home_screen.dart';
import 'home_state.dart';

enum HomeTypes { Users, History}


class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  static HomeCubit get(context) => BlocProvider.of(context);

  final firebaseNotifications = FirebaseNotifications();

  void initFcm(context){
    firebaseNotifications.setUpFcm(context: context, onForegroundClickCallNotify: (String payload){
      debugPrint('Foreground Click Call Notify: $payload');
    });
  }


  void updateFcmToken({required String uId}) {
    FirebaseMessaging.instance.getToken().then((token) {
      UserFcmTokenModel tokenModel = UserFcmTokenModel(token: token!,uId: uId);
      FirebaseFirestore.instance
          .collection(tokensCollection)
          .doc(CacheHelper.getString(key: 'uId'))
          .set(tokenModel.toMap())
          .then((value) {
        debugPrint('User Fcm Token Updated $token');
      }).catchError((onError) {
        debugPrint(onError.toString());
      });
    });
  }

  List<UserModel> users = [];


  final _homeApi = HomeApi();
  void getUsersRealTime(){
      emit(LoadingGetUsersState());
      _homeApi.getUsersRealTime().onData((data) {
        if(data.size!=0){
          users = []; // for realtime update the list
          for (var element in data.docs) {
            if(!users.any((e) => e.id == element.id)){
              users.add(UserModel.fromJsonMap(map: element.data(),uId: element.id));
            }
          }
          emit(SuccessGetUsersState());
        }else{
          emit(ErrorGetUsersState('No users found'));
        }
      });
  }

  List<CallModel> calls = [];

  void getCallHistoryRealTime(){
      emit(LoadingGetCallHistoryState());
      _homeApi.getCallHistoryRealTime().onData((data) {
        if(data.size != 0){
          calls = []; // for realtime update the list
          for (var element in data.docs) {
            if(element.data()['callerId'] == CacheHelper.getString(key: 'uId')
                || element.data()['receiverId'] == CacheHelper.getString(key: 'uId')){ //As firebase not allow multi where query, so we get all calls and filter it
              if(!calls.any((e) => e.id == element.id)){
                var call = CallModel.fromJson(element.data());
                if(call.callerId == CacheHelper.getString(key: 'uId')){
                  call.otherUser = UserModel(name: call.receiverName!, avatar: call.receiverAvatar!);
                }else{
                  call.otherUser = UserModel(name: call.callerName!, avatar: call.callerAvatar!);
                }
                calls.add(call);
              }
            }
          }
          emit(SuccessGetCallHistoryState());
        }else{
          emit(ErrorGetCallHistoryState('No Call History'));
        }
      });
    }

  //#region Get Data by Normal Request
   void getUser(){
    FirebaseFirestore.instance
          .collection(userCollection)
      .get()
      .then((value) {
        if(value.size!=0){
          for (var element in value.docs) {
            if(!users.any((e) => e.id == element.id)){
              users.add(UserModel.fromJsonMap(map: element.data(),uId: element.id));
            }else{
              users[users.indexWhere((e) => e.id == element.id)] = UserModel.fromJsonMap(map: element.data(),uId: element.id);
            }
          }
          emit(SuccessGetUsersState());
        }else{
          emit(ErrorGetUsersState('No users found'));
        }
      });
    }
   void getCallHistory(){
    FirebaseFirestore.instance
          .collection(callsCollection)
          .get()
          .then((value) {
        debugPrint('sizeVal: ${value.size}');
        if(value.size != 0){
          for (var element in value.docs) {
            if(element.data()['callerId'] == CacheHelper.getString(key: 'uId') || element.data()['receiverId'] == CacheHelper.getString(key: 'uId')){
              calls.add(CallModel.fromJson(element.data()));
            }

          }
          emit(SuccessGetCallHistoryState());
        }else{
          emit(ErrorGetCallHistoryState('No Call History'));
        }
      }).catchError((onError){
        emit(ErrorGetCallHistoryState(onError.toString()));
      });
    }
 //#endregion


  //Call Logic ________________________________
  final _callApi = CallApi();
  bool fireCallLoading = false;
  Future<void> fireVideoCall({required CallModel callModel}) async {
    fireCallLoading = true;
    emit(LoadingFireVideoCallState());
      //1-generate call token
     Map<String,dynamic> queryMap = {
       'channelName' : 'channel_${UniqueKey().hashCode.toString()}',
       'uid' : callModel.callerId,
     };
     _callApi.generateCallToken(queryMap: queryMap).then((value){
       callModel.token = value['token'];
       callModel.channelName = value['channel_name'];
       //2-post call in Firebase
       postCallToFirestore(callModel: callModel);
     }).catchError((onError){
       fireCallLoading = false;
       //For test
       callModel.token = agoraTestToken;
       callModel.channelName = agoraTestChannelName;
        postCallToFirestore(callModel: callModel);
       emit(ErrorFireVideoCallState(onError.toString()));
     });

  }

  void postCallToFirestore({required CallModel callModel}) {
    _callApi.postCallToFirestore(callModel: callModel).then((value){
      //3-update user busy status in Firebase
      _callApi.updateUserBusyStatusFirestore(callModel: callModel, busy: true).then((value) {
        fireCallLoading = false;
        //4-send notification to receiver
        sendNotificationForIncomingCall(callModel: callModel);
      }).catchError((onError){
        fireCallLoading = false;
        emit(ErrorUpdateUserBusyStatus(onError.toString()));
      });
    }).catchError((onError){
      fireCallLoading = false;
      emit(ErrorPostCallToFirestoreState(onError.toString()));
    });
  }

  void sendNotificationForIncomingCall({required CallModel callModel}) {
    FirebaseFirestore.instance
    .collection(tokensCollection)
    .doc(callModel.receiverId)
    .get()
    .then((value) {
      if(value.exists){
        Map<String, dynamic> bodyMap = {
          'type': 'call',
          'title': 'New call',
          'body': jsonEncode(callModel.toMap())
        };
        FcmPayloadModel fcmSendData = FcmPayloadModel(to: value.data()!['token'],data: bodyMap);

        DioHelper.postData(
          data:  fcmSendData.toMap(), baseUrl: 'https://fcm.googleapis.com/', endPoint: 'fcm/send',
        ).then((value) {
          debugPrint('SendNotifySuccess ${value.data.toString()}');
          emit(SuccessFireVideoCallState(callModel: callModel));
        }).catchError((onError){
          debugPrint('Error when send Notify: $onError');
          fireCallLoading = false;
          emit(ErrorSendNotification(onError.toString()));
        });
      }
    }).catchError((onError){
      debugPrint('Error when get user token: $onError');
      fireCallLoading = false;
      emit(ErrorSendNotification(onError.toString()));
    });
  }
 // CallModel inComingCall;

  CallStatus? currentCallStatus;
  void listenToInComingCalls() {
    _callApi.listenToInComingCall().onData((data) {
      if(data.size!=0){
        for (var element in data.docs) {
          if(element.data()['current'] == true){
            String status = element.data()['status'];
            if(status == CallStatus.ringing.name){
              currentCallStatus = CallStatus.ringing;
              debugPrint('ringingStatus');
              emit(SuccessInComingCallState(callModel: CallModel.fromJson(element.data())));
            }
          }
        }
      }
    });
  }
}
