import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/connectivity/connectivity.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit() : super(ConnectivityInitial()){
    listen();
  }

  static ConnectivityCubit get(context) => BlocProvider.of(context);

  listen(){
    ConnectivityHandler.instance.start().onData((data) {
      if(data == ConnectivityResult.none){
        emit(ConnectivityDisconnected());
      }else{
        emit(ConnectivityConnected());
      }
    });
  }

  dispose(){
    ConnectivityHandler.instance.dispose();
    emit(ConnectivityDispose());
  }
}
