import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../shared/constats.dart';
import '../../shared/dio_helper.dart';
import '../../shared/network/cache_helper.dart';
import '../models/call_model.dart';

class CallApi {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      listenToInComingCall() {
    return FirebaseFirestore.instance
        .collection(callsCollection)
        .where('receiverId', isEqualTo: CacheHelper.getString(key: 'uId'))
        .snapshots()
        .listen((event) {});
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
  listenToCallStatus({required String callId}) {
    return FirebaseFirestore.instance
        .collection(callsCollection)
        .doc(callId)
        .snapshots()
        .listen((event) {});
  }

  Future<void> postCallToFirestore({required CallModel callModel}) {
    return FirebaseFirestore.instance
        .collection(callsCollection)
        .doc(callModel.id)
        .set(callModel.toMap());
  }

  Future<void> updateUserBusyStatusFirestore({required CallModel callModel,required bool busy}) {
    Map<String, dynamic> busyMap = {'busy': busy};
    return FirebaseFirestore.instance
        .collection(userCollection)
        .doc(callModel.callerId)
        .update(busyMap)
        .then((value) {
      FirebaseFirestore.instance
          .collection(userCollection)
          .doc(callModel.receiverId)
          .update(busyMap);
    });
  }

  //Sender
  Future<dynamic> generateCallToken(
      {required Map<String, dynamic> queryMap}) async {
    try {
      var response = await DioHelper.getData(
          endPoint: fireCallEndpoint,
          query: queryMap,
          baseUrl: cloudFunctionBaseUrl);
      debugPrint('fireVideoCallResp: ${response.data}');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Error: ${response.data} Status Code: ${response.statusCode}');
      }
    } on DioError catch (error) {
      debugPrint("fireVideoCallError: ${error.toString()}");
    }
  }


  Future<void> updateCallStatus({required String callId,required String status}){
    return FirebaseFirestore.instance
        .collection(callsCollection)
        .doc(callId)
        .update({'status': status});
  }
  Future<void> endCurrentCall({required String callId}){
    return FirebaseFirestore.instance
        .collection(callsCollection)
        .doc(callId)
        .update({'current': false});
  }
}
