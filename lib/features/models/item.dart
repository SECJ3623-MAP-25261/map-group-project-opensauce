import 'package:cloud_firestore/cloud_firestore.dart';
import 'review.dart'; // Assuming 'review.dart' contains the Review class

// =======================================================================
// NEW CLASS: locationObject
// =======================================================================
class locationObject {
  final String locationName;
  final double latitude;
  final double longitude;

  locationObject({
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  // Helper factory method for deserialization
  factory locationObject.fromMap(Map<String, dynamic> map) {
    return locationObject(
      locationName: map['locationName'] as String? ?? '',
      // Use num to safely handle both int and double from Firestore
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Helper method for serialization
  Map<String, dynamic> toMap() {
    return {
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
// =======================================================================
// ITEM CLASS
// =======================================================================
class Item {
  final String id;
  final DocumentReference ownerRef;
  final String ownerId;
  final String ownerName;
  final String ownerImage;
  final String productName;
  final double pricePerDay;
  final String description;
  final String category;
  final double deposit;
  final String imageUrl;
  final List<String> imageUrls;
  final String description;
  final int quantity;
  final String rentingDuration;
  final String deliveryMethods;
  final double averageRating;
  final String? currentRenterId;
  final double averageRating;
  final List<Review> reviews;
  final String location;
  final double locationLat;
  final double locationLong;
  
  // Added fields to fix errors
  final String category;
  final double deposit;
  final String currentRenterId;
  final List<locationObject> locationDetails; // New field

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
    this.currentRenterId,
    this.reviews = const [],
    this.locationLat = 0.0,
    this.locationLong = 0.0,
    this.locationDetails = const [], // Set default empty list for safety
  });

  // --- 1. Serialization (Dart Object -> Firestore Map) ---
  Map<String, dynamic> toMap() {
    return {
      'owner': ownerRef,
      'ownerName': ownerName,
      'ownerImage': ownerImage,
      'product_name': productName,
      'price_per_day': pricePerDay,
      'description': description,
      'category': category,
      'deposit': deposit,
      'imageURL': imageUrl,
      'imageUrls': imageUrls,
      'location': location,
      'locationLat': locationLat,
      'locationLong': locationLong,
      // FIX 1: Use toMap() on locationObject list for proper serialization
      'locationDetails': locationDetails.map((loc) => loc.toMap()).toList(),
      'quantity': quantity,
      'renting_duration': rentingDuration,
      'delivery_methods': deliveryMethods,
      'rating': averageRating,
      
      'renter': currentRenterId != null && currentRenterId!.isNotEmpty
          ? FirebaseFirestore.instance.doc('user/$currentRenterId') 
          : null,
      
      'reviews': reviews.map((r) => r.toMap()).toList(), 
    };
  }

  // NOTE: Keeping your toJson method as provided, but recommend using toMap() consistently
  Map<String, dynamic> toJson() {
    return {
      'owner': FirebaseFirestore.instance.doc('user/$ownerId'),
      'ownerName': ownerName,
      'ownerImage': ownerImage, 
      'product_name': productName,
      'price_per_day': pricePerDay,
      'description': description,
      'imageURL': imageUrl,
      'imageUrls': imageUrls,
      'deposit': deposit,
      'location': location,
      // FIX 2: Ensure locationDetails list is mapped for serialization
      'locationDetails' : locationDetails.map((loc) => loc.toMap()).toList(),
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

      'renter': currentRenterId != null && currentRenterId!.isNotEmpty
          ? FirebaseFirestore.instance.doc('user/$currentRenterId') 
          : null,
    };
  }


  // --- 2. Deserialization (Firestore Map -> Dart Object) ---
  factory Item.fromMap(Map<String, dynamic> map, String id) {
    // Safely cast and map the reviews list
    final List<Review> loadedReviews =
        (map['reviews'] as List<dynamic>? ?? [])
            .map((e) => Review.fromMap(e as Map<String, dynamic>))
            .toList();

    // Safely retrieve DocumentReference for owner
    final DocumentReference? ownerRef =
        map['owner'] is DocumentReference
            ? map['owner'] as DocumentReference
            : null;
            
    // Safely retrieve DocumentReference for renter
    final DocumentReference? renterRef =
        map['renter'] is DocumentReference
            ? map['renter'] as DocumentReference
            : null;
            
    // FIX 3: Correctly deserialize List<Map<String, dynamic>> into List<locationObject>
    final List<locationObject> loadedLocationDetails =
        (map['locationDetails'] as List<dynamic>? ?? [])
            .map((e) => locationObject.fromMap(e as Map<String, dynamic>))
            .toList();


    // Helper for safe parsing
    double safeDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

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
      ownerRef: ownerRef!,
      ownerId: ownerRef.id,
      currentRenterId: renterRef?.id,

      ownerName: map['ownerName'] ?? '',
      ownerImage: map['ownerImage'] ?? '',
      productName: map['product_name'] ?? '',
      category: map['category'] ?? 'Other',

      pricePerDay: (map['price_per_day'] as num?)?.toDouble() ?? 0.0,
      deposit: (map['deposit'] as num?)?.toDouble() ?? 0.0,

      pricePerDay: safeDouble(map['price_per_day']),
      imageUrl: map['imageURL'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      description: map['description'] ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,

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
    String? description,
    String? category,
    double? deposit,
    String? imageUrl,
    List<String>? imageUrls,
    String? location,
    double? locationLat,
    double? locationLong,
    int? quantity,
    String? rentingDuration,
    String? deliveryMethods,
    double? averageRating,
    String? currentRenterId,
    List<Review>? reviews,
    String? location,
    double? locationLat,
    double? locationLong,
    String? category,
    double? deposit,
    String? currentRenterId,
    List<locationObject>? locationDetails,
  }) {
    return Item(
      id: id ?? this.id,
      ownerRef: ownerRef ?? this.ownerRef,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerImage: ownerImage ?? this.ownerImage,
      productName: productName ?? this.productName,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      deposit: deposit ?? this.deposit,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      locationLat: locationLat ?? this.locationLat,
      locationLong: locationLong ?? this.locationLong,
      quantity: quantity ?? this.quantity,
      rentingDuration: rentingDuration ?? this.rentingDuration,
      deliveryMethods: deliveryMethods ?? this.deliveryMethods,
      averageRating: averageRating ?? this.averageRating,
      currentRenterId: currentRenterId ?? this.currentRenterId,
      reviews: reviews ?? this.reviews,
      locationDetails: locationDetails ?? this.locationDetails,
      location: location ?? this.location,
      locationLat: locationLat ?? this.locationLat,
      locationLong: locationLong ?? this.locationLong,
      category: category ?? this.category,
      deposit: deposit ?? this.deposit,
      currentRenterId: currentRenterId ?? this.currentRenterId,
    );
  }
}