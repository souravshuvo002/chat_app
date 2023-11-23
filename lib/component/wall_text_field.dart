import 'package:flutter/material.dart';

class Wall_Text_Field extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  const Wall_Text_Field({super.key, required this.controller, required this.hintText, required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: const InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: 'Write something on the wall',
          hintStyle: TextStyle(color: Colors.black)
      ),

    );
  }
}
