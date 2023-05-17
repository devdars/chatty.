import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chatty/common/apis/apis.dart';
import 'package:chatty/common/entities/chat.dart';
import 'package:chatty/common/routes/names.dart';
import 'package:chatty/common/store/store.dart';
import 'package:chatty/common/values/server.dart';
import 'package:chatty/pages/message/controller.dart';
import 'package:chatty/pages/message/voicecall/state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceCallController extends GetxController{
  VoiceCallController();

  final state=VoiceCallState();
  final player = AudioPlayer();
  String appId = APPID;
  final db = FirebaseFirestore.instance;

  final profile_token = UserStore.to.profile.token;
  late final RtcEngine engine;

  @override
ChannelProfileType channelProfileType = ChannelProfileType.channelProfileCommunication;
  void onInit(){
    super.onInit();

    var data = Get.parameters;
    state.to_name.value = data["to_name"]??"";
    state.to_avatar.value = data["to_avatar"]??"";
    state.call_role.value = data["call_role"]??"";
    state.doc_id.value = data["doc_id"]??"";
    state.to_token.value = data["to_token"]??"";
    initEngine();


  }

Future<void> initEngine()async{

    await player.setAsset("assets/Sound_Horizon.mp3");
    engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(
      appId: appId,
    ));
    //registering handlers..
    engine.registerEventHandler(RtcEngineEventHandler(
      onError: (ErrorCodeType err, String msg){
        print('[....onError] err: $err,  ,msg:$msg');
      },
      onJoinChannelSuccess: (RtcConnection connection, int elapsed){
        print('....onConnection ${connection.toJson()}');
        state.isJoined.value=true;
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) async {
        await player.pause();
    },
      onLeaveChannel: (RtcConnection connection, RtcStats stats ){
        print('.....user left the call....');
        state.isJoined.value=false;
      },
      onRtcStats: (RtcConnection connection, RtcStats stats){
        print("....time...");
        print(stats.duration);
        var time = stats.duration;
      }
    ));
    await engine.enableAudio();
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.setAudioProfile(profile: AudioProfileType.audioProfileDefault,
    scenario: AudioScenarioType.audioScenarioGameStreaming
    );
    await joinChannel();
    if(state.call_role == "anchor"){
      //play dial tone---send notification to the other user
      await sendNotification("voice");
      await player.play();
    }
}Future<void> sendNotification(String call_type)async{
    CallRequestEntity callRequestEntity = CallRequestEntity();
    callRequestEntity.call_type = call_type;
    callRequestEntity.to_token = state.to_token.value;
    callRequestEntity.to_avatar = state.to_avatar.value;
    callRequestEntity.doc_id = state.doc_id.value;
    callRequestEntity.to_name = state.to_name.value;
    print("...the other user's token is ${state.to_token.value}");
    var res = await ChatAPI.call_notifications(params: callRequestEntity);
    if(res.code == 0){
      print("....notification success...");
    }
    else{
      print("....notification failed...");
    }
  }


Future<String> getToken() async {
    if(state.call_role == "anchor"){
      state.channelId.value=md5.convert(utf8.encode("${profile_token}_${state.to_token}")).toString();
    }
    //audience condition
    else{
      state.channelId.value=md5.convert(utf8.encode("${state.to_token}_${profile_token}")).toString();
    }

    CallTokenRequestEntity callTokenRequestEntity = CallTokenRequestEntity();
    callTokenRequestEntity.channel_name = state.channelId.value;
    print("....channel id is ${state.channelId.value}");
    print("....my access token is ${UserStore.to.token}");
    var res = await ChatAPI.call_token(params: callTokenRequestEntity);
    if(res.code == 0){
      return res.data!;
    }

    return "";
}

Future<void> joinChannel() async {
    await Permission.microphone.request();
    EasyLoading.show(
      indicator: const CircularProgressIndicator(),
      maskType: EasyLoadingMaskType.clear,
      dismissOnTap: true
    );
    String token = await getToken();
    if(token.isEmpty){
      EasyLoading.dismiss();
      Get.back();
      return;

    }

    //joining channel
    await engine.joinChannel(
       token: token,
        channelId: state.channelId.value,
        uid: 0,
        options:  ChannelMediaOptions(
      channelProfile: channelProfileType,
      clientRoleType: ClientRoleType.clientRoleBroadcaster
    ));
    EasyLoading.dismiss();
}
//call this from view/ui
Future<void> leaveChannel() async {
    EasyLoading.show(
      indicator: const CircularProgressIndicator(),
      maskType: EasyLoadingMaskType.clear,
      dismissOnTap: true
    );
    await player.pause();
    state.isJoined.value = false;
    EasyLoading.dismiss();
    Get.put(MessageController());
    Get.back();

}
//disconnecting..
Future<void> _dispose() async {
    await player.pause();
    await engine.leaveChannel();
    await engine.release();
    await player.stop();
}
@override
void onClose(){
    _dispose();
    super.onClose();
}
@override
  void dispose(){
    _dispose();
    super.dispose();
}
}