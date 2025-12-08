import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/item.dart';
import '../../models/review.dart'; // Keep this if you use the Review model elsewhere
import '../reviewPage/review_page.dart'; // IMPORT ADDED to fix the undefined error

class ProductDetailsPage extends StatefulWidget {
  final Item item;

  const ProductDetailsPage({super.key, required this.item});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  DateTimeRange? _selectedDateRange;
  bool _isFavorite = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      saveText: "Select",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5C001F),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            datePickerTheme: DatePickerThemeData(
              rangePickerHeaderBackgroundColor: Colors.white,
              rangePickerHeaderForegroundColor: Colors.black,
              rangeSelectionBackgroundColor: const Color(
                0xFF5C001F,
              ).withOpacity(0.1),
              backgroundColor: Colors.white,
              headerBackgroundColor: Colors.white,
              headerForegroundColor: Colors.black,
              confirmButtonStyle: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(
                  const Color(0xFF5C001F),
                ),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDateRange = picked);
  }

  String _formatDateRange(DateTimeRange range) {
    final format = DateFormat('d MMM');
    return "${format.format(range.start)} - ${format.format(range.end)}";
  }

  @override
  Widget build(BuildContext context) {
    final imageCount = widget.item.imageUrls.length;
    double pricePerDay = widget.item.pricePerDay;
    double totalPrice = pricePerDay;
    String durationText = "per day";

    if (_selectedDateRange != null) {
      final int days = _selectedDateRange!.duration.inDays + 1;
      totalPrice = pricePerDay * days;
      durationText =
          "For $days days • ${_formatDateRange(_selectedDateRange!)}";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Product Detail",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "RM${totalPrice.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF5C001F),
                    ),
                  ),
                  Text(
                    durationText,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_selectedDateRange == null) {
                    _pickDateRange();
                  } else {
                    print("Renting product: ${widget.item.productName}");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C001F),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _selectedDateRange == null ? "Select Dates" : "Rent",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // UPDATED: Listen to the Product DOCUMENT, not a subcollection
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('product')
                .doc(widget.item.id)
                .snapshots(),
        builder: (context, snapshot) {
          List<dynamic> reviewsList = [];
          int reviewCount = 0;
          double averageRating = 0.0;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            // Extract the Array 'reviews' from the document
            if (data.containsKey('reviews')) {
              reviewsList = data['reviews'] as List<dynamic>;

              // Optional: Sort reviews by date descending (client-side sort)
              reviewsList.sort((a, b) {
                Timestamp? tA = a['date'] as Timestamp?;
                Timestamp? tB = b['date'] as Timestamp?;
                if (tA == null || tB == null) return 0;
                return tB.compareTo(tA);
              });
            }

            reviewCount = reviewsList.length;
            if (reviewCount > 0) {
              double sum = 0;
              for (var review in reviewsList) {
                sum += (review['star'] as num?)?.toDouble() ?? 0.0;
              }
              averageRating = sum / reviewCount;
            }
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Carousel
                SizedBox(
                  height: 250,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: imageCount,
                        onPageChanged:
                            (i) => setState(() => _currentImageIndex = i),
                        itemBuilder:
                            (_, i) => Container(
                              color: Colors.grey[100],
                              child: Image.network(
                                widget.item.imageUrls[i],
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[300],
                                        size: 60,
                                      ),
                                    ),
                              ),
                            ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(imageCount, (index) {
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _currentImageIndex == index
                                        ? const Color(0xFF5C001F)
                                        : Colors.white.withOpacity(0.7),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.item.productName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "RM ${widget.item.pricePerDay.toStringAsFixed(0)} per day",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Rating Badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC107),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "$reviewCount Reviews",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // --- DIVIDER ---
                      Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                        height: 30,
                      ),

                      // Owner
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(widget.item.ownerImage),
                        ),
                        title: Text(
                          widget.item.ownerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "2 months renting",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // --- DIVIDER ---
                      Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                        height: 30,
                      ),

                      // Description
                      const Text(
                        "Description Product",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.item.description,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- DIVIDER ---
                      Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                        height: 30,
                      ),

                      // Reviews Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color(0xFFFFC107),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${averageRating.toStringAsFixed(1)} - $reviewCount reviews",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          ReviewPage(itemId: widget.item.id),
                                ),
                              );
                            },
                            child: const Text(
                              "See all",
                              style: TextStyle(
                                color: Color(0xFF5C001F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Reviews Horizontal List
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
                          height: 170,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: reviewCount,
                            separatorBuilder:
                                (_, __) => const SizedBox(width: 15),
                            itemBuilder: (context, index) {
                              final data =
                                  reviewsList[index] as Map<String, dynamic>;
                              return SizedBox(
                                width: 300,
                                child: _buildReviewCard(data),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),

                      // --- DIVIDER ---
                      Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                        height: 30,
                      ),

                      // Availability
                      const Text(
                        "Availability",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickDateRange,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDateRange != null
                                    ? _formatDateRange(_selectedDateRange!)
                                    : "Add your rent dates for exact pricing",
                                style: TextStyle(
                                  color:
                                      _selectedDateRange != null
                                          ? Colors.black
                                          : Colors.grey[600],
                                  fontSize: 15,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- DIVIDER ---
                      Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                        height: 30,
                      ),

                      // Policy
                      const Text(
                        "Cancellation policy",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Free cancellation before – ${DateFormat('MMMM').format(DateTime.now().add(const Duration(days: 30)))}.",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Cancel before pick-up on – ${DateFormat('MMMM').format(DateTime.now().add(const Duration(days: 14)))} for a partial refund.",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                "Review this renter's full policy for details.",
                                style: TextStyle(
                                  color: Color(0xFF5C001F),
                                  decoration: TextDecoration.underline,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> data) {
    // USING CORRECT FIELD NAMES FROM DATABASE SCREENSHOT
    final String reviewerName = data['reviewerName'] ?? 'Guest';
    final String reviewerImage =
        data['reviewerImage'] ?? 'https://via.placeholder.com/150';
    final String reviewText = data['reviewText'] ?? '';
    final double rating = (data['star'] as num?)?.toDouble() ?? 0.0;

    DateTime date = DateTime.now();
    if (data['date'] != null && data['date'] is Timestamp) {
      date = (data['date'] as Timestamp).toDate();
    }

    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(reviewerImage),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 15),
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
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM yyyy').format(date),
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              reviewText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}