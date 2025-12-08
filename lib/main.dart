import 'package:easyrent/features/message/messages.dart';
import 'package:easyrent/features/rentee/services/notifiers.dart';
import 'package:easyrent/features/rentee/my_profile_page.dart';
import 'package:easyrent/features/rentee/wishlist/presentation/page/wishlist_page.dart';
import 'package:easyrent/features/renter/renter_management/presentation/pages/dummy_select_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'features/rentee/homePage/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/rentee/homePage/home_page.dart';
import 'features/rentee/wishlist/presentation/page/wishlist_page.dart';
import 'features/rentee/presentation/widgets/rentee_bottom_navbar.dart';
import 'features/rentee/services/notifiers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
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
      title: 'EasyRent',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        primarySwatch: Colors.amber,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF800000)),
      ),
      home: DummySelectRole(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _pages = [
    const HomePage(), // Index 0
    const WishlistPage(), // Index 1 (Make sure this is imported!)
    const Center(child: Text("Scan Page")),
    const Center(child: Text("Messages Page")),
    const Center(child: Text("Account Page")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: selectedPageNotifiers,
        builder: (context, index, child) {
          if (index >= _pages.length) return _pages[0];
          return _pages[index];
        },
      ),
      bottomNavigationBar: const RenteeBottomNavBar(),
    );
  }
}
