import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:easyrent/widgets/renting_status/history_widget.dart';
import 'package:easyrent/widgets/renting_status/in_renting_widget.dart';
import 'package:easyrent/widgets/renting_status/my_cart_widget.dart';
import 'package:easyrent/widgets/renting_status/ordering_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/rentee_service.dart';
import '../models/cart_model.dart';
import '../widgets/cart_item_card.dart'; // Ensure this exists
import 'payment_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with SingleTickerProviderStateMixin {
  final RenteeService _service = RenteeService();
  final Set<String> _selectedCartIds = {};
  late TabController _tabController;
  // Keep track of the actual Model objects for checkout
  final List<CartItemModel> _selectedItems = [];

  // Connectivity
  bool _isConnected = true;
  StreamSubscription<ConnectivityResult>? _subscription;

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (!mounted) return;
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  double get _currentTotal {
    return _selectedItems.fold(0, (sum, item) => sum + item.totalRentalPrice);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please Login")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          indicatorWeight: 2,
          tabs: const [
            Tab(text: "Cart"),
            Tab(text: "Ordering"),
            Tab(text: "In Renting"),
            Tab(text: "History"),
          ]
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: 
        [
          MyCartWidget(),
          OrderingWidget(),
          InRentingWidget(),
          HistoryWidget(),
        ],
      ),
      
    );
  }

  //   Widget _buildOrderingTabContent() {
  //   final Stream<List<Map<String, dynamic>>> orderingItemsStream =
  //       RentingStatusDatabaseService().getOrderingItems(AppString.userSampleId);

  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(16.0),
  //     child: StreamBuilder<List<Map<String, dynamic>>>(
  //       stream: orderingItemsStream,
  //       builder: (context, asyncSnapshot) {
  //         if (asyncSnapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(child: CircularProgressIndicator());
  //         }

  //         if (asyncSnapshot.hasError) {
  //           return Center(child: Text('Error: ${asyncSnapshot.error}'));
  //         }

  //         final List<Map<String, dynamic>> orderingItems =
  //             asyncSnapshot.data ?? [];

  //         if (orderingItems.isEmpty) {
  //           return const Center(child: Text('No ordering items found.'));
  //         }

  //         return Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children:
  //               orderingItems.map((item) {
                  
  //                 final Map<String, dynamic>? itemMap = item['items'] as Map<String, dynamic>?;                  // print("the 
  //                 if (itemMap == null) {
  //                   return const SizedBox.shrink();
  //                 }
  //                 final String itemId = item['id']?.toString() ?? ''; //! Error: This will show orderId
  //                 final String realProductId  = item['items']['id']?.toString() ?? '';
  //                 // print("------------ itemId is ${item['items']['id']?.toString()}");
  //                 final Item itemDetails = Item.fromMap(itemMap, itemId);

  //                 // comvert string to datetime 
  //                 final endRenting = parseDate(item['endRenting']);
  //                 print("-----------${item['totalFee'].runtimeType}------------");
  //                 return RentalItemCardWidget(item: itemDetails,orderDate: item['duration'], returnDate: (endRenting!), status: item['status'],totalFee: (item['totalFee'] as num?)?.toDouble() ?? 0.0,productId: realProductId,);
  //                 return const SizedBox.shrink();
  //               }).toList(),
  //         );
  //       },
  //     ),
  //   );
  // }

  // Widget _buildInRentingTabContent() {
  //   final Stream<List<Map<String, dynamic>>> inRentingItemsStream =
  //       RentingStatusDatabaseService().getInRentingItems(
  //         AppString.userSampleId,
  //       );

  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(16.0),
  //     child: StreamBuilder<List<Map<String, dynamic>>>(
  //       stream: inRentingItemsStream,
  //       builder: (context, asyncSnapshot) {
  //         if (asyncSnapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(child: CircularProgressIndicator());
  //         }

  //         if (asyncSnapshot.hasError) {
  //           return Center(child: Text('Error: ${asyncSnapshot.error}'));
  //         }

  //         final List<Map<String, dynamic>> inRentingItems =
  //             asyncSnapshot.data ?? [];

  //         if (inRentingItems.isEmpty) {
  //           return const Center(child: Text('No items currently in renting.'));
  //         }

  //         return Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: inRentingItems.map((order) {
  //             final itemMap = order['items'];
  //             final Item itemDetails = Item.fromMap(itemMap, order['id']);

  //                 final startDate = parseDate(order['startRenting']);
  //                 final endDate = parseDate(order['endRenting']);
  //                 return InrentingItemCardWidget(
  //                   item: itemDetails,
  //                   status: order['status'],
  //                   totalPrice: (order['totalFee'] as num?)?.toDouble() ?? 0.0,
  //                   startDate: startDate!,
  //                   endDate: endDate!,
  //                   returnMethods: order['deliveryOption'],
  //                 );

  //                 // Return an empty widget if the data is corrupted or missing the 'items' field
  //                 return const SizedBox.shrink();
  //               }).toList(),
  //         );
  //       },
  //     ),
  //   );
  // }

  // Widget _buildHistoryTabContent() {
  //   final Stream<List<Map<String, dynamic>>> historyItemsStream =
  //       RentingStatusDatabaseService().getHistoryItems(AppString.userSampleId);

  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(16.0),
  //     child: StreamBuilder<List<Map<String, dynamic>>>(
  //       stream: historyItemsStream,
  //       builder: (context, asyncSnapshot) {
  //         if (asyncSnapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(child: CircularProgressIndicator());
  //         }

  //         if (asyncSnapshot.hasError) {
  //           return Center(child: Text('Error: ${asyncSnapshot.error}'));
  //         }

  //         final List<Map<String, dynamic>> historyItems =
  //             asyncSnapshot.data ?? [];

  //         if (historyItems.isEmpty) {
  //           return const Center(child: Text('No order history found.'));
  //         }

  //         return Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children:
  //               historyItems.map((order) {
  //                 final itemMap = order['items'];
  //                 final Item itemDetails = Item.fromMap(itemMap, order['id']);
  //                 final endRenting = parseDate(order['endRenting']);
  //                 final startRenting = parseDate(order['startRenting']);
  //                 return HistoryItemCardWidgets(item: itemDetails, startDate: startRenting!, endDate: endRenting!, duration: order['duration'], status: order['status'], totalPrice: (order['totalFee'] as num?)?.toDouble() ?? 0.0, );
                
  //                 return const SizedBox.shrink();
  //               }).toList(),
  //         );
  //       },
  //     ),
  //   );
  // }
}
