import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/constants/locale.dart';
import 'package:flutter_firebase_chat/screens/auth/screen.dart';
import 'package:flutter_firebase_chat/screens/chatRoom/screen.dart';
import 'package:flutter_firebase_chat/screens/rooms/screen.dart';
import 'package:flutter_firebase_chat/screens/userList/screen.dart';
import 'package:flutter_firebase_chat/widgets/loader.dart';

void main() {
  runApp(const Root());
}

class Root extends StatelessWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader(
              isFullScreen: true,
              isLoading: true,
            );
          }
          if (snapshot.hasError) {
            return Container(
              color: Theme.of(context).errorColor,
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
              title: Locale.appName,
              theme: ThemeData(
                  primarySwatch: Colors.blue,
                  textTheme: ThemeData.light().textTheme.copyWith(
                        titleSmall: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                        titleMedium: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        titleLarge: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                  buttonTheme: ButtonTheme.of(context).copyWith(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                    ),
                  ),
                  textButtonTheme:
                      TextButtonThemeData(style: TextButton.styleFrom()),
                  pageTransitionsTheme: const PageTransitionsTheme(builders: {
                    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  })),
              routes: {
                '/': (_) => StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (_, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Loader(
                          isFullScreen: true,
                          isLoading: true,
                        );
                      }
                      if (userSnapshot.hasError) {
                        print(userSnapshot.error);
                        return Container(
                          color: Theme.of(context).errorColor,
                        );
                      }
                      if (userSnapshot.hasData) {
                        return const ChatsScreen();
                      } else {
                        return const AuthScreen();
                      }
                    }),
                AuthScreen.routeName: (_) => const AuthScreen(),
                ChatsScreen.routeName: (_) => const ChatsScreen(),
                ChatRoomScreen.routeName: (_) => const ChatRoomScreen(),
                UserListScreen.routeName: (_) => const UserListScreen(),
              },
            );
          }
          return Container();
        });
  }
}
