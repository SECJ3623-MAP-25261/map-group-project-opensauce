import 'package:easyrent/models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- 1. OWNER SECTION WIDGET ---
class OwnerSection extends StatelessWidget {
  final String ownerId;

  const OwnerSection({super.key, required this.ownerId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(); // Hide if loading

        var user = snapshot.data!.data() as Map<String, dynamic>?;
        String name = user?['displayName'] ?? "Unknown Owner";
        String image = user?['profileImage'] ?? "";

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFF800000),
                backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                child: image.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Owned by",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- 2. LOCATION CHIPS WIDGET ---
class LocationSection extends StatelessWidget {
  final Map<String, dynamic> itemData;
  final Function(locationObject) onLocationSelected;
  // ADD THIS: Keep track of which one is selected
  final String? selectedLocationName; 

  const LocationSection({
    super.key,
    required this.itemData,
    required this.onLocationSelected,
    this.selectedLocationName, // Initialize it
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> rawLocations = itemData['locationDetails'] is List
        ? itemData['locationDetails']
        : [];

    final List<locationObject> locations = rawLocations.map((loc) {
      return locationObject.fromMap(loc as Map<String, dynamic>);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey),
            SizedBox(width: 5),
            Text(
              "Pickup Location(s)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: locations.map((loc) {
            // CHECK: Is this specific chip the one selected?
            final bool isSelected = selectedLocationName == loc.locationName;

            return ActionChip(
              avatar: Icon(
                Icons.map, 
                size: 14, 
                color: isSelected ? Colors.white : const Color(0xFF800000)
              ),
              label: Text(
                loc.locationName,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              // CHANGE COLOR based on selection
              backgroundColor: isSelected ? const Color(0xFF800000) : Colors.grey[100],
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? const Color(0xFF800000) : Colors.transparent,
                ),
              ),
              onPressed: () => onLocationSelected(loc),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// --- 3. REVIEWS SECTION (With Logic) ---
class ReviewsSection extends StatefulWidget {
  final String itemId;

  const ReviewsSection({super.key, required this.itemId});

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  // LOGIC: Check permissions and open dialog
  void _attemptReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login required")));
      return;
    }

    // Check if they have a COMPLETED booking for this item
    final query = await FirebaseFirestore.instance
        .collection('bookings')
        .where('renteeId', isEqualTo: user.uid)
        .where('itemId', isEqualTo: widget.itemId)
        .where('status', isEqualTo: 'completed')
        .get();

    if (query.docs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You can only review items you have rented & returned!",
            ),
          ),
        );
      }
      return;
    }

    String bookingId = query.docs.first.get('bookingId');
    _showReviewDialog(bookingId);
  }

  // LOGIC: The Dialog and The Transaction
  void _showReviewDialog(String bookingId) {
    final commentController = TextEditingController();
    double currentRating = 5.0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Rate this Item"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Star Rating UI
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < currentRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                      ),
                      onPressed: () {
                        setDialogState(() => currentRating = index + 1.0);
                      },
                    );
                  }),
                ),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: "Write your feedback...",
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (commentController.text.isNotEmpty) {
                    final user = FirebaseAuth.instance.currentUser!;

                    try {
                      // --- TRANSACTION START ---
                      await FirebaseFirestore.instance.runTransaction((
                        transaction,
                      ) async {
                        DocumentReference itemRef = FirebaseFirestore.instance
                            .collection('items')
                            .doc(widget.itemId);
                        DocumentSnapshot itemSnap = await transaction.get(
                          itemRef,
                        );

                        // 1. Calculate new stats
                        Map<String, dynamic> data =
                            itemSnap.data() as Map<String, dynamic>;
                        double oldAvg = (data['averageRating'] ?? 0).toDouble();
                        int oldCount = (data['reviewCount'] ?? 0).toInt();

                        int newCount = oldCount + 1;
                        double newAvg =
                            ((oldAvg * oldCount) + currentRating) / newCount;

                        // 2. Create Review Doc
                        DocumentReference reviewRef = FirebaseFirestore.instance
                            .collection('reviews')
                            .doc();
                        transaction.set(reviewRef, {
                          'reviewId': reviewRef.id,
                          'itemId': widget.itemId,
                          'bookingId': bookingId,
                          'reviewerId': user.uid,
                          'reviewerName': user.displayName ?? "User",
                          'rating': currentRating,
                          'comment': commentController.text,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        // 3. Update Item Stats
                        transaction.update(itemRef, {
                          'averageRating': newAvg,
                          'reviewCount': newCount,
                        });
                      });
                      // --- TRANSACTION END ---

                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Review Submitted!")),
                        );
                      }
                    } catch (e) {
                      print("Error: $e");
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800000),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('itemId', isEqualTo: widget.itemId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = snapshot.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Reviews (${reviews.length})",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _attemptReview,
                  child: const Text("Write a Review"),
                ),
              ],
            ),
            if (reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "No reviews yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            ...reviews.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF800000),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(data['reviewerName'] ?? 'Anonymous'),
                subtitle: Text(data['comment']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(
                      " ${data['rating']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }
}
