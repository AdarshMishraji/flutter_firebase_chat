import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/constants/locale.dart';
import 'package:flutter_firebase_chat/screens/rooms/rooms.dart';
import 'package:flutter_firebase_chat/screens/userList/screen.dart';

class ChatsScreen extends StatelessWidget {
  static const String routeName = '/chats';
  const ChatsScreen({Key? key}) : super(key: key);

  void _signout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          Locale.rooms,
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: _signout,
              icon: Icon(Icons.logout, color: theme.primaryColor))
        ],
      ),
      body: const Rooms(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.people_alt),
        onPressed: () =>
            Navigator.of(context).pushNamed(UserListScreen.routeName),
      ),
    );
  }
}
