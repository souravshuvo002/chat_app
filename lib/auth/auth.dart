import 'package:chat_app/auth/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/HomePage.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user logged in
          if (snapshot.hasData) {
            return const HomePage();
          }
          else
            {
              return const LoginOrRegister();
            }
        },
      ),
    );
  }
}
