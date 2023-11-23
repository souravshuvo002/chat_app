import 'package:chat_app/pages/LoginPage.dart';
import 'package:chat_app/pages/RegisterPage.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {

  // initially show login page
  bool showLoginPage = true;

  // toggle between login and register page
  void toggleState()
  {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return LoginPage(ontap: toggleState);
    }
    else
      {
        return RegisterPage(ontap: toggleState);
      }
  }
}
