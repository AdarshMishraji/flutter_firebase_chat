import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_chat/constants/locale.dart';
import 'package:flutter_firebase_chat/screens/auth/authTabs.dart';
import 'package:flutter_firebase_chat/screens/models/users.dart';
import 'package:flutter_firebase_chat/widgets/loader.dart';
import 'package:flutter_firebase_chat/widgets/userImagePicker.dart';
import 'package:regex_validator/regex_validator.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  String _userEmail = '';
  String _userName = '';
  String _password = '';
  File? _imageUrl;

  void _onSubmitForm({
    required String email,
    required String password,
    String? username = '',
    required bool isLogin,
    required File? imageUrl,
  }) async {
    final auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential;
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final imageUploadSnapshotListener = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${auth.currentUser!.uid}.png');

        await imageUploadSnapshotListener.putFile(_imageUrl!).then((p0) {
          if (p0.bytesTransferred == p0.totalBytes) {
            print('Upload complete');
          }
        });
        await FirebaseFirestore.instance
            .collection(Users.collectionName)
            .doc(userCredential.user!.uid)
            .set({
          Users.name: username,
          Users.email: email,
          Users.joinedAt:
              userCredential.user!.metadata.creationTime!.toIso8601String(),
          Users.imageUrl: await imageUploadSnapshotListener.getDownloadURL()
        });
      }
    } on PlatformException catch (e) {
      String? message = Locale.errorOccuredCheckCredentials;
      if (e.message != null) {
        message = e.message;
      }
      throw Exception(message);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    }
  }

  void _trySubmit() {
    final isValid = _formKey.currentState?.validate();
    FocusScope.of(context).unfocus(); // close the keyboard;
    if (isValid != null && !isValid) {
      return;
    } else {
      if (!_isLogin && _imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter an image url.')));
        return;
      }
      _formKey.currentState?.save();
      _onSubmitForm(
          email: _userEmail.trim(),
          username: _userName.trim(),
          isLogin: _isLogin,
          password: _password.trim(),
          imageUrl: !_isLogin ? _imageUrl! : null);
    }
  }

  void _onImageSelected(File image) {
    _imageUrl = image;
  }

  void _toggleAuthForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        margin: const EdgeInsets.all(20),
        child: AnimatedContainer(
          margin: const EdgeInsets.all(16),
          height: _isLogin ? 275 : 475,
          duration: const Duration(milliseconds: 500),
          curve: Curves.linearToEaseOut,
          child: SingleChildScrollView(
            child: SizedBox(
              height: _isLogin ? 275 : 475,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthTabs(
                            isLogin: _isLogin, toggleAuthForm: _toggleAuthForm),
                        if (!_isLogin)
                          UserImagePicker(onImagePicked: _onImageSelected),
                        TextFormField(
                          key: const ValueKey(Locale.emailAddress),
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              labelText: Locale.emailAddress),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Locale.enterEmailAddress;
                            }
                            if (!value.isEmail()) {
                              return Locale.enterValidEmailAddress;
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _userEmail = value!;
                          },
                        ),
                        if (!_isLogin)
                          TextFormField(
                            key: const ValueKey(Locale.userName),
                            decoration: const InputDecoration(
                                labelText: Locale.userName),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return Locale.enterUsername;
                              }
                              if (!value.isUsername()) {
                                return Locale.enterValidUsername;
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _userName = value!;
                            },
                          ),
                        TextFormField(
                          key: const ValueKey(Locale.password),
                          decoration:
                              const InputDecoration(labelText: Locale.password),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Locale.enterPassword;
                            }
                            if (value.isPasswordHard()) {
                              return null;
                            }
                            if (value.isPasswordNormal1() ||
                                value.isPasswordNormal2() ||
                                value.isPasswordNormal3()) {
                              return Locale.passwordNotStrong;
                            }
                            if (!value.isPasswordEasy()) {
                              return Locale.passwordLessThan8Chars;
                            }
                            return Locale.passwordIsTooWeak;
                          },
                          onSaved: (value) {
                            _password = value!;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _trySubmit,
                    child: _isLoading
                        ? const Loader(
                            isFullScreen: false,
                            isLoading: true,
                            loaderColor: Colors.white)
                        : Text(_isLogin ? Locale.login : Locale.signup),
                  ),
                ],
              ),
            ),
            // ),
          ),
        ),
      ),
    );
  }
}
