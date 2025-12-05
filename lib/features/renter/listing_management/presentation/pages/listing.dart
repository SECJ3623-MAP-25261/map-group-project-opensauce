import 'package:easyrent/features/message/messages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notifier/listing_notifier.dart';
import '../../../renter_management/presentation/pages/renter_management_wrapper.dart';
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
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<ListingNotifier>(context, listen: false).loadMyItems(),
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const RenterManagementWrapper(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const MessagesApp(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
    }
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
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          Provider.of<ListingNotifier>(
                            context,
                            listen: false,
                          ).searchItems(value);
                        },
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
              child:
                  state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child:
                            state.myItems.isEmpty
                                ? const Center(child: Text("No items found"))
                                : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 220,
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
                                        final existingNotifier =
                                            Provider.of<ListingNotifier>(
                                              context,
                                              listen: false,
                                            );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    ChangeNotifierProvider.value(
                                                      value: existingNotifier,
                                                      child: RenterItemDetail(
                                                        item: item,
                                                      ),
                                                    ),
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
      bottomNavigationBar: RenterBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final existingNotifier = Provider.of<ListingNotifier>(
            context,
            listen: false,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChangeNotifierProvider.value(
                    value: existingNotifier,
                    child: const RenterAddItem(),
                  ),
            ),
          );
        },
        backgroundColor: const Color(0xFF5C001F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
