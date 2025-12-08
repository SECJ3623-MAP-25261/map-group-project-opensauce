import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/item.dart';

class ListingItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ListingItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('product')
          .doc(item.id)
          .snapshots(),
      builder: (context, snapshot) {
        
        Item currentItem = item;
        double displayRating = 0.0;
        int reviewCount = 0;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data();
          
          try {
            currentItem = Item.fromSnapshot(snapshot.data!);
          } catch (e) {
            print("Error parsing item: $e");
          }

          if (data != null && data.containsKey('reviews')) {
            final List<dynamic> reviewsList = data['reviews'] as List<dynamic>;
            reviewCount = reviewsList.length;

            if (reviewCount > 0) {
              double sum = 0;
              for (var review in reviewsList) {
                sum += (review['star'] as num?)?.toDouble() ?? 0.0;
              }
              displayRating = sum / reviewCount;
            }
          }
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      currentItem.imageUrl, 
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, stack) => const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                
                // TEXT INFO
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentItem.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "RM ${currentItem.pricePerDay.toStringAsFixed(0)} per day",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            displayRating.toStringAsFixed(1), 
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "($reviewCount)", 
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}