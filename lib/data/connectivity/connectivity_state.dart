part of 'connectivity_cubit.dart';

abstract class ConnectivityState extends Equatable {
  const ConnectivityState();
}

class ConnectivityInitial extends ConnectivityState {
  @override
  List<Object> get props => [];
}

class ConnectivityConnected extends ConnectivityState {
  @override
  List<Object> get props => [];
}
class ConnectivityDisconnected extends ConnectivityState {
  @override
  List<Object> get props => [];
}

class ConnectivityDispose extends ConnectivityState {
  @override
  List<Object> get props => [];
}
