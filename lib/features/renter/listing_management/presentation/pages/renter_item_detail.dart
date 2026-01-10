import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ✅ Keep your Package Imports (Assuming 'easyrent' is your package name)
import 'package:easyrent/features/rentee/reviewPage/review_page.dart';
import 'package:easyrent/connectivity_service.dart';

// ✅ Analytics & Comparison Imports
import '../../models/rental_analytics.dart';
import '../../services/rental_service.dart';
import 'product_comparison_page.dart'; 

// ✅ Data & Notifier Imports
import '../../../../models/item.dart';
import '../../services/notifier/listing_notifier.dart';
import 'edit_item.dart';

// Riverpod alias
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;

class RenterItemDetail extends StatefulWidget {
  final Item item;

  const RenterItemDetail({super.key, required this.item});

  @override
  State<RenterItemDetail> createState() => _RenterItemDetailState();
}

class _RenterItemDetailState extends State<RenterItemDetail> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  final RentalService _rentalService = RentalService();
  late Future<RentalAnalytics> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch analytics for the current item on load
    _analyticsFuture = _rentalService.getRentalAnalytics(widget.item.id);
  }

  // ---------------------------------------------------------------------------
  // ✅ UPDATED: Dynamic Comparison Picker (Uses Real Database Data)
  // ---------------------------------------------------------------------------
  void _showComparisonPicker(BuildContext context) {
    // 1. Get the list of items from your ListingNotifier
    final listingNotifier = Provider.of<ListingNotifier>(context, listen: false);
    final myItems = listingNotifier.state.myItems;

    // 2. Filter: Exclude the current item so we don't compare it with itself
    final otherItems = myItems.where((item) => item.id != widget.item.id).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 450, // Height for the list
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Compare with...", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 15),
              const Text(
                "Select a product to compare performance:",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 15),
              
              // 3. Display the List
              if (otherItems.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      "No other products found to compare.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: otherItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = otherItems[index];

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.shade200)
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5C001F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF5C001F)),
                        ),
                        // Using 'name' from ItemEntity (as used in ListingNotifier)
                        title: Text(
                           item.productName, 
                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: const Text("Tap to compare stats", style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        onTap: () {
                          Navigator.pop(context); // Close the sheet
                          
                          // 4. Navigate to Comparison Page with REAL IDs
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductComparisonPage(
                                productId1: widget.item.id,          // Current Product
                                productName1: widget.item.productName,
                                productId2: item.id,           // Selected Product ID
                                productName2: item.productName,       // Selected Product Name
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  // ---------------------------------------------------------------------------

  Widget _buildImage(String imageUrl, {BoxFit fit = BoxFit.contain}) {
    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      );
    }
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: fit,
        errorBuilder:
            (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
      );
    }
    try {
      Uint8List bytes = base64Decode(imageUrl);
      return Image.memory(
        bytes,
        fit: fit,
        errorBuilder:
            (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
      );
    } catch (e) {
      return const Center(
        child: Icon(Icons.error, size: 50, color: Colors.red),
      );
    }
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: 100, 
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreen(BuildContext context, List<String> images, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.8),
        barrierDismissible: true,
        pageBuilder: (BuildContext context, _, __) {
          return FullScreenImageViewer(images: images, initialIndex: index);
        },
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Delete Item"),
            content: const Text(
              "Are you sure you want to delete this listing permanently?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<ListingNotifier>(
                    context,
                    listen: false,
                  ).deleteItem(widget.item.id);
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _movePage(int delta) {
    _pageController.animateToPage(
      _currentImageIndex + delta,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> data) {
    String dateStr = "";
    if (data['date'] != null && data['date'] is Timestamp) {
      dateStr = DateFormat(
        'dd MMM yyyy',
      ).format((data['date'] as Timestamp).toDate());
    }

    final double rating = (data['star'] as num?)?.toDouble() ?? 0.0;
    final String reviewerName = data['reviewerName'] ?? "Guest";
    final String reviewerImage =
        data['reviewerImage'] ?? "https://via.placeholder.com/150";
    final String reviewText = data['reviewText'] ?? "";

    return Container(
      width: 300,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(reviewerImage),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              reviewText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('product')
              .doc(widget.item.id)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data();
        if (data == null) {
          return const Scaffold(body: Center(child: Text("Item not found")));
        }

        final currentItem = Item.fromSnapshot(snapshot.data!);

        List<dynamic> reviewsList = [];
        if (data.containsKey('reviews')) {
          reviewsList = data['reviews'] as List<dynamic>;
          reviewsList.sort((a, b) {
            Timestamp? tA = a['date'] as Timestamp?;
            Timestamp? tB = b['date'] as Timestamp?;
            if (tA == null || tB == null) return 0;
            return tB.compareTo(tA);
          });
        }

        final int reviewCount = reviewsList.length;
        double calculatedRating = 0.0;
        if (reviewCount > 0) {
          double sum = 0;
          for (var r in reviewsList) {
            sum += (r['star'] as num?)?.toDouble() ?? 0.0;
          }
          calculatedRating = sum / reviewCount;
        }

        final double priceVal = currentItem.pricePerDay;
        final List<String> displayImages =
            currentItem.imageUrls.isNotEmpty
                ? currentItem.imageUrls
                : [currentItem.imageUrl];

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Product Detail",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            // ---------------------------------------------
            // ✅ ACTION BUTTON FOR COMPARISON
            // ---------------------------------------------
            actions: [
              IconButton(
                icon: const Icon(Icons.compare_arrows, color: Colors.black),
                tooltip: "Compare Analytics",
                onPressed: () {
                  _showComparisonPicker(context);
                },
              ),
              const SizedBox(width: 8), 
            ],
            // ---------------------------------------------
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: displayImages.length,
                          onPageChanged:
                              (index) =>
                                  setState(() => _currentImageIndex = index),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap:
                                  () => _openFullScreen(
                                    context,
                                    displayImages,
                                    index,
                                  ),
                              child: _buildImage(displayImages[index]),
                            );
                          },
                        ),
                      ),
                    ),
                    if (_currentImageIndex > 0)
                      Positioned(
                        left: 10,
                        child: GestureDetector(
                          onTap: () => _movePage(-1),
                          child: const CircleAvatar(
                            backgroundColor: Colors.white70,
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    if (_currentImageIndex < displayImages.length - 1)
                      Positioned(
                        right: 10,
                        child: GestureDetector(
                          onTap: () => _movePage(1),
                          child: const CircleAvatar(
                            backgroundColor: Colors.white70,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${_currentImageIndex + 1} / ${displayImages.length}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Center(
                  child: Column(
                    children: [
                      Text(
                        currentItem.productName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "RM ${priceVal.toStringAsFixed(0)} per day",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            calculatedRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "($reviewCount Reviews)",
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 24),

                const Text(
                  "Description Product",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  currentItem.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF667085),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),
                
                // Analytics Section
                FutureBuilder<RentalAnalytics>(
                  future: _analyticsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard("Total Earnings", "Error"),
                          _buildStatCard("Total Orders", "0"),
                          _buildStatCard("Total Duration", "0"),
                        ],
                      );
                    } else if (snapshot.hasData) {
                      final data = snapshot.data!;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatCard(
                            "Total\nEarnings",
                            "RM ${data.totalEarnings}",
                          ),
                          _buildStatCard(
                            "Total\nOrders",
                            "${data.totalOrders}",
                          ),
                          _buildStatCard(
                            "Total Renting\nDuration",
                            "${data.totalDuration} days",
                          ),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),

                const SizedBox(height: 24),
                const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Reviews",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ReviewPage(itemId: widget.item.id),
                          ),
                        );
                      },
                      child: const Text(
                        "See All",
                        style: TextStyle(
                          color: Color(0xFF5C001F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                if (reviewCount == 0)
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "No reviews yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: reviewCount,
                      separatorBuilder: (_, __) => const SizedBox(width: 15),
                      itemBuilder: (context, index) {
                        final reviewData =
                            reviewsList[index] as Map<String, dynamic>;
                        return _buildReviewCard(reviewData);
                      },
                    ),
                  ),

                const SizedBox(height: 40),

                rp.Consumer(
                  builder: (context, ref, child) {
                    final isOnline =
                        ref.watch(connectivityProvider).value ?? true;

                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                isOnline
                                    ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) =>
                                                  ChangeNotifierProvider.value(
                                                    value: Provider.of<
                                                      ListingNotifier
                                                    >(context, listen: false),
                                                    child: RenterEditItem(
                                                      item: currentItem,
                                                    ),
                                                  ),
                                        ),
                                      );
                                    }
                                    : null,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color:
                                    isOnline
                                        ? const Color(0xFF5C001F)
                                        : const Color(0xFFBDBDBD),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "EDIT",
                              style: TextStyle(
                                color:
                                    isOnline
                                        ? const Color(0xFF5C001F)
                                        : const Color(0xFFBDBDBD),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: isOnline ? _confirmDelete : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isOnline
                                      ? const Color(0xFF5C001F)
                                      : const Color(0xFFBDBDBD),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isOnline ? "DELETE" : "OFFLINE",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  void _movePage(int delta) {
    _controller.animateToPage(
      _currentIndex + delta,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildFullImage(String imageUrl) {
    if (imageUrl.isEmpty) return const SizedBox();
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl, fit: BoxFit.contain);
    }
    try {
      Uint8List bytes = base64Decode(imageUrl);
      return Image.memory(bytes, fit: BoxFit.contain);
    } catch (e) {
      return const Center(child: Icon(Icons.error, color: Colors.white));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Center(child: _buildFullImage(widget.images[index])),
                );
              },
            ),

            if (_currentIndex > 0)
              Positioned(
                left: 10,
                child: IconButton(
                  onPressed: () => _movePage(-1),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 30,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black26,
                    shape: const CircleBorder(),
                  ),
                ),
              ),

            if (_currentIndex < widget.images.length - 1)
              Positioned(
                right: 10,
                child: IconButton(
                  onPressed: () => _movePage(1),
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 30,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black26,
                    shape: const CircleBorder(),
                  ),
                ),
              ),

            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black26,
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}