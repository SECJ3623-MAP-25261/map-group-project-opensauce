class ItemEntity {
  final String id;
  final String name;
  final String price;
  final String rentalInfo;
  final String imageUrl;
  final String status;

  ItemEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.rentalInfo,
    required this.imageUrl,
    this.status = "pending",
  });

  ItemEntity copyWith({
    String? id,
    String? name,
    String? price,
    String? rentalInfo,
    String? imageUrl,
    String? status,
  }) {
    return ItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      rentalInfo: rentalInfo ?? this.rentalInfo,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
    );
  }
}
