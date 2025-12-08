import 'package:easyrent/features/message/messages.dart';
import 'package:easyrent/features/rentee/services/notifiers.dart';
import 'package:easyrent/features/rentee/my_profile_page.dart';
import 'package:easyrent/features/rentee/wishlist/presentation/page/wishlist_page.dart';
import 'package:flutter/material.dart';
import 'features/rentee/homePage/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Generated file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   runApp(ProviderScope(child: const MyApp()));
  }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}




class _MyAppState extends State<MyApp> {
  @override
  final List<Widget> _pages = [
    // Replace these with your actual screen widgets:
    HomePage(),
    WishlistPage(),

  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EasyRent',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        primarySwatch: Colors.amber,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF800000),
        ),
      ),
      home: 
      ValueListenableBuilder(valueListenable: selectedPageNotifiers, builder: (context, value, child) {
        if(value == 0){
            return HomePage();
        } else if(value ==1) {
          return WishlistPage();
        } else {
          return MyProfilePage();
        }
      },),
    );
  }
}