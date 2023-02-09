import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:youtube/data/models/user_model.dart';

import '../../../shared/theme.dart';

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
          userModel.avatar.isNotEmpty
              ? CircleAvatar(
                  radius: 25.0,
                  backgroundColor: defaultColor,
                  child: Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      Container(
                        child: CircleAvatar(
                          radius: 24.0,
                          backgroundImage: CachedNetworkImageProvider(
                            userModel.avatar,
                          ),
                        ),
                        margin: const EdgeInsets.all(4.0),
                      ),
                      Container(
                        width: 15.0,
                        height: 15.0,
                        decoration: BoxDecoration(
                          color: userModel.online ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const Icon(Icons.person),
          const SizedBox(
            width: 10.0,
          ),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userModel.name),
              if(!userModel.online)...[
                Text(
                    DateFormat('dd/MM/yyyy HH:mm:ss').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            userModel.lastOnline.toInt())),
                    style: Theme.of(context).textTheme.caption),
              ]
            ],
          )),
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
