import 'package:easyrent/features/rentee/services/notifiers.dart';
import 'package:flutter/material.dart';

class RenteeBottomNavBar extends StatelessWidget {
  // final int selectedIndex;
  // final Function(int) onItemTapped;

  const RenteeBottomNavBar({
    super.key,
    // required this.selectedIndex,
    // required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifiers,
      builder: (context, selectedPage, child) {
        return BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedPageNotifiers.value,
          onTap: (value) {
            selectedPageNotifiers.value = value;
          },
          selectedItemColor: const Color(0xFF5C001F),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "EXPLORE"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "WISHLIST"),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "SCAN"),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "MESSAGES"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "ACCOUNT"),
          ],
        );
      }
    );
  }
}
