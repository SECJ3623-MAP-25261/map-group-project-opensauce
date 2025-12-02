import 'package:easyrent/features/rentee/application/notifiers.dart';
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
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Listing"),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: "Calendar"),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "QR"),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        );
      }
    );
  }
}
