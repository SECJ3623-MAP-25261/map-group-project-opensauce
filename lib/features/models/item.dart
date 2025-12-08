import 'package:cloud_firestore/cloud_firestore.dart';
import 'review.dart';

class Item {
  final String id;
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
  final String location;
  final int quantity;          
  final String rentingDuration;
  final String deliveryMethods;
  final double averageRating;    
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
    required this.location,
    required this.quantity,
    required this.rentingDuration,
    required this.deliveryMethods,
    required this.averageRating,
    this.currentRenterId,
    this.reviews = const [],
  });

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
      'quantity': quantity,
      'renting_duration': rentingDuration,
      'delivery_methods': deliveryMethods,
      'rating': averageRating,
      
      'renter': currentRenterId != null && currentRenterId!.isNotEmpty
          ? FirebaseFirestore.instance.doc('user/$currentRenterId') 
          : null,
          
    };
  }

  factory Item.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw StateError('Item data is missing.');

    String getIdFromRef(dynamic value) {
      if (value is DocumentReference) {
        return value.id; 
      }
      return '';
    }

    return Item(
      id: snapshot.id,
      ownerId: getIdFromRef(data['owner']),
      ownerName: data['ownerName'] ?? 'Unknown',
      ownerImage: data['ownerImage'] ?? '',
      productName: data['product_name'] ?? '',
      pricePerDay: (data['price_per_day'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      category: data['category'] ?? 'Other',
      deposit: (data['deposit'] as num?)?.toDouble() ?? 0.0, 
      location: data['location'] ?? '',
      imageUrl: data['imageURL'] ?? '', 
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      rentingDuration: data['renting_duration'].toString(),
      deliveryMethods: data['delivery_methods'] ?? 'Pick-up',
      averageRating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      currentRenterId: getIdFromRef(data['renter']),
      reviews: [],
    );
  }
}