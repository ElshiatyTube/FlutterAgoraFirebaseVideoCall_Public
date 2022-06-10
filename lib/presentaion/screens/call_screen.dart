import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:youtube/data/models/call_model.dart';
import 'package:youtube/presentaion/cubit/call/call_cubit.dart';
import 'package:youtube/presentaion/cubit/home/home_cubit.dart';

import '../../shared/constats.dart';
import '../../shared/shared_widgets.dart';
import '../cubit/call/call_state.dart';
import '../widgets/call_widgets/default_circle_image.dart';
import '../widgets/call_widgets/user_info_header.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:permission_handler/permission_handler.dart';

class CallScreen extends StatefulWidget {
  final bool isReceiver;
  final CallModel callModel;
  const CallScreen({Key? key, required this.isReceiver, required this.callModel}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late CallCubit _callCubit;

  @override
  void initState() {
    super.initState();
    _callCubit = CallCubit.get(context);
    rePermission();
    _callCubit.listenToCallStatus(callModel: widget.callModel, context: context,isReceiver: widget.isReceiver);
    if(!widget.isReceiver){ //Caller
      _callCubit.initAgoraAndJoinChannel(channelToken: widget.callModel.token!,channelName: widget.callModel.channelName!,isCaller:true);
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
      _callCubit.countDownTimer.cancel();
    }
    _callCubit.performEndCall(callModel: widget.callModel);
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
            _callCubit.updateCallStatusToUnAnswered(callId: widget.callModel.id);
          }
        }

        if(state is AgoraRemoteUserJoinedEvent){
          //remote user join channel
          if(!widget.isReceiver){ //Caller
            _callCubit.countDownTimer.cancel();
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
              body: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  cubit.remoteUid == null ? !widget.isReceiver ? Container(color: Colors.red,child: const RtcLocalView.SurfaceView()) : Container( //res
                    decoration:  BoxDecoration(
                      image: DecorationImage(
                        image:  widget.callModel.callerAvatar!.isNotEmpty ? NetworkImage(
                          widget.callModel.callerAvatar!,
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
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: 122,
                          height: 219.0,
                          child: Center(
                            child: RtcLocalView.SurfaceView(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50.0,),
                        !widget.isReceiver ?  UserInfoHeader( //Caller -> Show Receiver INFO
                          avatar: widget.callModel.receiverAvatar!,
                          name: widget.callModel.receiverName!,
                        ) : UserInfoHeader( //Receiver -> Show Caller INFO
                          avatar: widget.callModel.callerAvatar!,
                          name: widget.callModel.callerName!,
                        ),
                        const SizedBox(height: 30.0,),
                        cubit.remoteUid ==null ? Expanded(
                          child: widget.isReceiver ?  Text('${widget.callModel.callerName} is calling you..',style: const TextStyle(color: Colors.white,fontSize: 39.0),)
                              :const Text('Contacting..',style: TextStyle(color: Colors.white,fontSize: 39.0),),
                        ) : Expanded(child: Container()),

                        cubit.remoteUid ==null ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            widget.isReceiver ? Expanded(
                              child: InkWell(
                                onTap: (){
                                  //receiverAcceptVideoChat
                                  _callCubit.updateCallStatusToAccept(callModel: widget.callModel);
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
                                    _callCubit.updateCallStatusToReject(callId: widget.callModel.id);
                                  }else{
                                    //callerCancelVideoChat
                                    _callCubit.updateCallStatusToCancel(callId: widget.callModel.id);
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
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: (){
                                  cubit.switchCamera();
                                },
                                child: const DefaultCircleImage(bgColor: Colors.white ,image: Icon(Icons.switch_camera_outlined,color: Colors.black,),center: true,width: 42,height: 42,),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                  onTap: (){
                                    cubit.updateCallStatusToEnd(callId: widget.callModel.id);
                                  },
                                  child: const DefaultCircleImage(bgColor: Colors.red ,image: Icon(Icons.call_end_rounded,color: Colors.white,),center: true,width: 55,height: 55,)
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: (){
                                  cubit.toggleMuted();
                                },
                                child: DefaultCircleImage(bgColor: Colors.white ,image: cubit.muteIcon ,center: true,width: 42,height: 42,),
                              ),
                            ),


                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ) ,
            ),
          ),
        );
      },
    );
  }
  // Display remote user's video
  Widget _remoteVideo({required int remoteUserId}) {
    return RtcRemoteView.SurfaceView(uid: remoteUserId,channelId: /*widget.callModel.channelName!*/ agoraTestChannelName,);
  }
}
