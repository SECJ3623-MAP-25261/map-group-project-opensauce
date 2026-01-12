import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/rentee_service.dart';
import '../models/item_model.dart'; // Import Model
import '../widgets/rentee_item_card.dart'; // Import Widget
import 'cart_page.dart';
import '../services/notification_service.dart';

class RenteeMarketPage extends StatefulWidget {
  const RenteeMarketPage({super.key});

  @override
  State<RenteeMarketPage> createState() => _RenteeMarketPageState();
}

class _RenteeMarketPageState extends State<RenteeMarketPage> {
  final RenteeService _renteeService = RenteeService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";
  String _selectedCategory = "All";
  final List<String> _categories = [
    "All",
    "Electronics",
    "Tools",
    "Sports",
    "Camping",
    "Party",
    "Others",
  ];

  @override
  void initState() {
    super.initState();
    // This triggers the permission popup & saves the token
    NotificationService().initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. HEADER
          Container(
            color: const Color(0xFF800000),
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        "Find what you need",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // CART ICON
                    StreamBuilder<QuerySnapshot>(
                      stream: user != null
                          ? FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('cart')
                                .snapshots()
                          : null,
                      builder: (context, snapshot) {
                        bool hasItems =
                            snapshot.hasData && snapshot.data!.docs.isNotEmpty;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CartPage(),
                                ),
                              ),
                            ),
                            if (hasItems)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 10,
                                    minHeight: 10,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // SEARCH BAR
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {
                    _searchQuery = val;
                    _selectedCategory = "All";
                  }),
                  decoration: InputDecoration(
                    hintText: "Search drill, camera, tent...",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ],
            ),
          ),

          // 2. CATEGORY SELECTOR
          if (_searchQuery.isEmpty)
            SizedBox(
              height: 60,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: FilterChip(
                      label: Text(cat),
                      selected: _selectedCategory == cat,
                      selectedColor: const Color(0xFF800000).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF800000),
                      onSelected: (bool selected) =>
                          setState(() => _selectedCategory = cat),
                    ),
                  );
                },
              ),
            ),

          // 3. ITEM LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text("Error: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());

                var docs = snapshot.data!.docs;

                // SMART SEARCH FILTER (Client Side)
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final title = (doc.data() as Map<String, dynamic>)['title']
                        .toString()
                        .toLowerCase();
                    return title.contains(_searchQuery.toLowerCase());
                  }).toList();
                }

                if (docs.isEmpty)
                  return const Center(child: Text("No items found"));

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    // CONVERT TO MODEL
                    final item = ItemModel.fromSnapshot(docs[index]);

                    // USE NEW WIDGET
                    return RenteeItemCard(item: item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getStream() {
    if (_searchQuery.isNotEmpty || _selectedCategory == "All") {
      return _renteeService.getNewArrivals();
    } else {
      return _renteeService.getItemsByCategory(_selectedCategory);
    }
  }
}
