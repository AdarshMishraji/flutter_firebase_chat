import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/constants/locale.dart';
import 'package:flutter_firebase_chat/screens/models/chatRooms.dart';
import 'package:flutter_firebase_chat/screens/models/chats.dart';

class MessageInput extends StatefulWidget {
  final String roomId;
  const MessageInput({Key? key, required this.roomId}) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _firestoreInstance = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  String _enteredMessage = '';

  void _sendMessage() {
    FocusScope.of(context).unfocus();
    _firestoreInstance
        .collection(ChatRooms.collectionName)
        .doc(widget.roomId)
        .collection(Chats.collectionName)
        .add({
      Chats.message: _enteredMessage,
      Chats.type: MessageTypes.text,
      Chats.sendAt: DateTime.now().toIso8601String(),
      Chats.senderUserId: _currentUser!.uid
    }).then((_) {
      setState(() {
        _enteredMessage = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(label: Text(Locale.sendAMessage)),
            onChanged: (value) {
              setState(() {
                _enteredMessage = value;
              });
            },
          ),
        ),
        IconButton(
          onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
          icon: const Icon(Icons.send),
          color: Theme.of(context).primaryColor,
        ),
      ]),
    );
  }
}
