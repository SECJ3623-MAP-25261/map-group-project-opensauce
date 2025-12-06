import 'package:easyrent/features/rentee/checkout/presentation/pages/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/dummy_data.dart';
import '../reviewPage/review_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool isFavorite = false;

  // IMAGE CAROUSEL
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  // DATES & PRICING
  DateTimeRange? _selectedDateRange;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double _getPricePerDay() {
    try {
      final String priceStr = widget.product['price'] ?? "0";
      final String cleanStr = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleanStr) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // pick date range
  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      saveText: "Save",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5C001F),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
              secondary: Color(0xFF5C001F),
            ),
            datePickerTheme: DatePickerThemeData(
              rangePickerHeaderBackgroundColor: Colors.white,
              rangePickerHeaderForegroundColor: Colors.black,
              rangeSelectionBackgroundColor: const Color(
                0xFF5C001F,
              ).withValues(alpha: 0.1),
              rangePickerSurfaceTintColor: Colors.transparent,
              backgroundColor: Colors.white,
              headerForegroundColor: Colors.black,
              headerBackgroundColor: Colors.white,
              confirmButtonStyle: ButtonStyle(
                textStyle: WidgetStateProperty.all(
                  const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5C001F),
                  ),
                ),
                foregroundColor: WidgetStateProperty.all(
                  const Color(0xFF5C001F),
                ),
              ),
              cancelButtonStyle: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.black),
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

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  // format date using intl
  String _formatDateRange(DateTimeRange range) {
    final startFormat = DateFormat('d');
    final fullFormat = DateFormat('d MMM');

    // If same month
    if (range.start.month == range.end.month &&
        range.start.year == range.end.year) {
      return "${startFormat.format(range.start)} - ${fullFormat.format(range.end)}";
    }
    // If different month
    else {
      return "${fullFormat.format(range.start)} - ${fullFormat.format(range.end)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final renter =
        widget.product['renter'] ??
        {
          'name': 'EasyRent User',
          'image': 'https://i.pravatar.cc/150?img=12',
          'period': 'New Member',
        };
    final description =
        widget.product['description'] ?? "No description provided.";
    final int actualReviewCount = dummyReviews.length;

    final List<dynamic> galleryImages =
        widget.product['images'] ?? [widget.product['image']];
    final int imageCount = galleryImages.length;

    // CALCULATIONS FOR BOTTOM BAR
    double pricePerDay = _getPricePerDay();
    double totalPrice = pricePerDay;
    String durationText = "per day";

    if (_selectedDateRange != null) {
      final int days = _selectedDateRange!.duration.inDays + 1; // inclusive
      totalPrice = pricePerDay * days;
      durationText =
          "For $days days • ${_formatDateRange(_selectedDateRange!)}";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Product Detail",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -1),
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
                    ),
                  ),
                  Text(
                    durationText,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_selectedDateRange == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select rent dates first"),
                      ),
                    );
                    _pickDateRange();
                  } else {
                    // Proceed to checkout logic
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return CheckoutPage();
                    },));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C001F),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 70,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Rent",
                  style: TextStyle(
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

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SWIPEABLE IMAGE
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  color: const Color(0xFFF9F9F9),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: imageCount,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Center(
                        child: Image.network(
                          galleryImages[index],
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (ctx, err, stack) => const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                        ),
                      );
                    },
                  ),
                ),

                if (_currentImageIndex > 0)
                  Positioned(
                    left: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.7),
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 18,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                if (_currentImageIndex < imageCount - 1)
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.7),
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${_currentImageIndex + 1} / $imageCount",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          widget.product['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.product['price'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFC107),
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "${widget.product['rating']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              "•",
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "$actualReviewCount Reviews",
                              style: const TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(renter['image']),
                        radius: 20,
                        onBackgroundImageError: (_, __) {},
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            renter['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            renter['period'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),
                  const Text(
                    "Description Product",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], height: 1.5),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFC107),
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.product['rating']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "• $actualReviewCount reviews",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const ReviewListWidget(),
                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReviewPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF5C001F)),
                        backgroundColor: const Color(0xFF5C001F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "See All Review",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      "Availability",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _selectedDateRange != null
                          ? _formatDateRange(_selectedDateRange!)
                          : "Add your rent dates for exact pricing",
                      style: TextStyle(
                        color:
                            _selectedDateRange != null
                                ? const Color(0xFF5C001F)
                                : Colors.grey[600],
                        fontWeight:
                            _selectedDateRange != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: _pickDateRange, // Triggers the Date Picker
                  ),

                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      "Cancellation policy",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("Free cancellation before November."),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewListWidget extends StatelessWidget {
  const ReviewListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: dummyReviews.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          return ReviewCard(review: dummyReviews[index]);
        },
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            spreadRadius: 1,
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
                backgroundImage: NetworkImage(review['image']),
                radius: 16,
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      review['date'],
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                  const SizedBox(width: 2),
                  Text(
                    "${review['rating']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              review['comment'],
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
