import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/core/utils/parse_date.dart';
import 'package:easyrent/features/models/item.dart';
import 'package:easyrent/features/rentee/renting_status/data/dummy_data/renting_status_dummy.dart';
import 'package:easyrent/features/rentee/presentation/widgets/rentee_bottom_navbar.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/history_item_card_widgets.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/inRenting_item_card_widget.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/ordering_item_card_widget.dart';
import 'package:easyrent/features/rentee/renting_status/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Convert to DefaultTabController and implement tabs
class RentingStatusPage extends ConsumerStatefulWidget {
  const RentingStatusPage({super.key});

  @override
  ConsumerState<RentingStatusPage> createState() => _RentingStatusPageState();
}

class _RentingStatusPageState extends ConsumerState<RentingStatusPage>
    with
        TickerProviderStateMixin // Add TickerProviderStateMixin for TabController
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
            Navigator.pop(context);
          },
        ),

        title: const Text('Renting', style: KTextStyle.appBarTitle),
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
          _buildInRentingTabContent(),
          _buildHistoryTabContent(),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: const RenteeBottomNavBar(),
    );
  }

  // --- WIDGET METHOD TO BUILD THE CONTENT ---
  Widget _buildOrderingTabContent() {
    // 1. Define the stream variable with the correct type: Stream<List<Map<String, dynamic>>>
    final Stream<List<Map<String, dynamic>>> orderingItemsStream =
        RentingStatusDatabaseService().getOrderingItems(AppString.userSampleId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),

      // 2. Switched from FutureBuilder to StreamBuilder
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: orderingItemsStream,

        builder: (context, asyncSnapshot) {
          // --- Connection State Handling ---
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while the stream is waiting for its first item
            return const Center(child: CircularProgressIndicator());
          }

          // --- Error Handling ---
          if (asyncSnapshot.hasError) {
            // Display the error if the stream encounters one
            return Center(child: Text('Error: ${asyncSnapshot.error}'));
          }

          // --- Data Handling ---
          // Retrieve the data, which is now the latest list emitted by the stream
          final List<Map<String, dynamic>> orderingItems =
              asyncSnapshot.data ?? [];

          if (orderingItems.isEmpty) {
            // Display message if the data list is empty
            return const Center(child: Text('No ordering items found.'));
          }

          // 3. Build the UI using the latest data from the stream
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                orderingItems.map((item) {

                  final itemMap = item['items'];
                  // print("the main item is ${item}");
                  // print("the duration and endRenting and pending is : ${item['duration']} ${item['endRenting']} ${item['status']}");
                  // print("the id is ${item['id']}");
                  final Item itemDetails = Item.fromMap(itemMap, item['id']);

                  if (itemDetails != null) {
                    // comvert string to datetime 
                    final endRenting = parseDate(item['endRenting']);
                    return RentalItemCardWidget(item: itemDetails,orderDate: item['duration'], returnDate: (endRenting!), status: item['status'],totalFee: item['totalFee'],);
                  }
                  return const SizedBox.shrink();
                }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildInRentingTabContent() {
    // 1. Define the stream for items currently in renting status
    final Stream<List<Map<String, dynamic>>> inRentingItemsStream =
        RentingStatusDatabaseService().getInRentingItems(
          AppString.userSampleId,
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: inRentingItemsStream,
        builder: (context, asyncSnapshot) {
          // --- Connection State Handling ---
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Error Handling ---
          if (asyncSnapshot.hasError) {
            return Center(child: Text('Error: ${asyncSnapshot.error}'));
          }

          // --- Data Handling ---
          final List<Map<String, dynamic>> inRentingItems =
              asyncSnapshot.data ?? [];

          if (inRentingItems.isEmpty) {
            return const Center(child: Text('No items currently in renting.'));
          }

          // 2. Build the UI using the latest data from the stream
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                inRentingItems.map((order) {
                  
                  final itemMap = order['items'];
                  final Item itemDetails = Item.fromMap(itemMap, order['id']);

                  if (itemDetails != null) {
                    final startDate = parseDate(order['startRenting']);
                    final endDate = parseDate(order['endRenting']);
                    return InrentingItemCardWidget(item: itemDetails, status:order['status'] ,totalPrice: order['totalFee'],startDate: startDate!, endDate: endDate!, returnMethods: order['deliveryOption']);
                  }

                  // Return an empty widget if the data is corrupted or missing the 'items' field
                  return const SizedBox.shrink();
                }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTabContent() {
    // 1. Define the stream for completed/history items
    final Stream<List<Map<String, dynamic>>> historyItemsStream =
        RentingStatusDatabaseService().getHistoryItems(AppString.userSampleId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: historyItemsStream,
        builder: (context, asyncSnapshot) {
          // --- Connection State Handling ---
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Error Handling ---
          if (asyncSnapshot.hasError) {
            return Center(child: Text('Error: ${asyncSnapshot.error}'));
          }

          // --- Data Handling ---
          final List<Map<String, dynamic>> historyItems =
              asyncSnapshot.data ?? [];

          if (historyItems.isEmpty) {
            return const Center(child: Text('No order history found.'));
          }

          // 2. Build the UI using the latest data from the stream
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                historyItems.map((order) {

                  final itemMap = order['items'];
                  final Item itemDetails = Item.fromMap(itemMap, order['id']);
                  if (itemDetails != null) {
                    final endRenting = parseDate(order['endRenting']);
                    final startRenting = parseDate(order['startRenting']);
                    return HistoryItemCardWidgets(item: itemDetails, startDate: startRenting!, endDate: endRenting!, duration: order['duration'], status: order['status'], totalPrice: order['totalFee'], );
                  }

                  return const SizedBox.shrink();
                }).toList(),
          );
        },
      ),
    );
  }
}
