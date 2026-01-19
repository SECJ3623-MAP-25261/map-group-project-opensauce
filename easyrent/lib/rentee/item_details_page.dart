import 'package:easyrent/models/cart_model.dart';
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

  locationObject? _selectedLocation;

  void _onLocationSelected(
    locationObject selectedLocation,
  ) {
    print("============onLocationSelected called=============");
    setState(() {
      _selectedLocation = selectedLocation;
    });
    print("============selected location from itemDetailsPage=============: ${selectedLocation.locationName}");
  }
  
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF800000),
            colorScheme: const ColorScheme.light(primary: Color(0xFF800000)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  // --- WISHLIST LOGIC (Toggle) ---
  Future<void> _toggleWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login required")));
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(widget.docId);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Remove from wishlist
      await docRef.delete();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Removed from Wishlist")));
      }
    } else {
      // Add to wishlist
      await docRef.set({
        'itemId': widget.docId,
        'title': widget.itemData['title'],
        'price': widget.itemData['pricePerDay'],
        'image': (widget.itemData['images'] as List?)?.isNotEmpty == true
            ? widget.itemData['images'][0]
            : '',
        'description': widget.itemData['description'],
        'ownerId': widget.itemData['userId'] ?? widget.itemData['ownerId'],
        'addedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Added to Wishlist!")));
      }
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
      // 1. Handle Locations
      List<dynamic> locations = widget.itemData['pickupLocations'] ?? [];
      if (locations.isEmpty && widget.itemData['address'] != null) {
        locations = [widget.itemData['address']];
      }

      // 2. CRITICAL FIX: Hunt for the Owner ID
      // Checks 'ownerId' first (from API), then 'userId' (from old Firestore data)
      String realOwnerId =
          widget.itemData['ownerId'] ??
          widget.itemData['userId'] ??
          widget.itemData['owner_id'] ??
          'unknown';

      // Debugging: Print this to your console to be 100% sure
      print("DEBUG: Adding to cart. Found Owner ID: $realOwnerId");

      if (realOwnerId == 'unknown' || realOwnerId.isEmpty) {
        throw Exception("Cannot book item: Owner ID is missing.");
      }

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

            // --- THE FIX ---
            'ownerId': realOwnerId,

            // ----------------
            'pickupLocations': locations,
            'locationDetails': _selectedLocation != null
                ? [
                    {
                      'locationName': _selectedLocation!.locationName,
                      'latitude': _selectedLocation!.latitude,
                      'longitude': _selectedLocation!.longitude,
                    }
                  ]
                : [],
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
      print("Cart Error: $e");
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
    final user = FirebaseAuth.instance.currentUser;
    final data = widget.itemData;
    final List<dynamic> images = data['images'] ?? [];
   
    final String avgRating = data.containsKey('averageRating')
        ? "${data['averageRating'].toStringAsFixed(1)}"
        : "New";
    final String reviewCount = data.containsKey('reviewCount')
        ? "(${data['reviewCount']} reviews)"
        : "";

    return Scaffold(
      appBar: AppBar(
        title: Text(data['title']),
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
        actions: [
          // --- HEART ICON (Wishlist) ---
          if (user != null)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('wishlist')
                  .doc(widget.docId)
                  .snapshots(),
              builder: (context, snapshot) {
                bool isWishlisted = snapshot.hasData && snapshot.data!.exists;
                return IconButton(
                  icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? Colors.red : Colors.white,
                  ),
                  onPressed: _toggleWishlist,
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  // 2. HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "RM ${data['pricePerDay']}/day",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF800000),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // 3. RATING
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        "$avgRating / 5.0 ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        reviewCount,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 4. CATEGORY
                  Chip(label: Text(data['category'] ?? 'General')),
                  const SizedBox(height: 20),

                  // 5. OWNER SECTION (From Widgets File)
                  OwnerSection(
                    ownerId: data['ownerId'] ?? data['userId'] ?? '',
                  ),
                  const SizedBox(height: 20),

                  // 6. DESCRIPTION
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data['description'] ?? "No description.",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // 7. LOCATION (From Widgets File)
                  LocationSection(itemData: data,onLocationSelected:_onLocationSelected,selectedLocationName: _selectedLocation?.locationName,),

                  const SizedBox(height: 30),
                  const Divider(),

                  // 8. DATE SELECTION
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _selectedDateRange == null
                          ? "Select Dates"
                          : "${_selectedDateRange!.start.toString().split(' ')[0]} to ${_selectedDateRange!.end.toString().split(' ')[0]}",
                    ),
                    subtitle: Text(
                      _selectedDateRange == null
                          ? "Tap to choose"
                          : "${_selectedDateRange!.duration.inDays + 1} Days",
                    ),
                    trailing: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF800000),
                    ),
                    onTap: _pickDateRange,
                  ),

                  // 9. REVIEWS (From Widgets File)
                  ReviewsSection(itemId: widget.docId),
                ],
              ),
            ),
          ],
        ),
      ),

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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}