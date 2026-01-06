import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/core/utils/parse_date.dart';
import 'package:easyrent/features/models/item.dart';
import 'package:easyrent/features/rentee/presentation/widgets/rentee_bottom_navbar.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/history_item_card_widgets.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/inRenting_item_card_widget.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/ordering_item_card_widget.dart';
import 'package:easyrent/features/rentee/renting_status/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RentingStatusPage extends ConsumerStatefulWidget {
  const RentingStatusPage({super.key});

  @override
  ConsumerState<RentingStatusPage> createState() => _RentingStatusPageState();
}

class _RentingStatusPageState extends ConsumerState<RentingStatusPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryRed,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorWeight: 2,
          tabs: const [
            Tab(text: 'Ordering'),
            Tab(text: 'In Renting'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderingTabContent(),
          _buildInRentingTabContent(),
          _buildHistoryTabContent(),
        ],
      ),
      bottomNavigationBar: const RenteeBottomNavBar(),
    );
  }

  Widget _buildOrderingTabContent() {
    final Stream<List<Map<String, dynamic>>> orderingItemsStream =
        RentingStatusDatabaseService().getOrderingItems(AppString.userSampleId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: orderingItemsStream,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (asyncSnapshot.hasError) {
            return Center(child: Text('Error: ${asyncSnapshot.error}'));
          }

          final List<Map<String, dynamic>> orderingItems =
              asyncSnapshot.data ?? [];

          if (orderingItems.isEmpty) {
            return const Center(child: Text('No ordering items found.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                orderingItems.map((item) {
                  
                  final Map<String, dynamic>? itemMap = item['items'] as Map<String, dynamic>?;                  // print("the 
                  if (itemMap == null) {
                    return const SizedBox.shrink();
                  }
                  final String itemId = item['id']?.toString() ?? '';
                  final Item itemDetails = Item.fromMap(itemMap, itemId);

                  // comvert string to datetime 
                  final endRenting = parseDate(item['endRenting']);
                  print("-----------${item['totalFee'].runtimeType}------------");
                  return RentalItemCardWidget(item: itemDetails,orderDate: item['duration'], returnDate: (endRenting!), status: item['status'],totalFee: (item['totalFee'] as num?)?.toDouble() ?? 0.0,);
                  return const SizedBox.shrink();
                }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildInRentingTabContent() {
    final Stream<List<Map<String, dynamic>>> inRentingItemsStream =
        RentingStatusDatabaseService().getInRentingItems(
          AppString.userSampleId,
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: inRentingItemsStream,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (asyncSnapshot.hasError) {
            return Center(child: Text('Error: ${asyncSnapshot.error}'));
          }

          final List<Map<String, dynamic>> inRentingItems =
              asyncSnapshot.data ?? [];

          if (inRentingItems.isEmpty) {
            return const Center(child: Text('No items currently in renting.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: inRentingItems.map((order) {
              final itemMap = order['items'];
              final Item itemDetails = Item.fromMap(itemMap, order['id']);

                  final startDate = parseDate(order['startRenting']);
                  final endDate = parseDate(order['endRenting']);
                  return InrentingItemCardWidget(
                    item: itemDetails,
                    status: order['status'],
                    totalPrice: (order['totalFee'] as num?)?.toDouble() ?? 0.0,
                    startDate: startDate!,
                    endDate: endDate!,
                    returnMethods: order['deliveryOption'],
                  );

                  // Return an empty widget if the data is corrupted or missing the 'items' field
                  return const SizedBox.shrink();
                }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTabContent() {
    final Stream<List<Map<String, dynamic>>> historyItemsStream =
        RentingStatusDatabaseService().getHistoryItems(AppString.userSampleId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: historyItemsStream,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (asyncSnapshot.hasError) {
            return Center(child: Text('Error: ${asyncSnapshot.error}'));
          }

          final List<Map<String, dynamic>> historyItems =
              asyncSnapshot.data ?? [];

          if (historyItems.isEmpty) {
            return const Center(child: Text('No order history found.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                historyItems.map((order) {
                  final itemMap = order['items'];
                  final Item itemDetails = Item.fromMap(itemMap, order['id']);
                  final endRenting = parseDate(order['endRenting']);
                  final startRenting = parseDate(order['startRenting']);
                  return HistoryItemCardWidgets(item: itemDetails, startDate: startRenting!, endDate: endRenting!, duration: order['duration'], status: order['status'], totalPrice: (order['totalFee'] as num?)?.toDouble() ?? 0.0, );
                
                  return const SizedBox.shrink();
                }).toList(),
          );
        },
      ),
    );
  }
}