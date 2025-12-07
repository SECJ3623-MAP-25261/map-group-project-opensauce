import 'package:cloud_firestore/cloud_firestore.dart';
import 'review.dart';
import 'user.dart';

class Item {
  final String id;
  // I made owner nullable/optional to prevent crashes if we don't have the User object yet
  final User? owner; 
  
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
  final String status; // Added to support your approval flow

  // --- Compatibility Getters (Keeps your old code working) ---
  String get name => productName;
  String get price => pricePerDay.toStringAsFixed(2);
  String get rentalInfo => rentingDuration;
  // ---------------------------------------------------------

  Item({
    required this.id,
    this.owner,
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
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'price_per_day': pricePerDay,
      'total_price': totalPrice,
      'image_url': imageUrl,
      'description': description,
      'renting_duration': rentingDuration,
      'quantity': quantity,
      'delivery_methods': deliveryMethods,
      'current_renter_id': currentRenterId,
      'average_rating': averageRating,
      'status': status,
      'reviews': reviews.map((r) => r.toMap()).toList(),
    };
  }

  factory Item.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw StateError('Item data missing');
    
    return Item(
      id: snapshot.id,
      // We don't have the full User object from just the item snapshot, so we leave it null for now
      owner: null, 
      productName: data['product_name'] ?? data['name'] ?? 'Unknown',
      pricePerDay: (data['price_per_day'] ?? data['price'] ?? 0.0) is String 
          ? double.tryParse(data['price_per_day'] ?? '0') ?? 0.0 
          : (data['price_per_day'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (data['total_price'] as num?)?.toDouble(),
      imageUrl: data['image_url'] ?? data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      rentingDuration: data['renting_duration'] ?? data['rentalInfo'] ?? '',
      quantity: data['quantity'] ?? 1,
      deliveryMethods: data['delivery_methods'] ?? 'Pickup',
      currentRenterId: data['current_renter_id'],
      averageRating: (data['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (data['reviews'] as List<dynamic>? ?? [])
          .map((r) => Review.fromMap(r as Map<String, dynamic>))
          .toList(),
      status: data['status'] ?? 'pending',
    );
  }
}