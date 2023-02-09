import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:youtube/data/models/call_model.dart';
import 'package:youtube/presentation/cubit/call/chat/live_chat_cubit.dart';
import 'package:youtube/presentation/cubit/home/home_cubit.dart';


import '../../shared/constats.dart';
import '../../shared/theme.dart';
import '../../shared/utilites.dart';
import '../cubit/call/call_cubit.dart';
import '../cubit/call/call_state.dart';
import '../views/call_views/comment_item_view.dart';
import '../widgets/call_widgets/chat_widget.dart';
import '../widgets/call_widgets/default_circle_image.dart';
import '../widgets/call_widgets/user_info_header.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:permission_handler/permission_handler.dart';

class CallScreen extends StatefulWidget {
  final bool isReceiver;
  const CallScreen({Key? key, required this.isReceiver}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late CallCubit _callCubit;
  late HomeCubit _homeCubit;
  @override
  void initState() {
    super.initState();
    _callCubit = CallCubit.get(context);
    _homeCubit = HomeCubit.get(context);
    rePermission();
    _callCubit.listenToCallStatus(callModel: _callCubit.callModel,isReceiver: widget.isReceiver);
    if(!widget.isReceiver){ //Caller
      _callCubit.initAgoraAndJoinChannel(channelToken: _callCubit.callModel.token!,channelName: _callCubit.callModel.channelName!,isCaller:true);
    }else{ //Receiver
      _callCubit.playContactingRing(isCaller: false);
    }
  }

  @override
  void dispose() {
    if(_callCubit.engine!=null){
      _callCubit.engine!.destroy();
    }
    _callCubit.assetsAudioPlayer.dispose();
    if(!widget.isReceiver){ //Sender
      _callCubit.countDownTimer?.cancel();
    }
    _callCubit.performEndCall(callModel: _callCubit.callModel);
    _callCubit.callStatusStreamSubscription?.cancel();
    _homeCubit.controlUserStreamSubscription(isPause: false);
    super.dispose();
  }

  Future<void> rePermission() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallCubit,CallState>(
      listener: (BuildContext context, Object? state) {
        if(state is ErrorUnAnsweredVideoChatState){
          showToast(msg: 'UnExpected Error!: ${state.error}');
        }
        if(state is DownCountCallTimerFinishState){
          if(_callCubit.remoteUid==null){
            _callCubit.updateCallStatusToUnAnswered(callId: _callCubit.callModel.id);
          }
        }

        if(state is AgoraRemoteUserJoinedEvent){
          //remote user join channel
          if(!widget.isReceiver){ //Caller
            _callCubit.countDownTimer?.cancel();
          }
          _callCubit.assetsAudioPlayer.stop(); //Sender, Receiver
        }

        //Call States
        if(state is CallNoAnswerState){
          if(!widget.isReceiver){ //Caller
            showToast(msg: 'No response!');
          }
          Navigator.pop(context);
        }
        if(state is CallCancelState){
          if(widget.isReceiver){ //Receiver
            showToast(msg: 'Caller cancel the call!');
          }
          Navigator.pop(context);
        }
        if(state is CallRejectState){
          if(!widget.isReceiver){ //Caller
            showToast(msg: 'Receiver reject the call!');
          }
          Navigator.pop(context);
        }
        if(state is CallEndState){
          showToast(msg: 'Call ended!');
          Navigator.pop(context);
        }
      },
      builder: (BuildContext context, state) {
        var cubit = CallCubit.get(context);
        return ModalProgressHUD(
          inAsyncCall: false,
          child: WillPopScope(
            onWillPop: () async {  return false; },
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    cubit.remoteUid == null ? !widget.isReceiver ? Container(color: Colors.black,child:  const RtcLocalView.SurfaceView()) : Container( //res
                      decoration:  BoxDecoration(
                        image: DecorationImage(
                          image:  _callCubit.callModel.callerAvatar!.isNotEmpty ? NetworkImage(
                            _callCubit.callModel.callerAvatar!,
                          ) :  const NetworkImage(
                            'https://picsum.photos/200/300',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ) : Stack(
                      children: [
                        Center(
                          child: _remoteVideo(remoteUserId: cubit.remoteUid!),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                             const SizedBox(
                                width: 122,
                                height: 219.0,
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0)),
                                      child: RtcLocalView.SurfaceView()),
                                ),
                              ),
                              const SizedBox(height: 10.0,),
                              if(cubit.remoteUid!=null)...[
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: (){
                                            cubit.switchCamera();
                                          },
                                          child: const DefaultCircleImage(bgColor: Colors.white ,image: Icon(Icons.switch_camera_outlined,color: Colors.black,),center: true,width: 42,height: 42,),
                                        ),
                                        const SizedBox(height: 10.0,),
                                        GestureDetector(
                                            onTap: (){
                                              cubit.updateCallStatusToEnd(callId: _callCubit.callModel.id);
                                            },
                                            child: const DefaultCircleImage(bgColor: Colors.red ,image: Icon(Icons.call_end_rounded,color: Colors.white,),center: true,width: 45,height: 45,)
                                        ),
                                        const SizedBox(height: 10.0,),
                                        GestureDetector(
                                          onTap: (){
                                            cubit.toggleMuted();
                                          },
                                          child: DefaultCircleImage(bgColor: Colors.white ,image: cubit.muteIcon ,center: true,width: 42,height: 42,),
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 50.0,),
                          !widget.isReceiver ?  UserInfoHeader( //Caller -> Show Receiver INFO
                            avatar: _callCubit.callModel.receiverAvatar!,
                            name: _callCubit.callModel.receiverName!,
                          ) : UserInfoHeader( //Receiver -> Show Caller INFO
                            avatar: _callCubit.callModel.callerAvatar!,
                            name: _callCubit.callModel.callerName!,
                          ),

                          const SizedBox(height: 30.0,),
                          cubit.remoteUid ==null ? Expanded(
                            child: widget.isReceiver ?  Text('${_callCubit.callModel.callerName} is calling you..',style: const TextStyle(color: Colors.white,fontSize: 39.0),)
                                :const Text('Contacting..',style: TextStyle(color: Colors.white,fontSize: 39.0),),
                          ) : Expanded(child: Container()),


                          if(cubit.remoteUid!=null)...[
                            const ChatWidget(),
                          ],


                         if(cubit.remoteUid==null)...[
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               widget.isReceiver ? Expanded(
                                 child: InkWell(
                                   onTap: (){
                                     //receiverAcceptVideoChat
                                     _callCubit.updateCallStatusToAccept(callModel: _callCubit.callModel);
                                   },
                                   child: Container(
                                     decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(15.0),
                                       color: Colors.green,
                                     ),
                                     child: const Center(
                                       child:  Padding(
                                         padding: EdgeInsets.symmetric(horizontal: 30.0,vertical: 8.0),
                                         child: Text('Acceptance',style: TextStyle(color: Colors.white,fontSize: 13.0),),
                                       ),
                                     ),
                                   ),
                                 ),
                               ) : Container(),
                               widget.isReceiver ? const SizedBox(width: 15.0,) : Container(),
                               Expanded(
                                 child: InkWell(
                                   onTap: (){
                                     if(widget.isReceiver){
                                       //receiverRejectVideoChat
                                       _callCubit.updateCallStatusToReject(callId: _callCubit.callModel.id);
                                     }else{
                                       //callerCancelVideoChat
                                       _callCubit.updateCallStatusToCancel(callId: _callCubit.callModel.id);
                                     }
                                   },
                                   child: Container(
                                     decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(15.0),
                                       color: Colors.red,
                                     ),
                                     child:  Center(
                                       child:  Padding(
                                         padding: const EdgeInsets.symmetric(horizontal: 30.0,vertical: 8.0),
                                         child:  Text(widget.isReceiver ? 'Reject' : 'Cancel',style: const TextStyle(color: Colors.white,fontSize: 13.0),),
                                       ),
                                     ),
                                   ),
                                 ),
                               )
                             ],
                           )
                         ]

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  // Display remote user's video
  Widget _remoteVideo({required int remoteUserId}) {
    return RtcRemoteView.SurfaceView(uid: remoteUserId,channelId: /*_callCubit.callModel.channelName!*/ agoraTestChannelName,);
  }
}
