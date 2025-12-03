class ItemEntity {
  final String id;
  final String name;
  final String price;        
  final String rentalInfo;
  final String imageUrl;     
  final String status;
  
  // new
  final String deposit;
  final String description;
  final String location;
  final String category;
  final double rating;
  final List<String> additionalImages; 

  ItemEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.rentalInfo,
    required this.imageUrl,
    this.status = "pending",
    
    this.deposit = "0",
    this.description = "",
    this.location = "",
    this.category = "Other",
    this.rating = 0.0,
    this.additionalImages = const [],
  });

  ItemEntity copyWith({
    String? id,
    String? name,
    String? price,
    String? rentalInfo,
    String? imageUrl,
    String? status,
    String? deposit,
    String? description,
    String? location,
    String? category,
    double? rating,
    List<String>? additionalImages,
  }) {
    return ItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      rentalInfo: rentalInfo ?? this.rentalInfo,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      deposit: deposit ?? this.deposit,
      description: description ?? this.description,
      location: location ?? this.location,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      additionalImages: additionalImages ?? this.additionalImages,
    );
  }
}