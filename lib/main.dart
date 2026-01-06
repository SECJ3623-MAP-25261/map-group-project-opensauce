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
import 'connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const ProviderScope(child: MyApp()));
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
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        primarySwatch: Colors.amber,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF800000)),
      ),
      home: DummySelectRole(),
      builder: (context, child) {
        return ConnectivityWrapper(child: child!);
      },
      // home: const MainScreen(),
      // routes: {
      //   '/home' : (_) => HomePage(),
      //   '/renting-status' : (_) => RentingStatusPage(),
      // },
      // home: MainScreen(),
    );
  }
}

class ConnectivityWrapper extends ConsumerWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    final isOnline = connectivityAsync.value ?? true;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: !isOnline ? 40 : 0,
            width: double.infinity,
            color: const Color(0xFF333333),
            child: !isOnline
                ? const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        const Text(
                          "Offline Mode - Showing saved data",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(child: child),
        ],
      ),
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
    const WishlistPage(), // Index 1 
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
