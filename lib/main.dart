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
        apiKey: "PASTE_YOUR_API_KEY_HERE",
        appId: "PASTE_YOUR_APP_ID_HERE",
        messagingSenderId: "PASTE_YOUR_MESSAGING_SENDER_ID",
        projectId: "PASTE_YOUR_PROJECT_ID",
        storageBucket: "PASTE_YOUR_STORAGE_BUCKET",
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
