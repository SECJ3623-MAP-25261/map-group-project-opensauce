import 'package:cloud_firestore/cloud_firestore.dart';
import 'review.dart'; // Keep this if you have the review file

class Item {
  final String id;
  
  // --- OWNER INFO (From Screenshot) ---
  final String ownerId;        
  final String ownerName;      
  final String ownerImage;     
  
  // --- PRODUCT INFO ---
  final String productName;    // Maps to 'product_name'
  final double pricePerDay;    // Maps to 'price_per_day'
  final String description;    
  final String category;
  final double deposit;       
  
  // --- IMAGES ---
  final String imageUrl;       // Maps to 'imageURL'
  final List<String> imageUrls;// Maps to 'imageUrls'

  // --- DETAILS ---
  final int quantity;          
  final String rentingDuration;// Maps to 'renting_duration'
  final String deliveryMethods;// Maps to 'delivery_methods'
  final double averageRating;  // Maps to 'rating'
  
  final String? currentRenterId; 
  final List<Review> reviews;

  Item({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerImage,
    required this.productName,
    required this.pricePerDay,
    required this.description,
    this.category = "Other",
    this.deposit = 0.0,
    required this.imageUrl,
    required this.imageUrls,
    required this.quantity,
    required this.rentingDuration,
    required this.deliveryMethods,
    required this.averageRating,
    this.currentRenterId,
    this.reviews = const [],
  });

  // --- 1. UPLOAD TO FIREBASE (Matches Screenshot Keys) ---
  Map<String, dynamic> toJson() {
    return {
      // Convert String ID back to Reference
      'owner': FirebaseFirestore.instance.doc('user/$ownerId'),
      'ownerName': ownerName,
      'ownerImage': ownerImage,
      
      'product_name': productName,
      'price_per_day': pricePerDay,
      'description': description,
      'imageURL': imageUrl,   // CamelCase per screenshot
      'imageUrls': imageUrls, // Array per screenshot
      'deposit': deposit,
      
      'quantity': quantity,
      'renting_duration': rentingDuration,
      'delivery_methods': deliveryMethods,
      'rating': averageRating,
      
      'renter': currentRenterId != null && currentRenterId!.isNotEmpty
          ? FirebaseFirestore.instance.doc('user/$currentRenterId') 
          : null,
          
      // 'reviews': reviews.map((r) => r.toJson()).toList(), // Uncomment if reviews are ready
    };
  }

  // --- 2. DOWNLOAD FROM FIREBASE ---
  factory Item.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw StateError('Item data is missing.');

    // Helper to extract ID from Reference safely
    String getIdFromRef(dynamic value) {
      if (value is DocumentReference) {
        return value.id; 
      }
      return '';
    }

    return Item(
      id: snapshot.id,
      
      // Owner Logic
      ownerId: getIdFromRef(data['owner']),
      ownerName: data['ownerName'] ?? 'Unknown',
      ownerImage: data['ownerImage'] ?? '',

      // Product Logic
      productName: data['product_name'] ?? '',
      pricePerDay: (data['price_per_day'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      category: data['category'] ?? 'Other',
      deposit: (data['deposit'] as num?)?.toDouble() ?? 0.0, 

      // Image Logic
      imageUrl: data['imageURL'] ?? '', 
      imageUrls: List<String>.from(data['imageUrls'] ?? []),

      // Details
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      rentingDuration: data['renting_duration'].toString(), // Safe toString() handles Numbers or Strings
      deliveryMethods: data['delivery_methods'] ?? 'Pick-up',
      averageRating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      
      currentRenterId: getIdFromRef(data['renter']),
      reviews: [], // Initialize empty for now to prevent crashes
    );
  }
}