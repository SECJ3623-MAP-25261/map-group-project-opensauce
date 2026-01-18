import 'dart:async'; // Needed for StreamSubscription
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async'; // For StreamSubscription
import 'item_details_widgets.dart'; // Ensure this file exists from previous steps

class ItemDetailsPage extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final String docId;

  const ItemDetailsPage({
    super.key,
    required this.itemData,
    required this.docId,
  });

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  DateTimeRange? _selectedDateRange;
  bool _isAddingToCart = false;

  // Connectivity
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _isConnected = true; 

  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
     final hasConnection = result != ConnectivityResult.none;
     if (hasConnection != _isConnected) {
       setState(() {
         _isConnected = hasConnection;
       });
     }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  // --- CALCULATION ---
  num get _totalPrice {
    if (_selectedDateRange == null) return 0.0;
    final duration = _selectedDateRange!.duration.inDays + 1;
    final pricePerDay =
        num.tryParse(widget.itemData['pricePerDay'].toString()) ?? 0.0;
    return duration * pricePerDay;
  }

  // --- DATE PICKER ---
  void _pickDateRange() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  // --- ADD TO CART LOGIC ---
  Future<void> _addToCart() async {
    if (!_isConnected) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You are offline. Cannot add to cart.")),
      );
      return;
    }
    
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select rental dates first")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }

    setState(() => _isAddingToCart = true);

    try {
      List<dynamic> locations = widget.itemData['pickupLocations'] ?? [];
      if (locations.isEmpty && widget.itemData['address'] != null) {
        locations = [widget.itemData['address']];
      }

      // Check Owner ID (The fix we did earlier)
      String realOwnerId =
          widget.itemData['ownerId'] ??
          widget.itemData['userId'] ??
          widget.itemData['owner_id'] ??
          'unknown';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .add({
            'itemId': widget.docId,
            'itemTitle': widget.itemData['title'],
            'itemImage':
                (widget.itemData['images'] as List?)?.isNotEmpty == true
                ? widget.itemData['images'][0]
                : '',
            'pricePerDay': widget.itemData['pricePerDay'],
            'ownerId': realOwnerId,
            'pickupLocations': locations,
            'startDate': Timestamp.fromDate(_selectedDateRange!.start),
            'endDate': Timestamp.fromDate(_selectedDateRange!.end),
            'addedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Added to Cart Successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Details"),
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. IMAGE CAROUSEL
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[200],
              child: images.isNotEmpty
                  ? Stack(
                      children: [
                        PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                        ),
                        // Dots Indicator
                        if (images.length > 1)
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: images.asMap().entries.map((entry) {
                                return Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black)
                                            .withOpacity(
                                              _currentImageIndex == entry.key
                                                  ? 0.9
                                                  : 0.4,
                                            ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    )
                  : const Center(
                      child: Icon(
                        Icons.inventory_2,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. TITLE & PRICE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.itemData['title'] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "RM ${widget.itemData['pricePerDay']}/day",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF800000),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.itemData['description'] ??
                        "No description provided.",
                  ),

                  const SizedBox(height: 20),
                  const Divider(),

                  // 4. OWNER INFO
                  OwnerSection(
                    ownerId:
                        widget.itemData['ownerId'] ??
                        widget.itemData['userId'] ??
                        '',
                  ),

                  const SizedBox(height: 20),

                  // 5. DATE PICKER FIELD
                  const Text(
                    "Select Dates",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF800000),
                    ),
                    title: Text(
                      _selectedDateRange == null
                          ? "Tap to select dates"
                          : "${_selectedDateRange!.start.toString().split(' ')[0]} - ${_selectedDateRange!.end.toString().split(' ')[0]}",
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _pickDateRange,
                  ),

                  // 6. REVIEWS
                  ReviewsSection(itemId: widget.docId),
                ],
              ),
            ),
          ],
        ),
      ),

      // --- BOTTOM BAR (Button Logic) ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: (_isAddingToCart || !_isConnected) ? null : _addToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isConnected ? const Color(0xFF800000) : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: _isAddingToCart
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    !_isConnected 
                        ? "Offline" 
                        : (_selectedDateRange == null
                            ? "Check Availability"
                            : "Add to Cart (RM ${_totalPrice.toStringAsFixed(2)})"),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white, // Text color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
