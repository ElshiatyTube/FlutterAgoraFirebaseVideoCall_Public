import 'dart:convert';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:youtube/data/models/call_model.dart';
import 'package:youtube/data/models/user_model.dart';
import 'package:youtube/presentaion/cubit/home/home_cubit.dart';
import 'package:youtube/shared/shared_widgets.dart';

import '../../shared/constats.dart';
import '../../shared/network/cache_helper.dart';
import '../../shared/theme.dart';
import '../cubit/Auth/auth_cubit.dart';
import '../cubit/home/home_state.dart';
import '../views/home_views/call_item_view.dart';
import '../views/home_views/home_screen_pageview.dart';
import '../views/home_views/user_item_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('UserIdIs: ${CacheHelper.getString(key: 'uId')}');
    Future.delayed(const Duration(milliseconds: 1000), () {
      checkInComingTerminatedCall();
    });
  }

  checkInComingTerminatedCall() async {
    if(CacheHelper.getString(key: 'terminateIncomingCallData').isNotEmpty){ //if there is a terminated call
      Map<String, dynamic> callMap = jsonDecode(CacheHelper.getString(key: 'terminateIncomingCallData'));
      await CacheHelper.removeData(key: 'terminateIncomingCallData');
      Navigator.pushNamed(context, callScreen,arguments: [
        true,
        CallModel.fromJson(callMap),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Hello, ${AuthCubit.get(context).currentUser.name}'),
        ),
        body: BlocConsumer<HomeCubit, HomeState>(
          listener: (context, state) {
            //GetUserData States
            if (state is ErrorGetUsersState) {
              showToast(msg: state.message);
            }
            if (state is ErrorGetCallHistoryState) {
            //  showToast(msg: state.message);
            }
            //FireCall States
            if (state is ErrorFireVideoCallState) {
             // showToast(msg: state.message);
            }
            if (state is ErrorPostCallToFirestoreState) {
              showToast(msg: state.message);
            }
            if(state is ErrorUpdateUserBusyStatus){
              showToast(msg: state.message);
            }
            if (state is SuccessFireVideoCallState) {
              Navigator.pushNamed(context, callScreen, arguments: [false,state.callModel]);
            }

            //Receiver Call States
            if(state is SuccessInComingCallState){
              Navigator.pushNamed(context, callScreen, arguments: [true,state.callModel]);
            }
          },
          builder: (context, state) {
            var homeCubit = HomeCubit.get(context);
            return ModalProgressHUD(
              inAsyncCall: homeCubit.fireCallLoading,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DefaultTabController(
                  length: HomeTypes.values.length,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TabBar(
                        isScrollable: true,
                        unselectedLabelColor: Colors.grey[400],
                        indicatorColor: defaultColor,
                        labelColor: defaultColor,
                        tabs: HomeTypes.values
                            .map((e) => Tab(
                                  child: Text(
                                    e.name,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ))
                            .toList(),
                      ),
                      (state is LoadingGetUsersState ||
                              state is LoadingGetCallHistoryState)
                          ? const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 2.0),
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.grey,
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Expanded(
                        child: TabBarView(
                          physics: const BouncingScrollPhysics(),
                          children: HomeTypes.values.map((e) {
                            return HomeScreenPageView(
                              users: homeCubit.users,
                              calls: homeCubit.calls,
                              isUsers: e == HomeTypes.Users ? true : false,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
