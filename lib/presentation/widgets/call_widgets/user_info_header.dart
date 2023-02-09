import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../shared/theme.dart';

class UserInfoHeader extends StatelessWidget {
  final String avatar;
  final String name;


  UserInfoHeader(
      {Key? key,
      required this.avatar,
      required this.name,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24.0,
          backgroundColor: Colors.grey.withOpacity(0.2),
          child: avatar.isNotEmpty
              ? CircleAvatar(
                  backgroundColor: defaultColor,
                  radius: 25.0,
                  backgroundImage: CachedNetworkImageProvider(
                    avatar,
                  ),
                )
              : const Icon(Icons.person),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
