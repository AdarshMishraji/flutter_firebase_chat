import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/screens/models/users.dart';
import 'package:flutter_firebase_chat/screens/userList/userList.dart';
import 'package:flutter_firebase_chat/widgets/loader.dart';

class UserListScreen extends StatelessWidget {
  static const String routeName = '/user-list';
  const UserListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(Users.collectionName)
            .where('__name__', isNotEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Loader(
              isFullScreen: true,
            );
          }
          final userList = userSnapshot.data!.docs;
          return UserList(userList: userList);
        },
      ),
    );
  }
}
