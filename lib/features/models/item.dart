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
  final String location;
  final double locationLat;
  final double locationLong;
  
  // Added fields to fix errors
  final String category;
  final double deposit;
  final String currentRenterId;

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
    required this.location,
    required this.locationLat,
    required this.locationLong,
    this.category = 'Other',
    this.deposit = 0.0,
    this.currentRenterId = '',
  });

  // --- 1. Serialization (Dart Object -> Firestore Map) ---
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
      'location': location,
      'locationLat': locationLat,
      'locationLong': locationLong,
      'category': category,
      'deposit': deposit,
      'currentRenterId': currentRenterId,
    };
  }

  // Fix: Add toJson as an alias for toMap to satisfy Repository calls
  Map<String, dynamic> toJson() => toMap();

  factory Item.fromMap(Map<String, dynamic> map, String id) {
    final List<Review> loadedReviews =
        (map['reviews'] as List<dynamic>? ?? [])
            .map((e) => Review.fromMap(e as Map<String, dynamic>))
            .toList();

    final DocumentReference? ownerRef =
        map['owner'] is DocumentReference
            ? map['owner'] as DocumentReference
            : null;

    // Helper for safe parsing
    double safeDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return Item(
      id: id,
      ownerRef: ownerRef ?? FirebaseFirestore.instance.doc('user/unknown'),
      ownerId: ownerRef?.id ?? '',
      ownerName: map['ownerName'] ?? '',
      ownerImage: map['ownerImage'] ?? '',
      productName: map['product_name'] ?? '',
      pricePerDay: safeDouble(map['price_per_day']),
      imageUrl: map['imageURL'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? 0,
      rentingDuration: map['renting_duration'] ?? '',
      deliveryMethods: map['delivery_methods'] ?? '',
      averageRating: safeDouble(map['rating']),
      reviews: loadedReviews,
      location: map['location'] ?? '',
      locationLat: safeDouble(map['locationLat']),
      locationLong: safeDouble(map['locationLong']),
      category: map['category'] ?? 'Other',
      deposit: safeDouble(map['deposit']),
      currentRenterId: map['currentRenterId'] ?? '',
    );
  }

  factory Item.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      // Return a default empty item or handle error appropriately
       return Item(
        id: snapshot.id,
        ownerRef: FirebaseFirestore.instance.doc('user/unknown'),
        ownerId: '',
        ownerName: '',
        ownerImage: '',
        productName: '',
        pricePerDay: 0.0,
        imageUrl: '',
        imageUrls: [],
        description: '',
        quantity: 0,
        rentingDuration: '',
        deliveryMethods: '',
        averageRating: 0.0,
        reviews: [],
        location: '',
        locationLat: 0.0,
        locationLong: 0.0
      );
    }
    return Item.fromMap(snapshot.data()!, snapshot.id);
  }

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
    String? location,
    double? locationLat,
    double? locationLong,
    String? category,
    double? deposit,
    String? currentRenterId,
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
      location: location ?? this.location,
      locationLat: locationLat ?? this.locationLat,
      locationLong: locationLong ?? this.locationLong,
      category: category ?? this.category,
      deposit: deposit ?? this.deposit,
      currentRenterId: currentRenterId ?? this.currentRenterId,
    );
  }
}