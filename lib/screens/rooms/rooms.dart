import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/screens/chatRoom/screen.dart';
import 'package:flutter_firebase_chat/screens/models/chatRooms.dart';
import 'package:flutter_firebase_chat/screens/models/users.dart';

class Rooms extends StatefulWidget {
  const Rooms({Key? key}) : super(key: key);

  @override
  State<Rooms> createState() => _RoomsState();
}

class _RoomsState extends State<Rooms> {
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _firestoreInstance = FirebaseFirestore.instance;
  DocumentReference<Map<String, dynamic>>? _currentUserRef;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _snapshotListener;

  List _roomList = [];

  void _setRoomList(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> rooms) async {
    final tempList = [];
    Future.forEach<QueryDocumentSnapshot<Map<String, dynamic>>>(rooms,
        (element) async {
      if (element[ChatRooms.roomType] == RoomTypes.group) {
        final data = element.data();
        Map<String, dynamic> roomUsers = {};
        await Future.forEach<dynamic>(data[ChatRooms.roomUsers], (user) async {
          user = await user.get();
          roomUsers[user.id] = user.data();
        }).then((_) {
          print(roomUsers);
          tempList.add({
            ...data,
            ChatRooms.roomId: element.id,
            ChatRooms.roomUsers: roomUsers
          });
        });
      } else {
        final roomUsers = element[ChatRooms.roomUsers];
        if (roomUsers[0] == _currentUserRef) {
          await roomUsers[1].get().then((user) async {
            final otherUser = await roomUsers[0].get();
            tempList.add({
              ...element.data(),
              ChatRooms.roomUsers: {
                user.id: user.data(),
                otherUser.id: otherUser.data(),
              },
              ChatRooms.roomName: user[Users.name],
              ChatRooms.roomLogo: user[Users.imageUrl],
              ChatRooms.roomId: element.id
            });
          });
        } else {
          await roomUsers[0].get().then((user) async {
            final otherUser = await roomUsers[1].get();
            tempList.add({
              ...element.data(),
              ChatRooms.roomUsers: {
                user.id: user.data(),
                otherUser.id: otherUser.data(),
              },
              ChatRooms.roomName: user[Users.name],
              ChatRooms.roomLogo: user[Users.imageUrl],
              ChatRooms.roomId: element.id,
            });
          });
        }
      }
    }).then((_) {
      setState(() {
        _roomList = tempList;
      });
    });
  }

  @override
  void initState() {
    _currentUserRef = _firestoreInstance
        .collection(Users.collectionName)
        .doc(_currentUser!.uid);
    _snapshotListener = _firestoreInstance
        .collection(ChatRooms.collectionName)
        .where(ChatRooms.roomUsers, arrayContains: _currentUserRef)
        .snapshots()
        .listen((event) => _setRoomList(event.docs.reversed.toList()));
    super.initState();
  }

  @override
  void dispose() {
    _snapshotListener!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _roomList.length,
            itemBuilder: (_, index) {
              return RoomItems(roomItem: _roomList[index]);
            },
          ))
        ],
      ),
    );
  }
}

class RoomItems extends StatelessWidget {
  final Map<dynamic, dynamic> roomItem;
  const RoomItems({Key? key, required this.roomItem}) : super(key: key);

  void onTapCallback(BuildContext context) {
    Navigator.of(context)
        .pushNamed(ChatRoomScreen.routeName, arguments: roomItem);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          // selected: isSelected,
          selectedTileColor: Colors.greenAccent.withOpacity(0.75),
          selectedColor: null,
          key: ValueKey(roomItem[ChatRooms.roomId]),
          leading: !roomItem.containsKey(ChatRooms.roomLogo)
              ? Icon(Icons.account_circle,
                  size: 52, color: Theme.of(context).primaryColor)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Image.network(
                    roomItem[ChatRooms.roomLogo],
                    height: 52,
                    width: 52,
                    fit: BoxFit.cover,
                  ),
                ),
          title: Text(
            roomItem[ChatRooms.roomName],
            style: Theme.of(context).textTheme.titleLarge,
          ),
          // onLongPress: () => onLongPressCallback(user[ChatRooms.userId]),
          onTap: () => onTapCallback(context),
        ),
      ),
    );
  }
}
