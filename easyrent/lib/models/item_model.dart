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
  final int? rentCount;

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
    this.rentCount
  });

  // 1. FACTORY: FROM API / MAP
  factory ItemModel.fromMap(Map<String, dynamic> data, {String? id}) {
    List<dynamic> imgs = data['images'] is List ? data['images'] : [];

    String foundOwnerId =
        data['ownerId'] ?? data['userId'] ?? data['owner_id'] ?? '';

    return ItemModel(
      id: id ?? (data['id'] ?? 'unknown').toString(),
      title: (data['title'] ?? data['name'] ?? 'No Name').toString(),
      pricePerDay:
          double.tryParse((data['pricePerDay'] ?? 0).toString()) ?? 0.0,
      firstImage: imgs.isNotEmpty
          ? imgs.first.toString()
          : (data['firstImage'] ?? data['image']),
      description: (data['description'] ?? '').toString(),
      ownerId: foundOwnerId.toString(),
      images: imgs,
      category: (data['category'] ?? 'Others').toString(),
      pickupLocations: (data['pickupLocations'] is List)
          ? data['pickupLocations']
          : [],
      address: data['address']?.toString(),
      
      // --- FIX: Extract rentCount from the data ---
      rentCount: int.tryParse((data['rentCount'] ?? 0).toString()) ?? 0,
    );
  }

  // 2. FACTORY: FROM FIRESTORE
  factory ItemModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?; // Added null safety check
    return ItemModel.fromMap(data ?? {}, id: doc.id); 
  }

  // 3. METHOD: TO MAP
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'pricePerDay': pricePerDay,
      'firstImage': firstImage,
      'image': firstImage,
      'description': description,
      'ownerId': ownerId,
      'images': images,
      'category': category,
      'pickupLocations': pickupLocations,
      'address': address,
      
      // --- FIX: Include rentCount in the map ---
      'rentCount': rentCount ?? 0,
    };
  }
}