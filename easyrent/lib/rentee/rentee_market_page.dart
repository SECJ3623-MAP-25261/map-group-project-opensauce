import 'package:flutter/material.dart';
import '../services/rentee_service.dart';
import '../services/notification_service.dart';
import '../models/item_model.dart';
import '../widgets/rentee_item_card.dart';
import 'cart_page.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/offline_queue_service.dart';

class RenteeMarketPage extends StatefulWidget {
  const RenteeMarketPage({super.key});

  @override
  State<RenteeMarketPage> createState() => _RenteeMarketPageState();
}

class _RenteeMarketPageState extends State<RenteeMarketPage> {
  final RenteeService _renteeService = RenteeService();
  final TextEditingController _searchController = TextEditingController();

  StreamSubscription? _internetSubscription;

  // Futures to hold API data
  late Future<List<Map<String, dynamic>>> _mostRentedFuture;
  late Future<List<Map<String, dynamic>>> _newArrivalsFuture;

  @override
  void initState() {
    super.initState();
    // 1. Initialize Notifications (as discussed before)
    NotificationService().initNotifications();

    // 2. Load the Data from Cloud Functions
    _loadData();

    _internetSubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      if (result != ConnectivityResult.none) {
        // Internet is back! Run the sync.
        OfflineQueueService().syncPendingItems().then((_) {
          // Optional: Show a toast like "Offline items uploaded!"
          print("Sync complete");
        });
      }
    });
  }

  @override
  void dispose() {
    _internetSubscription?.cancel(); // Don't forget this!
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _mostRentedFuture = _renteeService.fetchMostRented();
      _newArrivalsFuture = _renteeService.fetchNewItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: const Color(0xFF800000),
        elevation: 0,
        title: const Text(
          "EasyRent Market",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
        ],
      ),

      // --- BODY ---
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: const Color(0xFF800000),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SEARCH BAR
              _buildSearchBar(),

              // 2. SECTION: MOST RENTED (Horizontal)
              _buildSectionTitle("Most Popular"),
              _buildHorizontalList(_mostRentedFuture),

              // 3. SECTION: NEW ARRIVALS (Vertical Grid)
              _buildSectionTitle("New Arrivals"),
              _buildVerticalGrid(_newArrivalsFuture),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFF800000),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search items...",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onSubmitted: (val) {
          // You can implement search logic here if needed,
          // or just filter the existing list.
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Horizontal List for "Most Rented"
  Widget _buildHorizontalList(Future<List<Map<String, dynamic>>> future) {
    return SizedBox(
      height: 250, // Height of the card container
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading items"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No popular items yet"));
          }

          final items = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (c, i) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final data = items[index];
              // 1. Convert API Map to ItemModel
              // (Category is preserved inside this model)
              final itemModel = ItemModel.fromMap(data);

              return SizedBox(
                width: 160,
                child: RenteeItemCard(item: itemModel),
              );
            },
          );
        },
      ),
    );
  }

  // Vertical Grid for "New Arrivals"
  Widget _buildVerticalGrid(Future<List<Map<String, dynamic>>> future) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No new items found"),
            ),
          );
        }

        final items = snapshot.data!;

        // Filter by Search Text if user typed something
        final filteredItems = items.where((item) {
          final title = (item['title'] ?? '').toString().toLowerCase();
          return title.contains(_searchController.text.toLowerCase());
        }).toList();

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true, // IMPORTANT for being inside ScrollView
          physics: const NeverScrollableScrollPhysics(), // IMPORTANT
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7, // Adjust card height
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final data = filteredItems[index];
            final itemModel = ItemModel.fromMap(data);
            return RenteeItemCard(item: itemModel);
          },
        );
      },
    );
  }
}
