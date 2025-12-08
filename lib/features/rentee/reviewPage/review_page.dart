import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReviewPage extends StatefulWidget {
  final String itemId;

  const ReviewPage({super.key, required this.itemId});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  // Reference to the product document
  DocumentReference get _productRef =>
      FirebaseFirestore.instance.collection('product').doc(widget.itemId);

  void _showAddReviewDialog() {
    double selectedRating = 0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Write a Review"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("How was your experience?"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed:
                            () => setState(() => selectedRating = index + 1.0),
                        icon: Icon(
                          index < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: const Color(0xFFFFC107),
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: "Share your thoughts...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedRating > 0 &&
                        commentController.text.isNotEmpty) {
                      // Construct the review map EXACTLY matching your database structure
                      final newReview = {
                        'reviewerName': 'Guest User',
                        'reviewerImage': 'https://via.placeholder.com/150',
                        'star': selectedRating,
                        'reviewText': commentController.text,
                        'date':
                            Timestamp.now(), // Use Timestamp to match DB type
                      };

                      // UPDATE THE ARRAY IN FIRESTORE
                      await _productRef.update({
                        'reviews': FieldValue.arrayUnion([newReview]),
                      });

                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C001F),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Deleting from an array requires the exact object or reading/filtering/updating.
  // For simplicity with your structure, we will update the list by index if possible,
  // but since we don't have stable IDs inside the array, we'll omit the delete button for now
  // or you would need to implement a "read -> filter -> update" logic.

  @override
  Widget build(BuildContext context) {
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
          "Review Product",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _showAddReviewDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C001F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Add Review",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _productRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          List<dynamic> reviewsList = [];

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            if (data.containsKey('reviews')) {
              reviewsList = data['reviews'] as List<dynamic>;

              // Sort by date desc
              reviewsList.sort((a, b) {
                Timestamp? tA = a['date'] as Timestamp?;
                Timestamp? tB = b['date'] as Timestamp?;
                if (tA == null || tB == null) return 0;
                return tB.compareTo(tA);
              });
            }
          }

          final int totalReviews = reviewsList.length;
          double averageRating = 0.0;
          final Map<int, int> starCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

          if (totalReviews > 0) {
            double sum = 0.0;
            for (var review in reviewsList) {
              final double rating = (review['star'] as num?)?.toDouble() ?? 0.0;
              sum += rating;
              int star = rating.round().clamp(1, 5);
              starCounts[star] = (starCounts[star] ?? 0) + 1;
            }
            averageRating = sum / totalReviews;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 6),
                                child: Text(
                                  "/5",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "$totalReviews Reviews",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildRatingBar(5, starCounts[5]!, totalReviews),
                          _buildRatingBar(4, starCounts[4]!, totalReviews),
                          _buildRatingBar(3, starCounts[3]!, totalReviews),
                          _buildRatingBar(2, starCounts[2]!, totalReviews),
                          _buildRatingBar(1, starCounts[1]!, totalReviews),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                if (totalReviews == 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      "No reviews yet. Be the first!",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviewsList.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final data = reviewsList[index] as Map<String, dynamic>;
                      return _buildReviewListCard(data);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewListCard(Map<String, dynamic> data) {
    String dateStr = "";
    if (data['date'] != null && data['date'] is Timestamp) {
      dateStr = DateFormat(
        'dd MMM yyyy',
      ).format((data['date'] as Timestamp).toDate());
    }
    final double rating = (data['star'] as num?)?.toDouble() ?? 0.0;

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
                backgroundImage: NetworkImage(data['reviewerImage'] ?? ""),
                radius: 20,
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['reviewerName'] ?? "Guest",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
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
          Text(
            data['reviewText'] ?? "",
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, int count, int total) {
    double percentage = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                size: 12,
                color:
                    index < star ? const Color(0xFFFFC107) : Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFFC107),
                ),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 20,
            child: Text(
              "$count",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
