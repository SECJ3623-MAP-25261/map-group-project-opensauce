import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String cartDocId;
  final String itemId;
  final String title;
  final String image;
  final double pricePerDay;
  final DateTime startDate;
  final DateTime endDate;
  final List<dynamic> pickupLocations;
  final String ownerId;

  CartItemModel({
    required this.cartDocId,
    required this.itemId,
    required this.title,
    required this.image,
    required this.pricePerDay,
    required this.startDate,
    required this.endDate,
    required this.pickupLocations,
    required this.ownerId,
  });

  // Factory: Firestore Document -> CartItemModel Object
  factory CartItemModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      cartDocId: doc.id,
      itemId: data['itemId'] ?? '',
      title: data['itemTitle'] ?? 'Unknown',
      image: data['itemImage'] ?? '',
      pricePerDay: double.tryParse(data['pricePerDay'].toString()) ?? 0.0,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      pickupLocations: data['pickupLocations'] ?? [],
      ownerId: data['ownerId'] ?? '',
    );
  }

  // Logic: Calculate Duration and Total Price
  int get days {
    // Add 1 because if start=today and end=today, it is 1 day rental
    return endDate.difference(startDate).inDays + 1;
  }

  double get totalRentalPrice => pricePerDay * days;
}
