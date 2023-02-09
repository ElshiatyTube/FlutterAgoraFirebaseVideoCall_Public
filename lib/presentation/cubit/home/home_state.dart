
import 'package:equatable/equatable.dart';
import 'package:youtube/data/models/call_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {
}

class ChangeCurrentPageState extends HomeState {
}

class LoadingGetUsersState extends HomeState {
}
class SuccessGetUsersState extends HomeState {
}
class ErrorGetUsersState extends HomeState {
  final String message;

  ErrorGetUsersState(this.message);
}


class LoadingGetCallHistoryState extends HomeState {
}
class SuccessGetCallHistoryState extends HomeState {
}
class ErrorGetCallHistoryState extends HomeState {
  final String message;

   ErrorGetCallHistoryState(this.message);
}

//Sender
class LoadingFireVideoCallState extends HomeState {}
class SuccessFireVideoCallState extends HomeState {
  final CallModel callModel;

  SuccessFireVideoCallState({required this.callModel});
}
class ErrorFireVideoCallState extends HomeState {
  final String message;
  ErrorFireVideoCallState(this.message);
}

class ErrorPostCallToFirestoreState extends HomeState {
  final String message;
  ErrorPostCallToFirestoreState(this.message);
}

class ErrorUpdateUserBusyStatus extends HomeState {
  final String message;
  ErrorUpdateUserBusyStatus(this.message);
}

class ErrorSendNotification extends HomeState {
  final String message;
  ErrorSendNotification(this.message);
}


//Incoming Call
class SuccessInComingCallState extends HomeState {
  final CallModel callModel;

  SuccessInComingCallState({required this.callModel});
}

