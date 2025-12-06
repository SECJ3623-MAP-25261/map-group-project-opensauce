import 'package:easyrent/features/rentee/rentee_profile/domain/user.dart';
import 'review.dart'; 

class Item {
  
  final String id;
  final User owner; 
  
  final String productName;
  final double pricePerDay;
  final double? totalPrice; 
  final String imageUrl;
  final String description;
  final int quantity;
  final String rentingDuration; 
  final String deliveryMethods; 
  final String? currentRenterId; 

  final double averageRating; 
  final List<Review> reviews; 

  Item({
    required this.id,
    required this.owner,
    required this.productName,
    required this.pricePerDay,
    this.totalPrice,
    required this.imageUrl,
    required this.description,
    required this.quantity,
    required this.rentingDuration,
    required this.deliveryMethods,
    this.currentRenterId,
    required this.averageRating,
    required this.reviews,
  });

  // Map<String, dynamic> toJson() {
  //   return {
  //     'ownerId': ownerId,
  //     'ownerName': ownerName,
  //     'product_name': productName,
  //     'price_per_day': pricePerDay,
  //     'total_price': totalPrice,
  //     'image_urls': imageUrls,
  //     'description': description,
  //     'renting_duration': rentingDuration,
  //     'quantity': quantity,
  //     'delivery_methods': deliveryMethods,
  //     'current_renter_id': currentRenterId,
  //     'average_rating': averageRating,
  //     'reviews': reviews.map((r) => r.toMap()).toList(), // Map the list of reviews
  //   };
  // }

  // // --- Deserialization (From Firebase/Map) ---
  // factory Item.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
  //   final data = snapshot.data();
  //   if (data == null) {
  //     throw StateError('Item data is missing from Firestore snapshot.');
  //   }
    
  //   // Convert the list of review maps back into a List<Review>
  //   final reviewMaps = (data['reviews'] as List<dynamic>? ?? [])
  //       .map((reviewMap) => Review.fromMap(reviewMap as Map<String, dynamic>))
  //       .toList();

  //   return Item(
  //     id: snapshot.id, // **CRITICAL**: Use the Document ID for the 'id' field
  //     ownerId: data['ownerId'] ?? '',
  //     ownerName: data['ownerName'] ?? 'Unknown',
  //     productName: data['product_name'] ?? '',
  //     pricePerDay: (data['price_per_day'] as num?)?.toDouble() ?? 0.0,
  //     totalPrice: (data['total_price'] as num?)?.toDouble(),
  //     imageUrls: List<String>.from(data['image_urls'] ?? []),
  //     description: data['description'] ?? '',
  //     rentingDuration: data['renting_duration'] ?? '',
  //     quantity: data['quantity'] ?? 1,
  //     deliveryMethods: data['delivery_methods'] ?? 'Pickup only',
  //     currentRenterId: data['current_renter_id'],
  //     averageRating: (data['average_rating'] as num?)?.toDouble() ?? 0.0,
  //     reviews: reviewMaps,
  //   );
  // }
}