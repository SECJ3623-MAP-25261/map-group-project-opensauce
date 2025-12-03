import 'package:easyrent/features/message/messages.dart';
import 'package:easyrent/features/rentee/application/notifiers.dart';
import 'package:easyrent/features/rentee/rentee_profile/presentation/pages/my_profile_page.dart';
import 'package:easyrent/features/rentee/wishlist/presentation/page/wishlist_page.dart';
import 'package:easyrent/features/renter/listing_management/presentation/pages/listing.dart';
import 'package:flutter/material.dart';
import 'features/rentee/homePage/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/renter/renter_management/presentation/pages/dummy_select_role.dart';


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
  final List<Widget> _pages = [
    // Replace these with your actual screen widgets:
    HomePage(),
    WishlistPage(),

  ];
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
      home: MessagesApp()
      // ValueListenableBuilder(valueListenable: selectedPageNotifiers, builder: (context, value, child) {
      //   if(value == 0){
      //       return HomePage();
      //   } else if(value ==1) {
      //     return WishlistPage();
      //   } else {
      //     return MyProfilePage();
      //   }
      // },),
    );
  }
}