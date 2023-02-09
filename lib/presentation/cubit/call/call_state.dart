
abstract class CallState {}

class CallInitial extends CallState {}

class DownCountCallTimerFinishState extends CallState {}


//Agora video room States
class AgoraRemoteUserJoinedEvent extends CallState {}
class AgoraUserLeftEvent extends CallState {}

class AgoraInitAndJoinedSuccessState extends CallState {}

class AgoraInitForSenderSuccessState extends CallState {}
class AgoraInitForReceiverSuccessState extends CallState {}

class AgoraSwitchCameraState extends CallState {}
class AgoraToggleMutedState extends CallState {}


//Update Call Status
class LoadingCancelVideoChatState extends CallState {}
class SuccessCancelVideoChatState extends CallState {}
class ErrorCancelVideoChatState extends CallState {
  final String error;
  ErrorCancelVideoChatState(this.error);
}

class LoadingRejectVideoChatState extends CallState {}
class SuccessRejectVideoChatState extends CallState {}
class ErrorRejectVideoChatState extends CallState {
  final String error;

  ErrorRejectVideoChatState(this.error);
}


class LoadingUnAnsweredVideoChatState extends CallState {}
class SuccessUnAnsweredVideoChatState extends CallState {}
class ErrorUnAnsweredVideoChatState extends CallState {
  final String error;

  ErrorUnAnsweredVideoChatState(this.error);
}




//call States
class CallAcceptState extends CallState {}
class CallRejectState extends CallState {}
class CallNoAnswerState extends CallState {}
class CallCancelState extends CallState {}
class CallEndState extends CallState {}
