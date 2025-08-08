import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:robotic_staff_app/screens/chat/chat_page.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoChat extends StatefulWidget {
  final String staffName, staffId, userId, userName, callID;
  const VideoChat({
    super.key,
    required this.staffName,
    required this.staffId,
    required this.userId,
    required this.userName,
    required this.callID,
  });

  @override
  State<VideoChat> createState() => _VideoChatState();
}

class _VideoChatState extends State<VideoChat> {
  final int appID = 639665702; // Your Zego AppID
  final String appSign =
      "7f6c104b5fa917a561058a4da436faf1880fb042d84d1cd22156e80dc651ed98"; // Your Zego AppSign

  late final ZegoUIKitPrebuiltCallController callController;
  late final String chatRoomId;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference chatCollection = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages');

    return Scaffold(
      appBar: AppBar(iconTheme: IconThemeData(color: Colors.white)),
      body: Stack(
        children: [
          SafeArea(
            child: ZegoUIKitPrebuiltCall(
              appID: appID,
              appSign: appSign,
              userID: widget.userId,
              userName: widget.userName,
              callID: widget.callID,
              config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
            ),
          ),

          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      chatCollection: chatCollection,
                      currentUserId: widget.userId,
                      currentUserName: widget.userName,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
