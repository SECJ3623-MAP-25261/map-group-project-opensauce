import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/item_entity.dart';

class ItemModel extends ItemEntity {
  ItemModel({
    required String id,
    required String name,
    required String price,
    required String rentalInfo,
    required String imageUrl,
    required String status,
  }) : super(
          id: id,
          name: name,
          price: price,
          rentalInfo: rentalInfo,
          imageUrl: imageUrl,
          status: status,
        );

  factory ItemModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return ItemModel(
      id: snapshot.id, 
      name: data['name'] ?? '',
      price: (data['price'] ?? '0').toString(),
      rentalInfo: data['rentalInfo'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'name': name,
      'price': price, 
      'rentalInfo': rentalInfo,
      'imageUrl': imageUrl,
      'status': status,
    };
  }
}