import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube/data/models/user_model.dart';

import '../../../shared/theme.dart';
import '../../cubit/Auth/auth_cubit.dart';

class UserItemView extends StatelessWidget {
  final UserModel userModel;
  final GestureTapCallback onCallTap;

  const UserItemView(
      {Key? key, required this.userModel, required this.onCallTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ListTile(
      title: Row(
        children: [
          userModel.avatar.isNotEmpty ? CircleAvatar(
            backgroundColor: defaultColor,
            radius: 22.0,
            backgroundImage: CachedNetworkImageProvider(
              userModel.avatar,
            ),
          ) : const Icon(Icons.person),
          const SizedBox(width: 10.0,),
          Expanded(child: Text(userModel.name)),
          GestureDetector(
              onTap: onCallTap,
              child: const Icon(
                Icons.call,
                color: Colors.green,
              )),
        ],
      ),
    );
  }
}
