import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// IMPORT YOUR PAGES
// import '../rentee/home_page.dart'; // Rentee Home (Explore)
import '../rentee/rentee_market_page.dart';
import '../rentee/rentee_profile_page.dart';
import '../renter/dashboard.dart'; // Renter Dashboard
import '../renter/renter_profile_page.dart';
import '../renter/renter_listing_page.dart';
import '../rentee/wishlist_page.dart';
import 'chat_list_page.dart';
import '../rentee/scan_page.dart';
import '../renter/renter_scan_page.dart';

class MainNavigationPage extends StatefulWidget {
  final bool initialRenterMode;

  const MainNavigationPage({super.key, this.initialRenterMode = false});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex;
  late bool _isRenterMode;

  final Color primaryColor = const Color(0xFF800000);

  @override
  void initState() {
    super.initState();
    _isRenterMode = widget.initialRenterMode;
    _currentIndex = 0;
  }

  // void _toggleMode() {
  //   setState(() {
  //     _isRenterMode = !_isRenterMode;
  //     _currentIndex = 0; // Reset to home when switching modes
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------------------------
    // CRITICAL FIX: Define these lists INSIDE the build method.
    // This allows them to access '_currentIndex' without error.
    // ---------------------------------------------------------

    // --- RENTEE PAGES ---
    final List<Widget> renteePages = [
      const RenteeMarketPage(),
      const WishlistPage(),
      // We pass 'isActive' here. This works because we are inside build().
      RenteeScanReturnPage(isActive: _currentIndex == 2),
      const ChatListPage(),
      const RenteeProfilePage(),
    ];

    // --- RENTER PAGES ---
    final List<Widget> renterPages = [
      const RenterListingsPage(),
      const RenterHomePage(),

      RenterScanPickupPage(isActive: _currentIndex == 2),
      const ChatListPage(),
      const RenterProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _isRenterMode ? renterPages : renteePages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: primaryColor.withOpacity(0.1),
        destinations: _isRenterMode ? _renterDestinations : _renteeDestinations,
      ),
    );
  }

  // --- RENTEE ICONS ---
  List<NavigationDestination> get _renteeDestinations => [
    const NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore, color: Color(0xFF800000)),
      label: 'Explore',
    ),
    const NavigationDestination(
      icon: Icon(Icons.favorite_border),
      selectedIcon: Icon(Icons.favorite, color: Color(0xFF800000)),
      label: 'Wishlist',
    ),
    const NavigationDestination(
      icon: Icon(Icons.qr_code_scanner),
      label: 'Scan',
    ),
    const NavigationDestination(
      icon: Icon(Icons.chat_bubble_outline),
      selectedIcon: Icon(Icons.chat_bubble, color: Color(0xFF800000)),
      label: 'Message',
    ),
    const NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person, color: Color(0xFF800000)),
      label: 'Profile',
    ),
  ];

  // --- RENTER ICONS ---
  List<NavigationDestination> get _renterDestinations => [
    // 1. Listings Icon
    const NavigationDestination(
      icon: Icon(Icons.list_alt),
      selectedIcon: Icon(Icons.list_alt, color: Color(0xFF800000)),
      label: 'Listings',
    ),

    // 2. Dashboard Icon
    const NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard, color: Color(0xFF800000)),
      label: 'Dashboard',
    ),

    const NavigationDestination(
      icon: Icon(Icons.qr_code_scanner),
      label: 'Scan',
    ),
    const NavigationDestination(
      icon: Icon(Icons.chat_bubble_outline),
      selectedIcon: Icon(Icons.chat_bubble, color: Color(0xFF800000)),
      label: 'Message',
    ),
    const NavigationDestination(
      icon: Icon(Icons.store_outlined),
      selectedIcon: Icon(Icons.store, color: Color(0xFF800000)),
      label: 'Profile',
    ),
  ];
}

// Simple placeholder for pages not yet built
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              "$title Page",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text("Coming soon", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
