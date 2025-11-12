import 'package:flutter/material.dart';
import '../account/registration/renter_registration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyRent App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF800000), // Maroon color
        ),
      ),
      home: OnboardingPage(),
    );
  }
}

class SimpleStartPage extends StatefulWidget {
  const SimpleStartPage({super.key});

  @override
  State<SimpleStartPage> createState() => _SimpleStartPageState();
}

class _SimpleStartPageState extends State<SimpleStartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RenterRegistrationPage(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF800000), // Maroon color
            foregroundColor: Colors.white, // White text color
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text('Switch to Renter'),
        ),
      ),
    );
  }
}
