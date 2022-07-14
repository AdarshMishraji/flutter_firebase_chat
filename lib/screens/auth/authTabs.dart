import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/constants/locale.dart';

class AuthTabs extends StatelessWidget {
  final VoidCallback toggleAuthForm;
  final bool isLogin;
  const AuthTabs(
      {Key? key, required this.toggleAuthForm, required this.isLogin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = MediaQuery.of(context).size;
    final tabSize = (mediaQuerySize.width - 70) / 2;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: toggleAuthForm,
                child: Container(
                  width: tabSize - 10,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(15),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: const Text(Locale.login, textAlign: TextAlign.center),
                ),
              ),
              GestureDetector(
                onTap: toggleAuthForm,
                child: Container(
                  width: tabSize - 10,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(15),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: const Text(Locale.signup, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            transform: Transform.translate(
                    offset: Offset(isLogin ? 10 : tabSize - 10, 0))
                .transform,
            width: tabSize,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).primaryColor,
                    spreadRadius: 1,
                    blurRadius: 7.5)
              ],
            ),
            child: Text(
              isLogin ? Locale.login : Locale.signup,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
