import 'package:flutter/material.dart';

class NavbarWidget extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavbarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends State<NavbarWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF5C001F),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "EXPLORE",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: "WISHLIST",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: "SCAN",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: "MESSAGES",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "ACCOUNT",
        ),
      ],
    );
  }
}
