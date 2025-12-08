import 'package:cloud_firestore/cloud_firestore.dart';
import 'review.dart';

class Item {
  final String id;
  final DocumentReference ownerRef;
  final String ownerId;
  final String ownerName;
  final String ownerImage;
  final String productName;
  final double pricePerDay;
  final String imageUrl;
  final List<String> imageUrls;
  final String description;
  final int quantity;
  final String rentingDuration;
  final String deliveryMethods;
  final double averageRating;
  final List<Review> reviews;

  Item({
    required this.id,
    required this.ownerRef,
    required this.ownerId,
    required this.ownerName,
    required this.ownerImage,
    required this.productName,
    required this.pricePerDay,
    required this.imageUrl,
    required this.imageUrls,
    required this.description,
    required this.quantity,
    required this.rentingDuration,
    required this.deliveryMethods,
    required this.averageRating,
    required this.reviews,
  });

  // Convert Item to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'product_name': productName,
      'price_per_day': pricePerDay,
      'imageURL': imageUrl,
      'owner': ownerRef,
      'description': description,
      'quantity': quantity,
      'renting_duration': rentingDuration,
      'delivery_methods': deliveryMethods,
      'rating': averageRating,
      'ownerName': ownerName,
      'ownerImage': ownerImage,
      'imageUrls': imageUrls,
      'reviews': reviews.map((r) => r.toMap()).toList(),
    };
  }

  // Create Item from Firestore Snapshot - UPDATED with type safety
  factory Item.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;

    // Debug print to see what data we're getting
    print('🔥 Firestore data for item ${snapshot.id}:');
    data.forEach((key, value) {
      print('  $key: $value (${value.runtimeType})');
    });

    // Handle owner reference
    DocumentReference ownerRef;
    if (data['owner'] is DocumentReference) {
      ownerRef = data['owner'] as DocumentReference;
    } else if (data['owner'] is String) {
      ownerRef = FirebaseFirestore.instance
          .collection('user')
          .doc(data['owner'] as String);
    } else {
      ownerRef = FirebaseFirestore.instance.collection('user').doc('unknown');
    }

    // Convert all fields with proper type safety
    final productName = _safeString(data['product_name']);
    final description = _safeString(data['description']);
    final imageUrl = _safeString(data['imageURL']);
    final rentingDuration = _safeString(data['renting_duration']);
    final deliveryMethods = _safeString(data['delivery_methods']);
    final ownerName = _safeString(data['ownerName'] ?? 'Unknown Owner');
    final ownerImage = _safeString(
      data['ownerImage'] ?? 'https://i.pravatar.cc/150?img=1',
    );

    // Handle price - could be int or double
    final pricePerDay = _safeDouble(data['price_per_day']);

    // Handle quantity - could be int or double
    final quantity = _safeInt(data['quantity']);

    // Handle rating - could be int or double
    final averageRating = _safeDouble(data['rating'] ?? data['averageRating']);

    // Handle imageUrls - ensure it's a List<String>
    List<String> imageUrls = [];
    if (data['imageUrls'] is List) {
      final list = data['imageUrls'] as List;
      imageUrls = list.map((item) => item.toString()).toList();
    } else if (imageUrl.isNotEmpty) {
      imageUrls = [imageUrl];
    }

    // Handle reviews
    List<Review> reviews = [];
    if (data['reviews'] is List) {
      final reviewList = data['reviews'] as List<dynamic>;
      reviews =
          reviewList.map((reviewData) {
            if (reviewData is Map<String, dynamic>) {
              return Review.fromMap(reviewData);
            }
            return Review(
              reviewerName: 'Unknown',
              reviewerImage: 'https://i.pravatar.cc/150?img=1',
              date: DateTime.now(),
              star: 0.0,
              reviewText: '',
            );
          }).toList();
    }

    return Item(
      id: snapshot.id,
      ownerRef: ownerRef,
      ownerId: ownerRef.id,
      ownerName: ownerName,
      ownerImage: ownerImage,
      productName: productName,
      pricePerDay: pricePerDay,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      description: description,
      quantity: quantity,
      rentingDuration: rentingDuration,
      deliveryMethods: deliveryMethods,
      averageRating: averageRating,
      reviews: reviews,
    );
  }

  // Helper methods for type-safe conversions
  static String _safeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  static int _safeInt(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 1;
      }
    }
    return 1;
  }

  // CopyWith method
  Item copyWith({
    String? id,
    DocumentReference? ownerRef,
    String? ownerId,
    String? ownerName,
    String? ownerImage,
    String? productName,
    double? pricePerDay,
    String? imageUrl,
    List<String>? imageUrls,
    String? description,
    int? quantity,
    String? rentingDuration,
    String? deliveryMethods,
    double? averageRating,
    List<Review>? reviews,
  }) {
    return Item(
      id: id ?? this.id,
      ownerRef: ownerRef ?? this.ownerRef,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerImage: ownerImage ?? this.ownerImage,
      productName: productName ?? this.productName,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      rentingDuration: rentingDuration ?? this.rentingDuration,
      deliveryMethods: deliveryMethods ?? this.deliveryMethods,
      averageRating: averageRating ?? this.averageRating,
      reviews: reviews ?? this.reviews,
    );
  }
}
