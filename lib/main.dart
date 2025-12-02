import 'package:easyrent/pages/renter/listing.dart';
import 'package:flutter/material.dart';
import 'features/renter/renter_management/presentation/pages/dummy_select_role.dart';


void main() {
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