import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/constants/locale.dart';
import 'package:flutter_firebase_chat/screens/chatRoom/screen.dart';
import 'package:flutter_firebase_chat/screens/models/chatRooms.dart';
import 'package:flutter_firebase_chat/screens/models/users.dart';
import 'package:flutter_firebase_chat/screens/userList/groupForm.dart';
import 'package:flutter_firebase_chat/widgets/loader.dart';

class UserList extends StatefulWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> userList;
  const UserList({Key? key, required this.userList}) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  // ui state variables
  final Map<String, bool> _selectedUsers = {};
  bool _loading = false;

  // firebase constants;
  final _firestoreInstance = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  // firebase related variables;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _currentUserRooms = [];
  DocumentReference<Map<String, dynamic>>? _currentUserRef;

  // frequently updated variable
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _listListener;

  @override
  void initState() {
    // componentDidMount
    final currentUserRef = _firestoreInstance
        .collection(Users.collectionName)
        .doc(_currentUser!.uid);
    _currentUserRef = currentUserRef;
    _listListener = _firestoreInstance
        .collection(ChatRooms.collectionName)
        .where(ChatRooms.roomType, isEqualTo: RoomTypes.duet)
        .where(ChatRooms.roomUsers, arrayContains: currentUserRef)
        .snapshots()
        .listen((value) => _currentUserRooms = value.docs);
    super.initState();
  }

  @override
  void dispose() {
    _listListener!.cancel();
    super.dispose();
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUsers.containsKey(userId)) {
        if (_selectedUsers[userId]!) {
          _selectedUsers.remove(userId);
        }
      } else {
        _selectedUsers[userId] = true;
      }
    });
  }

  void _clearSelectedUsers() {
    setState(() {
      _selectedUsers.clear();
    });
  }

  void _createGroup({required String roomName, String? roomLogo}) async {
    if (_selectedUsers.length > 1) {
      // create group
      try {
        if (_currentUserRef != null) {
          final List<DocumentReference<Map<String, dynamic>>> userRefs = [];
          _selectedUsers.forEach((key, _) {
            userRefs.add(
                _firestoreInstance.collection(Users.collectionName).doc(key));
          });
          userRefs.add(_currentUserRef!);
          await _firestoreInstance.collection(ChatRooms.collectionName).add({
            ChatRooms.roomType: RoomTypes.group,
            ChatRooms.creatorUser: _currentUserRef,
            ChatRooms.roomUsers: userRefs,
            ChatRooms.roomName: roomName,
            ChatRooms.createdAt: DateTime.now().toIso8601String(),
          }).then((room) {
            Navigator.of(context)
                .pushReplacementNamed(ChatRoomScreen.routeName, arguments: {
              ChatRooms.roomId: room.id,
              ChatRooms.roomName: roomName,
              ChatRooms.roomLogo: roomLogo,
              ChatRooms.roomType: RoomTypes.group,
              ChatRooms.roomUsers: userRefs
            });
          });
        } else {
          throw Exception('No currentUserRef');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future _selectedUserToConnectFromMultiSelectMode() async {
    if (_selectedUsers.isNotEmpty) {
      try {
        // single user
        final userId = _selectedUsers.keys.first;
        final userDetail = widget.userList
            .firstWhere((element) => element.id == userId)
            .data();
        await _selectedUserToConnect({...userDetail, Users.userId: userId});
      } on StateError {
        print('no match found');
      }
    }
  }

  Future _selectedUserToConnect(Map<String, dynamic> user) async {
    try {
      if (_currentUserRef == null) {
        return;
      }
      setState(() {
        _loading = true;
      });
      final selectedUserRef = _firestoreInstance
          .collection(Users.collectionName)
          .doc(user[Users.userId]);

      final room = _currentUserRooms.where((element) {
        final data = element.data();
        final roomUsers = data[ChatRooms.roomUsers];
        return (roomUsers[0] == selectedUserRef &&
                roomUsers[1] == _currentUserRef) ||
            (roomUsers[0] == _currentUserRef &&
                roomUsers[1] == selectedUserRef);
      }).toList();
      String? roomId;
      if (room.isEmpty) {
        await _firestoreInstance.collection(ChatRooms.collectionName).add({
          ChatRooms.roomType: RoomTypes.duet,
          ChatRooms.creatorUser: _currentUserRef,
          ChatRooms.roomUsers: [
            _currentUserRef,
            selectedUserRef,
          ],
          ChatRooms.createdAt: DateTime.now().toIso8601String(),
        }).then((room) {
          roomId = room.id;
        });
      } else {
        roomId = room[0].id;
      }
      Navigator.of(context)
          .pushReplacementNamed(ChatRoomScreen.routeName, arguments: {
        ChatRooms.roomId: roomId,
        ChatRooms.roomName: user[Users.name],
        ChatRooms.roomLogo:
            user.containsKey(Users.imageUrl) ? user[Users.imageUrl] : null,
        ChatRooms.roomType: RoomTypes.duet,
        ChatRooms.roomUsers: [
          _currentUserRef,
          selectedUserRef,
        ]
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showGroupNameEntryModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GroupForm(
            onRoomNameSubmitted: (String roomName) {
              _createGroup(roomName: roomName);
              Navigator.of(context).pop();
            },
            close: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        title: const Text(Locale.users),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.userList.length,
                  itemBuilder: (_, index) {
                    final id = widget.userList[index].id;
                    final data = widget.userList[index].data();
                    final isSelected =
                        _selectedUsers.containsKey(id) && _selectedUsers[id]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: UserListItem(
                        key: ValueKey(id),
                        isSelected: isSelected,
                        user: {...data, Users.userId: id},
                        onLongPressCallback: _toggleUserSelection,
                        onTapCallback: _selectedUsers.isNotEmpty
                            ? (user) => _toggleUserSelection(user[Users.userId])
                            : _selectedUserToConnect,
                      ),
                    );
                  },
                ),
              ),
              if (_selectedUsers.isNotEmpty)
                Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0, -5),
                            blurRadius: 10,
                            spreadRadius: 1)
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _clearSelectedUsers,
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).errorColor),
                            child: const Text(Locale.clearAll),
                          ),
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _selectedUsers.length > 1
                                ? _showGroupNameEntryModal
                                : _selectedUserToConnectFromMultiSelectMode,
                            child: Text(_selectedUsers.length > 1
                                ? '${Locale.createGroup} ${_selectedUsers.length}'
                                : Locale.connect),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Loader(
            isFullScreen: true,
            isfullScreenWithBackgroundTransparent: true,
            isLoading: _loading,
            loaderSize: 50,
          )
        ],
      ),
    );
  }
}

class UserListItem extends StatelessWidget {
  final bool isSelected;
  final Map<String, dynamic> user;
  final Function(Map<String, dynamic> user) onTapCallback;
  final Function(String id) onLongPressCallback;

  const UserListItem(
      {Key? key,
      required this.isSelected,
      required this.user,
      required this.onLongPressCallback,
      required this.onTapCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        selected: isSelected,
        selectedTileColor: Colors.greenAccent.withOpacity(0.75),
        selectedColor: null,
        key: ValueKey(user[Users.userId]),
        leading: !user.containsKey(Users.imageUrl)
            ? Icon(Icons.account_circle,
                size: 52, color: Theme.of(context).primaryColor)
            : ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Image.network(
                  user[Users.imageUrl],
                  height: 52,
                  width: 52,
                  fit: BoxFit.cover,
                ),
              ),
        title: Text(
          user[Users.name],
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Text(
          user[Users.email],
          style: Theme.of(context).textTheme.titleSmall,
        ),
        onLongPress: () => onLongPressCallback(user[Users.userId]),
        onTap: () => onTapCallback(user),
      ),
    );
  }
}
