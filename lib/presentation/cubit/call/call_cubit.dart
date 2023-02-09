import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:youtube/data/models/call_model.dart';
import 'package:youtube/presentation/cubit/auth/auth_cubit.dart';
import 'package:youtube/shared/constats.dart';
import 'package:youtube/shared/utilites.dart';

import '../../../data/api/call_api.dart';
import '../home/home_cubit.dart';
import 'call_state.dart';
import 'package:quiver/async.dart';

class CallCubit extends Cubit<CallState> {
  CallCubit({required this.context, required this.callModel}) : super(CallInitial());
  final BuildContext context;
  final CallModel callModel;

  static CallCubit get(context) => BlocProvider.of(context);

  //Agora video room

  int? remoteUid;
  RtcEngine? engine;

  Future<void> initAgoraAndJoinChannel(
      {required String channelToken,
      required String channelName,
      required bool isCaller}) async {
    //create the engine
    engine = await RtcEngine.create(agoraAppId);
    await engine!.enableVideo();
    engine!.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          printDebug("local user $uid joined");
        },
        userJoined: (int uid, int elapsed) {
          printDebug("remote user $uid joined");
          remoteUid = uid;
          listenForRemoteUserConnection();
          emit(AgoraRemoteUserJoinedEvent());
        },
        userOffline: (int uid, UserOfflineReason reason) {
          printDebug("remote user $uid left channel");
          remoteUid = null;
          emit(AgoraUserLeftEvent());
        },
      ),
    );

    //join channel
    await engine!.joinChannel(agoraTestToken, agoraTestChannelName, null, 0);
    if (isCaller) {
      emit(AgoraInitForSenderSuccessState());
      playContactingRing(isCaller: true);
    } else {
      emit(AgoraInitForReceiverSuccessState());
    }

    printDebug('channelTokenIs $channelToken channelNameIs $channelName');
  }

   StreamSubscription? remoteUserConnectionSubscription;
   listenForRemoteUserConnection() {
    String? remoteUserId =
        callModel.callerId == AuthCubit.get(context).currentUser.id
            ? callModel.receiverId
            : callModel.callerId;
    if (remoteUserId == null) return;
    remoteUserConnectionSubscription = _callApi.listenForRemoteUserConnection(callId: callModel.id, otherUserId: remoteUserId);
    remoteUserConnectionSubscription?.onData((event) {
      if (event.data()!['online'] == false) {
        updateCallStatusToEnd(callId: callModel.id);
      }
    });
  }

  //Sender
  AudioPlayer assetsAudioPlayer = AudioPlayer();

  Future<void> playContactingRing({required bool isCaller}) async {
    String audioAsset = "assets/sounds/ringlong.mp3";
    ByteData bytes = await rootBundle.load(audioAsset);
    Uint8List soundBytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    int result = await assetsAudioPlayer.playBytes(soundBytes);
    if (result == 1) {
      //play success
      printDebug("Sound playing successful.");
    } else {
      printDebug("Error while playing sound.");
    }
    if (isCaller) {
      startCountdownCallTimer();
    }
  }

  int current = 0;
  CountdownTimer? countDownTimer;

  void startCountdownCallTimer() {
    countDownTimer = CountdownTimer(
      const Duration(seconds: callDurationInSec),
      const Duration(seconds: 1),
    );
    var sub = countDownTimer!.listen(null);
    sub.onData((duration) {
      current = callDurationInSec - duration.elapsed.inSeconds;
      printDebug("DownCount: $current");
    });

    sub.onDone(() {
      printDebug("CallTimeDone");
      sub.cancel();
      emit(DownCountCallTimerFinishState());
    });
  }

  bool muted = false;
  Widget muteIcon = const Icon(
    Icons.keyboard_voice_rounded,
    color: Colors.black,
  );

  Future<void> toggleMuted() async {
    muted = !muted;
    muteIcon = muted
        ? const Icon(
            Icons.mic_off_rounded,
            color: Colors.black,
          )
        : const Icon(
            Icons.keyboard_voice_rounded,
            color: Colors.black,
          );
    await engine!.muteLocalAudioStream(muted);
    emit(AgoraToggleMutedState());
  }

  Future<void> switchCamera() async {
    await engine!.switchCamera();
    emit(AgoraSwitchCameraState());
  }

  //Update Call Status
  final _callApi = CallApi();

  void updateCallStatusToUnAnswered({required String callId}) {
    emit(LoadingUnAnsweredVideoChatState());
    _callApi
        .updateCallStatus(callId: callId, status: CallStatus.unAnswer.name)
        .then((value) {
      emit(SuccessUnAnsweredVideoChatState());
    }).catchError((onError) {
      emit(ErrorUnAnsweredVideoChatState(onError.toString()));
    });
  }

  Future<void> updateCallStatusToCancel({required String callId}) async {
    await _callApi.updateCallStatus(
        callId: callId, status: CallStatus.cancel.name);
  }

  Future<void> updateCallStatusToReject({required String callId}) async {
    await _callApi.updateCallStatus(
        callId: callId, status: CallStatus.reject.name);
  }

  Future<void> updateCallStatusToAccept({required CallModel callModel}) async {
    await _callApi.updateCallStatus(
        callId: callModel.id, status: CallStatus.accept.name);
    initAgoraAndJoinChannel(
        channelToken: agoraTestChannelName,
        channelName: agoraTestToken,
        isCaller: false);
  }

  Future<void> updateCallStatusToEnd({required String callId}) async {
    await _callApi.updateCallStatus(
        callId: callId, status: CallStatus.end.name);
  }

  Future<void> clearComments({required String callId}) async {
    await _callApi.clearComments(callId: callId);
  }

  Future<void> endCurrentCall({required String callId}) async {
    await _callApi.endCurrentCall(callId: callId);
  }

  Future<void> updateUserBusyStatusFirestore(
      {required CallModel callModel}) async {
    await _callApi.updateUserBusyStatusFirestore(
        callModel: callModel, busy: false);
  }

  Future<void> performEndCall({required CallModel callModel}) async {
    await Future.wait([
      endCurrentCall(callId: callModel.id),
      updateUserBusyStatusFirestore(callModel: callModel),
      clearComments(callId: callModel.id)
    ]);
  }

  StreamSubscription? callStatusStreamSubscription;

  void listenToCallStatus(
      {required CallModel callModel,
      required bool isReceiver}) {
    var _homeCubit = HomeCubit.get(context);
    callStatusStreamSubscription =
        _callApi.listenToCallStatus(callId: callModel.id);
    callStatusStreamSubscription!.onData((data) {
      if (data.exists) {
        String status = data.data()!['status'];
        if (status == CallStatus.accept.name) {
          _homeCubit.currentCallStatus = CallStatus.accept;
          printDebug('acceptStatus');
          emit(CallAcceptState());
        }
        if (status == CallStatus.reject.name) {
          _homeCubit.currentCallStatus = CallStatus.reject;
          printDebug('rejectStatus');
          callStatusStreamSubscription!.cancel();
          emit(CallRejectState());
        }
        if (status == CallStatus.unAnswer.name) {
          _homeCubit.currentCallStatus = CallStatus.unAnswer;
          printDebug('unAnswerStatusHere');
          callStatusStreamSubscription!.cancel();
          emit(CallNoAnswerState());
        }
        if (status == CallStatus.cancel.name) {
          _homeCubit.currentCallStatus = CallStatus.cancel;
          printDebug('cancelStatus');
          callStatusStreamSubscription!.cancel();
          emit(CallCancelState());
        }
        if (status == CallStatus.end.name) {
          _homeCubit.currentCallStatus = CallStatus.end;
          printDebug('endStatus');
          callStatusStreamSubscription!.cancel();
          emit(CallEndState());
        }
      }
    });
  }
}
