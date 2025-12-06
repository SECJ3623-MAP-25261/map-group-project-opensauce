import '../entities/item_entity.dart';

class ItemModel extends ItemEntity {
  ItemModel({
    required super.id,
    required super.name,
    required super.price,
    required super.rentalInfo,
    required super.imageUrl,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      rentalInfo: json['rentalInfo'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "rentalInfo": rentalInfo,
        "imageUrl": imageUrl,
      };
}
