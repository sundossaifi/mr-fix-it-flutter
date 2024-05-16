import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatelessWidget {
  const CallPage({Key? key, required this.callID, required this.userID, required this.userName, required this.isVideoCall})
      : super(key: key);
  final String callID;
  final String userID;
  final String userName;
  final bool isVideoCall;

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: 1252426318,
      appSign: '7a3b2dec992bc61e9a629fbf7973db6290a1cf2bd40f61d0ebb9d73850e2d562',
      userID: userID,
      userName: userName,
      callID: callID,
      config: isVideoCall
          ? (ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()..onOnlySelfInRoom = (context) => Navigator.of(context).pop())
          : (ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()..onOnlySelfInRoom = (context) => Navigator.of(context).pop()),
    );
  }
}
