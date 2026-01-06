class ItemModel {
  final String description;
  final String id;
  final String image;
  final List<String> images;
  final num price; // Use num to handle both int (like 10) and double
  final String productName;
  final int quantity;
  final double rating;
  final RenterModel renter;

  ItemModel({
    required this.description,
    required this.id,
    required this.image,
    required this.images,
    required this.price,
    required this.productName,
    required this.quantity,
    required this.rating,
    required this.renter,
  });

  // Factory constructor to create an ItemModel from a JSON/Firestore Map
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      description: json['description'] as String,
      id: json['id'] as String,
      image: json['image'] as String,
      // Safely cast the dynamic list to List<String>
      images: (json['images'] as List<dynamic>).cast<String>(),
      price: json['price'] as num,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      rating: json['rating'] as double,
      // Pass the nested map to the RenterModel factory
      renter: RenterModel.fromJson(json['renter'] as Map<String, dynamic>),
    );
  }

  // Optional: Convert the ItemModel back to a Map for storage/API requests
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'id': id,
      'image': image,
      'images': images,
      'price': price,
      'product_name': productName,
      'quantity': quantity,
      'rating': rating,
      'renter': renter.toJson(), // Convert RenterModel back to map
    };
  }
}

// --- Nested Model for Renter Data ---

class RenterModel {
  final String image;
  final String name;
  final String period;
  final int reviewCount;

  RenterModel({
    required this.image,
    required this.name,
    required this.period,
    required this.reviewCount,
  });

  factory RenterModel.fromJson(Map<String, dynamic> json) {
    return RenterModel(
      image: json['image'] as String,
      name: json['name'] as String,
      period: json['period'] as String,
      reviewCount: json['reviewCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'name': name,
      'period': period,
      'reviewCount': reviewCount,
    };
  }
}