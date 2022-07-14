import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/screens/chatRoom/messageInput.dart';
import 'package:flutter_firebase_chat/screens/chatRoom/messageList.dart';
import 'package:flutter_firebase_chat/screens/models/chatRooms.dart';
import 'package:flutter_firebase_chat/screens/models/chats.dart';
import 'package:flutter_firebase_chat/widgets/loader.dart';

class ChatRoomScreen extends StatelessWidget {
  static const String routeName = '/chat-room';

  const ChatRoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>;
    print(routeArgs);
    return Scaffold(
      appBar: AppBar(title: Text(routeArgs[ChatRooms.roomName])),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection(ChatRooms.collectionName)
                .doc(routeArgs[ChatRooms.roomId])
                .collection(Chats.collectionName)
                .snapshots(),
            builder: (_, chats) {
              if (chats.connectionState == ConnectionState.waiting) {
                return const Loader(
                  isFullScreen: true,
                );
              }
              return MessageList(
                  messageList: chats.data!.docs.reversed.toList(),
                  roomUsers: routeArgs[ChatRooms.roomUsers]);
            },
          ),
        ),
        MessageInput(
          roomId: routeArgs[ChatRooms.roomId],
        )
      ]),
    );
  }
}
