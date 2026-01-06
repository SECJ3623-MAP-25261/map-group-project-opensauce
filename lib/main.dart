import 'package:easyrent/features/renter/renter_management/presentation/pages/dummy_select_role.dart';
import 'package:easyrent/features/rentee/services/notifiers.dart';
import 'package:easyrent/features/rentee/wishlist/presentation/page/wishlist_page.dart';
import 'package:flutter/material.dart';
import 'features/rentee/homePage/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/rentee/presentation/widgets/rentee_bottom_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import BOTH the service and the wrapper
import 'connectivity_service.dart';
import 'connectivity_wrapper.dart';

import 'package:provider/provider.dart';
import 'features/rentee/notification/services/notification_service.dart';
import 'features/rentee/notification/repositories/notification_repository.dart';
import 'features/rentee/notification/datasources/notification_remote_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (_) => NotificationNotifier(
                NotificationRepositoryImpl(NotificationRemoteApiImpl()),
              )..loadNotifications(),
        ),
      ],
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EasyRent',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        primarySwatch: Colors.amber,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF800000)),
      ),
      // --- FIX IS HERE ---
      // We changed ConnectivityService to ConnectivityWrapper
      home: ConnectivityWrapper(child: const MainScreen()),
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
    const HomePage(),
    const WishlistPage(),
    const Center(child: Text("Scan Page")),
    const Center(child: Text("Messages Page")),
    DummySelectRole(),
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
