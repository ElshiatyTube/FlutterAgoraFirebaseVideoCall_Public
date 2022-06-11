import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
}
