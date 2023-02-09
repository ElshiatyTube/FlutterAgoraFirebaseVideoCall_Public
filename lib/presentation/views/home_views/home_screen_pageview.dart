import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube/presentation/views/home_views/user_item_view.dart';

import '../../../data/models/call_model.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/constats.dart';
import '../../../shared/network/cache_helper.dart';
import '../../../shared/utilites.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/home/home_cubit.dart';
import 'call_item_view.dart';

class HomeScreenPageView extends StatelessWidget {
  final List<UserModel> users;
  final List<CallModel> calls;
  final bool isUsers;
  const HomeScreenPageView({Key? key, required this.users, required this.calls, required this.isUsers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) {
          if (isUsers) {
            return UserItemView(
              userModel: users[index],
              onCallTap: () {
                if(!users[index].busy!){
                  HomeCubit.get(context).fireVideoCall(
                      callModel: CallModel(
                          id: 'call_${UniqueKey().hashCode.toString()}',
                          callerId: CacheHelper.getString(key: 'uId'),
                          callerAvatar: AuthCubit.get(context).currentUser.avatar,
                          callerName: AuthCubit.get(context).currentUser.name,
                          receiverId: users[index].id,
                          receiverAvatar:users[index].avatar,
                          receiverName:users[index].name,
                          status: CallStatus.ringing.name,
                          createAt: DateTime.now().millisecondsSinceEpoch,
                        current: true
                      ));
                }else{
                 showToast(msg: 'User is busy');
                }

              },
            );
          } else {
            return CallItemView(callModel: calls[index]);
          }
        },
        separatorBuilder: (context, index) => const Divider(),
        itemCount: isUsers ? users.length : calls.length);
  }
}
