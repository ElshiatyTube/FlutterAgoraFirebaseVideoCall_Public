import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:youtube/shared/network/cache_helper.dart';

import '../../../../data/api/call_api.dart';
import '../../../../data/models/comment_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../shared/utilites.dart';

part 'live_chat_state.dart';

class LiveChatCubit extends Cubit<LiveChatState> {
  LiveChatCubit({required this.callId}) : super(LiveChatInitial());
  final String callId;

  static LiveChatCubit get(context) => BlocProvider.of(context);

  final _callApi = CallApi();

  List<CommentModel> liveComments=[];

  Future<void> sendComment({required String content, required UserModel user}) async {
    try{
      emit(LoadingSendCommentState());
      CommentModel comment = CommentModel(
        id: UniqueKey().hashCode.toString(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        content: content,
        user: UserModel.comment(
          id: user.id,
          name: user.name,
          avatar: user.avatar,
        ),
      );
      await _callApi.sendComment(comment: comment,callId: callId);
    }catch(e){
      printDebug('ErrorSendCommentState: ${e.toString()}');
      emit(ErrorSendCommentState(e.toString()));
    }
  }

  void getCommentsRealTime(){
    emit(LoadingGetCommentsState());
    _callApi.getChatMessages(callId: callId).listen((data) {
      liveComments.clear();
      for (var element in data.docs) {
          liveComments.add(CommentModel.fromJson(element.data(), element.id));
      }
      emit(SuccessGetCommentsState());
    }).onError((error) {
      printDebug('ErrorGetCommentsState: ${error.toString()}');
      emit(ErrorGetCommentsState(error.toString()));
    });
  }


}
