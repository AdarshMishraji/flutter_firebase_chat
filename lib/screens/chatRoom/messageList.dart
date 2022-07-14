import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/screens/models/chats.dart';
import 'package:flutter_firebase_chat/screens/models/users.dart';

class MessageList extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> messageList;
  final Map<dynamic, dynamic> roomUsers;
  MessageList({Key? key, required this.messageList, required this.roomUsers})
      : super(key: key);
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messageList.length,
      itemBuilder: (_, index) {
        final message = messageList[index];
        final messageBody = message.data();
        print(messageBody[Chats.senderUserId]);
        return MessageItem(message: {
          ...messageBody,
          Chats.messageId: message.id,
          Chats.$senderUser: roomUsers[messageBody[Chats.senderUserId]],
          Chats.$isMineMessage:
              messageBody[Chats.senderUserId] == currentUserId,
        });
      },
    );
  }
}

class MessageItem extends StatelessWidget {
  final Map<dynamic, dynamic> message;
  const MessageItem({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final userImage = Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: CircleAvatar(
        backgroundImage:
            NetworkImage(message[Chats.$senderUser][Users.imageUrl]),
      ),
    );
    return Row(
      key: ValueKey(message[Chats.messageId]),
      mainAxisAlignment: message[Chats.$isMineMessage]
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!message[Chats.$isMineMessage]) userImage,
        Container(
          decoration: BoxDecoration(
            color: message[Chats.$isMineMessage]
                ? Theme.of(context).primaryColor
                : Colors.deepPurple,
            borderRadius: BorderRadius.circular(15),
          ),
          constraints: BoxConstraints(maxWidth: screenSize.width * 0.75),
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: message[Chats.$isMineMessage]
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                message[Chats.$senderUser]['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              Text(
                message[Chats.message],
                textAlign: message[Chats.$isMineMessage]
                    ? TextAlign.left
                    : TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  // fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        if (message[Chats.$isMineMessage]) userImage,
      ],
    );
  }
}
