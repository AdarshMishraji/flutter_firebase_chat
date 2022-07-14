import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/screens/auth/authForm.dart';

class AuthScreen extends StatelessWidget {
  static const String routeName = '/auth';
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: const AuthForm(),
    );
  }
}
