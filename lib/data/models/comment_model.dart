import 'package:youtube/data/models/user_model.dart';

class CommentModel{
  final String id;
  final String content;
  final num createdAt;
  final UserModel user;

  CommentModel({required this.id, required this.content, required this.createdAt, required this.user});

  factory CommentModel.fromJson(Map<String, dynamic> json, String id) {
    return CommentModel(
      id: id,
      content: json['content'],
      createdAt: json['created_at'],
      user: UserModel.fromUserCommentJsonMap(map: json['user']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt,
      'user': user.toUserCommentMap(),
    };
  }
}