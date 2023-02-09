import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube/shared/network/cache_helper.dart';
import 'package:youtube/shared/utilites.dart';

import '../../services/fcm/firebase_notification_handler.dart';
import '../../shared/constats.dart';
import '../models/user_model.dart';

class AuthApi {
  Future<UserCredential> login(
      {required String email, required String password}) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await updateFcmToken(tokenModel: UserFcmTokenModel(token: '', uId: CacheHelper.getString(key: 'uId')));
    await FirebaseNotificationsHandler.deleteToken();
    await FirebaseNotificationsHandler.dispose();
    await AuthApi().updateUserPresenceInRealtimeDB(forceDisconnect: true);
    await CacheHelper.clear();
    await FirebaseAuth.instance.signOut();
  }

  Future<void> updateFcmToken({required UserFcmTokenModel tokenModel}) async {
   return await FirebaseFirestore.instance
        .collection(tokensCollection)
        .doc(CacheHelper.getString(key: 'uId'))
        .set(tokenModel.toMap());
  }

  Future<UserCredential> register(
      {required String email, required String password, required String name}) {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUser(
      {required UserModel user}) {
   return FirebaseFirestore.instance
        .collection(userCollection)
        .doc(user.id)
        .set(user.toMap());
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> checkUserExistInFirebase(
      {required String uId}) {
    return FirebaseFirestore.instance.collection(userCollection).doc(uId).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(
      {required String uId}) {
    return FirebaseFirestore.instance.collection(userCollection).doc(uId).get();
  }


  updateUserPresenceInRealtimeDB({bool forceDisconnect=false}) async {
    final String uId = CacheHelper.getString(key: 'uId');
    if(uId.isEmpty) return;
    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref('/status/');
    Map<String, dynamic> presenceStatusTrue = {
      'online': true,
      'lastOnline': DateTime.now().millisecondsSinceEpoch,
    };
    Map<String, dynamic> presenceStatusFalse = {
      'online': false,
      'lastOnline': DateTime.now().millisecondsSinceEpoch,
    };
    await databaseReference
        .child(uId)
        .update(forceDisconnect? presenceStatusFalse: presenceStatusTrue)
        .whenComplete(() => printDebug('Updated my presence.'))
        .catchError((e) => printDebug(e));

    databaseReference.child(uId).onDisconnect().update(presenceStatusFalse);
  }
}
