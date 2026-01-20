import 'package:easyrent/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/login_page.dart';
import 'common/main_navigation_page.dart'; // <--- IMPORT THIS
import 'services/offline_queue_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService().initNotifications();
  await OfflineQueueService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EasyRent',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF800000),
          primary: const Color(0xFF800000),
          secondary: const Color(0xFFA00000),
          background: Colors.white,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF800000),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // Logged in? Go to the main wrapper
            return const MainNavigationPage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
