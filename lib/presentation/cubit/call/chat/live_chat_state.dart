part of 'live_chat_cubit.dart';

@immutable
abstract class LiveChatState {}

class LiveChatInitial extends LiveChatState {}


class LoadingSendCommentState extends LiveChatState {}
class ErrorSendCommentState extends LiveChatState {
  final String error;
  ErrorSendCommentState(this.error);
}

class LoadingGetCommentsState extends LiveChatState {}
class SuccessGetCommentsState extends LiveChatState {}
class ErrorGetCommentsState extends LiveChatState {
  final String error;
  ErrorGetCommentsState(this.error);
}