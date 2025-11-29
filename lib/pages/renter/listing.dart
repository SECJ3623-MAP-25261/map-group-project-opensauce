import 'package:easyrent/pages/rentee/profile_page.dart';
import 'package:flutter/material.dart';
import '../../models/renter_item.dart';
import '../../dbase/dummy.dart';
import '../../views/widgets/renter/renter_navbar.dart';
import 'add_item.dart';

class RenterListingPage extends StatefulWidget {
  const RenterListingPage({super.key});

  @override
  State<RenterListingPage> createState() => _RenterListingPageState();
}

class _RenterListingPageState extends State<RenterListingPage> {
  //  STATE VARIABLES
  int _selectedIndex = 1;

  List<RentalItem> _foundItems = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _foundItems = dummyRentalItems;
  }

  //  SEARCH LOGIC
  void _runFilter(String enteredKeyword) {
    List<RentalItem> results = [];
    if (enteredKeyword.isEmpty) {
      results = dummyRentalItems;
    } else {
      results =
          dummyRentalItems
              .where(
                (item) => item.name.toLowerCase().contains(
                  enteredKeyword.toLowerCase(),
                ),
              )
              .toList();
    }

    setState(() {
      _foundItems = results;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 4:
        // Profile Page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const RenteeprofilePage(),
            transitionDuration:
                Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showCenteredHint = _searchController.text.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // --- CUSTOM CENTERED SEARCH BAR ---
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (value) => _runFilter(value),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFEEEEEE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),

                      if (showCenteredHint)
                        const IgnorePointer(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, color: Colors.black54),
                              SizedBox(width: 8),
                              Text(
                                "Start your search",
                                style: TextStyle(color: Colors.black54),
                              ),
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

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:
                    _foundItems.isEmpty
                        ? const Center(
                          child: Text("No items found"),
                        )
                        : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          // USE _foundItems INSTEAD OF dummyRentalItems
                          itemCount: _foundItems.length,
                          itemBuilder: (context, index) {
                            final item = _foundItems[index];
                            return _buildItemCard(item);
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

  // HELPER WIDGET
  Widget _buildItemCard(RentalItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                item.imageUrls[0],
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (ctx, error, stack) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "RM ${item.pricePerDay.toStringAsFixed(0)} per day",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      item.rating.toString(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
