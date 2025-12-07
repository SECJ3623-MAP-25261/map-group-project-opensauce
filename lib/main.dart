import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Required to check kIsWeb
import 'features/renter/renter_management/presentation/pages/dummy_select_role.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // ⚠️ ONLY FOR WEB: Paste your keys from Firebase Console here
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
    // FOR ANDROID/iOS: Uses google-services.json automatically
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyRent App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF800000),
        ),
      ),
      home: DummySelectRole(),

    );
  }
}
