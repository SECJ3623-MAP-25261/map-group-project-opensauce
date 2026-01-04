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
  final String description; // Consolidating description
  final String category; // Consolidating category
  final double deposit; // Consolidating deposit
  final String imageUrl;
  final List<String> imageUrls;
  final int quantity;
  final String rentingDuration;
  final String deliveryMethods;
  final double averageRating; // Consolidating averageRating
  final String? currentRenterId; // Consolidating currentRenterId, making it nullable
  final List<Review> reviews;
  final String location; // Consolidating location
  final double locationLat; // Consolidating locationLat
  final double locationLong; // Consolidating locationLong
  final List<locationObject> locationDetails; // New field
  final int orderCounts;

  Item({
    required this.id,
    required this.ownerRef,
    required this.ownerId,
    required this.ownerName,
    required this.ownerImage,
    required this.productName,
    required this.pricePerDay,
    required this.description,
    required this.imageUrl,
    required this.imageUrls,
    required this.quantity,
    required this.rentingDuration,
    required this.deliveryMethods,
    required this.reviews,
    required this.location,
    // Note: locationLat and locationLong are redundant if using locationDetails
    // but kept for backward compatibility with your provided fields.
    required this.locationLat,
    required this.locationLong,
    required this.locationDetails, // New required field in constructor
    this.category = 'Other', // Using initializers for defaults
    this.deposit = 0.0, // Using initializers for defaults
    this.averageRating = 0.0, // Using initializers for defaults
    this.currentRenterId, // Nullable field doesn't need a default unless non-nullable
    this.orderCounts = 0
  });

  // Helper for safe parsing
  static double safeDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }
  
  // --- 1. Serialization (Dart Object -> Firestore Map) ---
  Map<String, dynamic> toMap() {
    return {
      'id' : id,
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
      // Use ownerId to reconstruct the DocumentReference if ownerRef is null
      'renter': currentRenterId != null && currentRenterId!.isNotEmpty
          ? FirebaseFirestore.instance.doc('user/$currentRenterId') 
          : null,
      'reviews': reviews.map((r) => r.toMap()).toList(), 
      'orderCounts':orderCounts
    };
  }

  // NOTE: This toJson method is simplified to call toMap() as is best practice.
  Map<String, dynamic> toJson() => toMap();


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
            
    // Get the owner ID from the DocumentReference
    final String ownerId = ownerRef?.id ?? '';
    // Get the renter ID from the DocumentReference
    final String? currentRenterId = renterRef?.id;

    // Default ownerRef if it was missing (should not happen with good data)
    final DocumentReference defaultOwnerRef = ownerRef ?? FirebaseFirestore.instance.doc('user/unknown');
    
    return Item(
      id: id,
      ownerRef: defaultOwnerRef,
      ownerId: ownerId,
      currentRenterId: currentRenterId,

      ownerName: map['ownerName'] as String? ?? '',
      ownerImage: map['ownerImage'] as String? ?? '',
      productName: map['product_name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Other',

      pricePerDay: safeDouble(map['price_per_day']),
      deposit: safeDouble(map['deposit']),

      imageUrl: map['imageURL'] as String? ?? '',
      imageUrls: List<String>.from(map['imageUrls'] as List<dynamic>? ?? []),
      
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      rentingDuration: map['renting_duration'] as String? ?? '',
      deliveryMethods: map['delivery_methods'] as String? ?? '',
      averageRating: safeDouble(map['rating']),
      reviews: loadedReviews,
      location: map['location'] as String? ?? '',
      locationLat: safeDouble(map['locationLat']),
      locationLong: safeDouble(map['locationLong']),
      locationDetails: loadedLocationDetails,
      orderCounts: (map['orderCounts'] as num?)?.toInt() ?? 0,
    );
  }

  factory Item.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      // Return a minimal, valid Item for a non-existent document
       return Item(
        id: snapshot.id,
        ownerRef: FirebaseFirestore.instance.doc('user/unknown'),
        ownerId: '',
        ownerName: '',
        ownerImage: '',
        productName: '',
        pricePerDay: 0.0,
        description: '',
        imageUrl: '',
        imageUrls: const [],
        quantity: 0,
        rentingDuration: '',
        deliveryMethods: '',
        reviews: const [],
        location: '',
        locationLat: 0.0,
        locationLong: 0.0,
        locationDetails: const [],
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
    List<locationObject>? locationDetails,
    int ? orderCounts
  }) {
    return Item(
      id: id ?? this.id,
      ownerRef: ownerRef ?? this.ownerRef,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerImage: ownerImage ?? this.ownerImage,
      productName: productName ?? this.productName,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      description: description ?? this.description,
      category: category ?? this.category,
      deposit: deposit ?? this.deposit,
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
      orderCounts: orderCounts ?? this.orderCounts
    );
  }
}