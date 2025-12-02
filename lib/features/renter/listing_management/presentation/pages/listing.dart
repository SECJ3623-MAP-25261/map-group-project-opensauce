import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/notifier/listing_notifier.dart';
import '../../../renter_management/domain/entities/item_entity.dart';

import '../widgets/listing_item_card.dart';
import 'add_item.dart';
import 'renter_item_detail.dart';
import '../widgets/renter_navbar.dart';

class RenterListingPage extends StatefulWidget {
  const RenterListingPage({super.key});

  @override
  State<RenterListingPage> createState() => _RenterListingPageState();
}

class _RenterListingPageState extends State<RenterListingPage> {
  int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<ListingNotifier>(context, listen: false).loadMyItems()
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigation logic...
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ListingNotifier>(context);
    final state = notifier.state;
    
    final bool showCenteredHint = _searchController.text.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Search Bar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          // TODO: Add search logic to Notifier later
                        },
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFEEEEEE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      if (showCenteredHint)
                        const IgnorePointer(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, color: Colors.black54),
                              SizedBox(width: 8),
                              Text("Start your search", style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Your item",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // --- GRID VIEW (Connected to Notifier) ---
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: state.myItems.isEmpty
                          ? const Center(child: Text("No items found"))
                          : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: state.myItems.length,
                              itemBuilder: (context, index) {
                                final item = state.myItems[index];
                                return ListingItemCard(
                                  item: item,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        // We will fix Detail Page next to accept ItemEntity
                                        builder: (context) => RenterItemDetail(item: item), 
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),

      // NAVBAR
      bottomNavigationBar: RenterBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),

      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RenterAddItem()),
          );
        },
        backgroundColor: const Color(0xFF5C001F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}