class LatLng {
    final double latitude;
    final double longitude;

    LatLng(this.latitude, this.longitude);
  }

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
  final String category;
  final double rating;
  final List<String> additionalImages; 

  // geolocation
  final List<String> location;
  final List<LatLng> locationLatLong;


  ItemEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.rentalInfo,
    required this.imageUrl,
    this.status = "pending",
    
    this.deposit = "0",
    this.description = "",
    this.location = const [],
    this.category = "Other",
    this.rating = 0.0,
    this.additionalImages = const [],
    this.locationLatLong = const [],
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
    List<String>? location, // new
    List<LatLng>? locationLatLong, // new
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
      category: category ?? this.category,
      rating: rating ?? this.rating,
      additionalImages: additionalImages ?? this.additionalImages,
      location: location ?? this.location,
      locationLatLong: locationLatLong ?? this.locationLatLong,
    );
  }
}