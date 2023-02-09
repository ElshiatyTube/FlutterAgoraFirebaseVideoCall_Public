import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/comment_model.dart';

class CommentItemView extends StatelessWidget {
  final CommentModel liveCommentDataModel;
  const CommentItemView({Key? key, required this.liveCommentDataModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 15.0,
          backgroundImage: NetworkImage(liveCommentDataModel.user.avatar),
        ),
        const SizedBox(width: 10.0,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(liveCommentDataModel.user.name,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              const SizedBox(height: 5.0,),
              Text(DateFormat('dd/MM/yyyy HH:mm:ss').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      liveCommentDataModel.createdAt.toInt())),style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.white)),
              const SizedBox(height: 5.0,),
              Text(liveCommentDataModel.content,style: const TextStyle(color: Colors.white),),
            ],
          ),
        ),
      ],
    );
  }
}
