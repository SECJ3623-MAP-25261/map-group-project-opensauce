import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../account/registration/renter_registration.dart';
import 'account/recovery/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // WEB SETUP
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB-FmpQ7mEkt96pHju22S_jiK7RNG3ZkX8",
        appId: "1:319516291992:web:9ae20352abf0ba7d9b71ed",
        messagingSenderId: "319516291992",
        projectId: "opensource-88def",
        storageBucket: "opensource-88def.firebasestorage.app",
      ),
    );
  } else {
    // ANDROID/iOS SETUP (Uses google-services.json)
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
