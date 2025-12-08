import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../models/item.dart'; 
import '../../services/notifier/listing_notifier.dart';
import 'edit_item.dart';

class RenterItemDetail extends StatefulWidget {
  final Item item; // <--- Changed to Item

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

  // --- NEW: REVIEW CARD WIDGET (Adapted from Teammate) ---
  Widget _buildReviewCard(dynamic review) {
    // Note: Since your Review model might only have 'star' and 'reviewText',
    // we use placeholders for Name/Image until the model is updated.
    final double rating = review.star;
    final String text = review.reviewText;
    final String name = "Guest User"; // Placeholder
    final String date = DateFormat('MMM yyyy').format(DateTime.now()); // Placeholder

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
              const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      date,
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
              text,
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
    final state = Provider.of<ListingNotifier>(context).state;
    
    // Find the latest version of this item (Stale Data Fix)
    final Item currentItem = state.myItems.firstWhere(
      (element) => element.id == widget.item.id,
      orElse: () => widget.item,
    );

    final double priceVal = currentItem.pricePerDay; // Already double in new model
    final List<String> displayImages = currentItem.imageUrls.isNotEmpty
        ? currentItem.imageUrls
        : [currentItem.imageUrl];

    // Real Rating Data
    final int reviewCount = currentItem.reviews.length;
    final String avgRating = currentItem.averageRating.toStringAsFixed(1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Product",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final String imagePath = displayImages[index];
                        bool isNetworkImage = imagePath.startsWith('http') || imagePath.startsWith('https');

                        if (isNetworkImage) {
                          return Image.network(
                            imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => 
                                const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                          );
                        } else {
                          return Image.file(
                            File(imagePath),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => 
                                const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                          );
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
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
                      ),
                    ),
                  ),

                if (_currentImageIndex < displayImages.length - 1)
                  Positioned(
                    right: 10,
                    child: GestureDetector(
                      onTap: () => _movePage(1),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black87),
                      ),
                    ),
                  ),
                
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${_currentImageIndex + 1} / ${displayImages.length}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // --- TITLE & PRICE SECTION ---
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
                  
                  // FIXED RATING ROW (Using Real Data)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        avgRating, // Real Average
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "($reviewCount Reviews)", // Real Count
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

            // --- DESCRIPTION SECTION ---
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

            // --- NEW: REVIEWS SECTION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Reviews",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
                ),
                if (reviewCount > 0)
                  TextButton(
                    onPressed: () {
                      // Navigate to full reviews list if you implement it
                    },
                    child: const Text("See All", style: TextStyle(color: Color(0xFF5C001F), fontWeight: FontWeight.bold)),
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
                    final review = currentItem.reviews[index];
                    return _buildReviewCard(review);
                  },
                ),
              ),

            const SizedBox(height: 40),

            // --- ACTION BUTTONS ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final existingNotifier = Provider.of<ListingNotifier>(context, listen: false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider.value(
                            value: existingNotifier,
                            child: RenterEditItem(item: currentItem),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF5C001F)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "EDIT",
                      style: TextStyle(color: Color(0xFF5C001F), fontWeight: FontWeight.bold),
                    ),
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
                    child: const Text(
                      "DELETE",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
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
}