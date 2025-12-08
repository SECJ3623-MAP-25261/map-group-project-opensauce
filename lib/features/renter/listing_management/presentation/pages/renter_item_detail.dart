import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../models/item.dart'; 
import '../../services/notifier/listing_notifier.dart';
import 'edit_item.dart';

class RenterItemDetail extends StatefulWidget {
  final Item item;

  const RenterItemDetail({super.key, required this.item});

  @override
  State<RenterItemDetail> createState() => _RenterItemDetailState();
}

class _RenterItemDetailState extends State<RenterItemDetail> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Are you sure you want to delete this listing permanently?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ListingNotifier>(context, listen: false)
                  .deleteItem(widget.item.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
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

  // --- HELPER: Review Card (Matches Teammate's Style) ---
  Widget _buildReviewCard(Map<String, dynamic> data) {
    String dateStr = "";
    if (data['date'] != null && data['date'] is Timestamp) {
      dateStr = DateFormat('dd MMM yyyy').format((data['date'] as Timestamp).toDate());
    }
    
    final double rating = (data['star'] as num?)?.toDouble() ?? 0.0;
    final String reviewerName = data['reviewerName'] ?? "Guest";
    final String reviewerImage = data['reviewerImage'] ?? "https://via.placeholder.com/150";
    final String reviewText = data['reviewText'] ?? "";

    return Container(
      width: 300, // Fixed width for horizontal scrolling
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              reviewText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // USE STREAMBUILDER for Live Data (Fixes "Not Showing" issue)
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('product').doc(widget.item.id).snapshots(),
      builder: (context, snapshot) {
        
        // 1. Handle Loading/Error
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        // 2. Parse Live Data
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) return const Scaffold(body: Center(child: Text("Item not found")));

        // Create Item object from live data
        final currentItem = Item.fromSnapshot(snapshot.data!);

        // 3. Process Reviews
        List<dynamic> reviewsList = [];
        if (data.containsKey('reviews')) {
          reviewsList = data['reviews'] as List<dynamic>;
          // Sort by date (Newest first)
          reviewsList.sort((a, b) {
            Timestamp? tA = a['date'] as Timestamp?;
            Timestamp? tB = b['date'] as Timestamp?;
            if (tA == null || tB == null) return 0;
            return tB.compareTo(tA);
          });
        }
        
        // 4. Calculate Rating Live
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
        final List<String> displayImages = currentItem.imageUrls.isNotEmpty
            ? currentItem.imageUrls
            : [currentItem.imageUrl];

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("Detail Product", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // --- IMAGE CAROUSEL ---
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
                          onPageChanged: (index) => setState(() => _currentImageIndex = index),
                          itemBuilder: (context, index) {
                            final String imagePath = displayImages[index];
                            bool isNetwork = imagePath.startsWith('http');
                            if (isNetwork) {
                              return Image.network(imagePath, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Icon(Icons.broken_image));
                            } else {
                              return Image.file(File(imagePath), fit: BoxFit.contain);
                            }
                          },
                        ),
                      ),
                    ),
                    if (_currentImageIndex > 0)
                      Positioned(
                        left: 10,
                        child: GestureDetector(
                          onTap: () => _movePage(-1),
                          child: const CircleAvatar(backgroundColor: Colors.white70, child: Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black)),
                        ),
                      ),
                    if (_currentImageIndex < displayImages.length - 1)
                      Positioned(
                        right: 10,
                        child: GestureDetector(
                          onTap: () => _movePage(1),
                          child: const CircleAvatar(backgroundColor: Colors.white70, child: Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black)),
                        ),
                      ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
                        child: Text("${_currentImageIndex + 1} / ${displayImages.length}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),

                // --- INFO HEADER (LIVE DATA) ---
                Center(
                  child: Column(
                    children: [
                      Text(
                        currentItem.productName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "RM ${priceVal.toStringAsFixed(0)} per day",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          // Live Rating
                          Text(
                            calculatedRating.toStringAsFixed(1), 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          // Live Count
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

                // --- DESCRIPTION ---
                const Text(
                  "Description Product",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
                ),
                const SizedBox(height: 12),
                Text(
                  currentItem.description,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF667085), height: 1.5),
                ),
                
                const SizedBox(height: 24),
                const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 24),

                // --- REVIEWS SECTION ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                    if (reviewCount > 0)
                      const Text("See All", style: TextStyle(color: Color(0xFF5C001F), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),

                if (reviewCount == 0)
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text("No reviews yet", style: TextStyle(color: Colors.grey))),
                  )
                else
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: reviewCount,
                      separatorBuilder: (_, __) => const SizedBox(width: 15),
                      itemBuilder: (context, index) {
                        final reviewData = reviewsList[index] as Map<String, dynamic>;
                        return _buildReviewCard(reviewData);
                      },
                    ),
                  ),

                const SizedBox(height: 40),

                // --- BUTTONS ---
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Pass Live Item to Edit
                          Navigator.push(context, MaterialPageRoute(builder: (_) => 
                            ChangeNotifierProvider.value(
                              value: Provider.of<ListingNotifier>(context, listen: false),
                              child: RenterEditItem(item: currentItem),
                            )
                          ));
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF5C001F)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("EDIT", style: TextStyle(color: Color(0xFF5C001F), fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _confirmDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C001F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text("DELETE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }
    );
  }
}