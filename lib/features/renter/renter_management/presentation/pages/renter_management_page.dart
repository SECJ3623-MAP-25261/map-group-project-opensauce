import 'package:flutter/material.dart';
import '../../../listing_management/presentation/widgets/renter_navbar.dart';
import '../../../listing_management/presentation/pages/renter_listing_wrapper.dart';

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
  
  final int _bottomNavIndex = 1; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _onItemTapped(int index) {
    if (index == _bottomNavIndex) return;

    switch (index) {
      case 0:
        // Go to Listing
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const RenterListingWrapper(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 1:

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Renter Management"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF5C001F), 
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF5C001F),
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
      
      bottomNavigationBar: RenterBottomNavBar(
        selectedIndex: _bottomNavIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}