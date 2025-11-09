import 'package:flutter/material.dart';

// login + register page (Kai Bin)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Reset Password",style: TextStyle(fontWeight: FontWeight.bold),)
          ],
        ),
      )
    );
  }
}