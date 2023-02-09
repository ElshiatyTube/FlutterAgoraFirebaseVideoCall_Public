import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';


class ConnectivityHandler{
  ConnectivityHandler._();
  static final ConnectivityHandler _instance = ConnectivityHandler._();
  static ConnectivityHandler get instance => _instance;

  StreamSubscription? _connectivitySubscription;

  StreamSubscription start(){
    return _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {});
  }

  void dispose(){
    _connectivitySubscription?.cancel();
  }
}