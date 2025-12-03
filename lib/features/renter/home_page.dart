import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rentee Home")),
      body: const Center(
        child: Text(
          "This is the Rentee Home Page",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}