import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String title;
  final double pricePerDay;
  final String? firstImage;
  final String description;
  final String ownerId;
  final List<dynamic> images;
  final String category;
  final List<dynamic> pickupLocations;
  final String? address;

  ItemModel({
    required this.id,
    required this.title,
    required this.pricePerDay,
    this.firstImage,
    required this.description,
    required this.ownerId,
    required this.images,
    required this.category,
    required this.pickupLocations,
    this.address,
  });

  factory ItemModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final List<dynamic> imgs = data['images'] ?? [];

    return ItemModel(
      id: doc.id,
      title: data['title'] ?? 'Unnamed',
      pricePerDay: double.tryParse(data['pricePerDay'].toString()) ?? 0.0,
      firstImage: imgs.isNotEmpty ? imgs.first : null,
      description: data['description'] ?? '',
      ownerId: data['userId'] ?? data['ownerId'] ?? '',
      images: imgs,
      category: data['category'] ?? 'General',
      pickupLocations: data['pickupLocations'] ?? [],
      address: data['address'],
    );
  }

  // Helper for compatibility with ItemDetailsPage which expects a Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'pricePerDay': pricePerDay,
      'images': images,
      'description': description,
      'userId': ownerId,
      'ownerId': ownerId,
      'category': category,
      'pickupLocations': pickupLocations,
      'address': address,
    };
  }
}
