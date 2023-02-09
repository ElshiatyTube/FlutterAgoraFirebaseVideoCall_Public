import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/presentation/cubit/auth/auth_cubit.dart';

import '../../../shared/theme.dart';
import '../../cubit/call/chat/live_chat_cubit.dart';
import '../../views/call_views/comment_item_view.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({Key? key}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    LiveChatCubit.get(context).getCommentsRealTime();
  }
  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LiveChatCubit,LiveChatState>(
      listener: (context,state){
        if(state is SuccessGetCommentsState)
        {
          Timer(const Duration(milliseconds: 100), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
        }
      },
      builder: (BuildContext context, state) {
        var liveDataCubit = LiveChatCubit.get(context);
        return SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    reverse: true,
                    itemBuilder: (context,index)
                    {
                      return CommentItemView(liveCommentDataModel: liveDataCubit.liveComments[index],);
                    },
                    separatorBuilder: (context,index)=> const SizedBox(height: 10.0,),
                    itemCount: liveDataCubit.liveComments.length,
                  ),
                ),
              ),
              SizedBox(
                height: 50.0,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextField(
                              controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Write something...',
                              border: InputBorder.none,
                            ),
                            onSubmitted: (value){
                              submitComment();
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0,),
                    InkWell(
                      onTap: (){
                        submitComment();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.white,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.send,color: defaultColor,),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  void submitComment() {
    if(_commentController.text.isEmpty) return;
    LiveChatCubit.get(context).sendComment(content: _commentController.text,user: AuthCubit.get(context).currentUser);
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }
}
