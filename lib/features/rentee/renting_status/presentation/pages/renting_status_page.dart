import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/features/rentee/renting_status/data/dummy_data/renting_status_dummy.dart';
import 'package:easyrent/features/rentee/presentation/widgets/rentee_bottom_navbar.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/rental_item_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Convert to DefaultTabController and implement tabs
class RentingStatusPage extends ConsumerStatefulWidget {
  const RentingStatusPage({super.key});

  @override
  ConsumerState<RentingStatusPage> createState() => _RentingStatusPageState();
}

class _RentingStatusPageState extends ConsumerState<RentingStatusPage> 
    with TickerProviderStateMixin // Add TickerProviderStateMixin for TabController
{
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with the correct number of tabs (3)
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold wraps the entire page
    return Scaffold(
      backgroundColor: Colors.grey[100],
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // Add navigation logic here
          },
        ),
        
        title: const Text(
          'Renting',
          style: KTextStyle.appBarTitle
        ),
        centerTitle: true,
        
        // 2. Implement the TabBar in the AppBar's bottom property
        bottom: TabBar(
          controller: _tabController,
          // Customizing tab indicator and text color
          indicatorColor: AppColors.primaryRed, // Red line beneath active tab
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorWeight: 2, // Thickness of the indicator line
          
          tabs: const [
            Tab(text: 'Ordering'),
            Tab(text: 'In Renting'),
            Tab(text: 'History'),
          ],
        ),
      ),

      // 3. Implement the TabBarView in the body
      // MAIN
      body: TabBarView(
        controller: _tabController,
        children: [
          // Content for the 'Ordering' tab (The main view from the screenshot)
          _buildOrderingTabContent(), 
          // Placeholder for the other tabs
          const Center(child: Text('In Renting Content')),
          const Center(child: Text('History Content')),
        ],
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: const RenteeBottomNavBar(),
    );
  }

  // --- WIDGET METHOD TO BUILD THE CONTENT ---
  Widget _buildOrderingTabContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Positioned.fill(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: userOrdering.length,
                  itemBuilder: (context, index) {
                    return RentalItemCardWidget(item: userOrdering[index]);
                  },
                ),
              ),
        ],
      ),
    );
  }
}