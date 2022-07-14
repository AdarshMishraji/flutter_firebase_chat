import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/constants/locale.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final Function(File) onImagePicked;
  const UserImagePicker({Key? key, required this.onImagePicked})
      : super(key: key);

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _imageUrl;

  void _selectProfileImage() async {
    final pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    setState(() {
      _imageUrl = File(pickedImage!.path);
    });
    widget.onImagePicked(_imageUrl!);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: CircleAvatar(
                radius: 30,
                backgroundImage:
                    _imageUrl != null ? FileImage(_imageUrl!) : null,
                child: _imageUrl == null
                    ? const Icon(Icons.account_circle,
                        size: 52, color: Colors.white)
                    : null),
          ),
          TextButton.icon(
            onPressed: _selectProfileImage,
            icon: const Icon(Icons.add_a_photo),
            label: const Text(Locale.addProfilePic),
          ),
        ],
      ),
    );
  }
}
