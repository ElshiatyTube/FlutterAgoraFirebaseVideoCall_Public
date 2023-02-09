import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/constats.dart';
import '../../shared/network/cache_helper.dart';

class HomeApi{

 //Not Used
 Future<QuerySnapshot<Map<String,dynamic>>> getUsers() async{
   return FirebaseFirestore.instance.collection(userCollection).where('uId',isNotEqualTo: CacheHelper.getString(key: 'uId')).get();
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getUsersRealTime() {
   return FirebaseFirestore.instance.collection(userCollection).where('uId',isNotEqualTo: CacheHelper.getString(key: 'uId')).snapshots().listen((event) {});
 }

 StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getCallHistoryRealTime() {
  return FirebaseFirestore.instance.collection(callsCollection).orderBy('createAt',descending: true).snapshots().listen((event) {});
 }
 
 
}