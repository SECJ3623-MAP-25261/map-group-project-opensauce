import 'package:flutter/material.dart';
import 'renter_request_approval_page.dart';
import 'renter_status_page.dart';
import 'renter_availability_page.dart';

class RenterManagementPage extends StatefulWidget {
  const RenterManagementPage({super.key});

  @override
  State<RenterManagementPage> createState() => _RenterManagementPageState();
}

class _RenterManagementPageState extends State<RenterManagementPage>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Renter Management"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF800000),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF800000),
          tabs: const [
            Tab(text: "Request Approval"),
            Tab(text: "Status"),
            Tab(text: "Availability"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RenterRequestApprovalPage(),
          RenterStatusPage(),
          RenterAvailabilityPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        selectedItemColor: const Color(0xFF800000),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
          // Example:
          // if(index == 1) Navigator.push(...);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "Wishlist",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: "Message",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Account",
          ),
        ],
      ),
    );
  }
}
