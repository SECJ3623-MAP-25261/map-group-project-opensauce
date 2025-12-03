import 'package:easyrent/features/geolocation.dart';
import 'package:easyrent/features/rentee/checkout/presentation/pages/checkout_page.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/pages/renting_status_page.dart';
import 'package:easyrent/features/rentee/wishlist/presentation/page/wishlist_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/account/registration/renter_registration.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
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
      home: RentingStatusPage(),
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
