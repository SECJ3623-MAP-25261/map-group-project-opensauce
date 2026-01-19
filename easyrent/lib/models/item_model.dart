import 'package:cloud_firestore/cloud_firestore.dart';

class locationObject {
  final String locationName;
  final double latitude;
  final double longitude;

  locationObject({
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  // Helper factory method for deserialization
  factory locationObject.fromMap(Map<String, dynamic> map) {
    return locationObject(
      locationName: map['locationName'] as String? ?? '',
      // Use num to safely handle both int and double from Firestore
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Helper method for serialization
  Map<String, dynamic> toMap() {
    return {
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

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
  final List<locationObject>? locationDetails;

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
    this.rentCount,
    this.locationDetails,
  });

  // 1. FACTORY: FROM API / MAP
  factory ItemModel.fromMap(Map<String, dynamic> data, {String? id}) {
    List<dynamic> imgs = data['images'] is List ? data['images'] : [];

    String foundOwnerId =
        data['ownerId'] ?? data['userId'] ?? data['owner_id'] ?? '';

    // --- FIX: Safely parse locationDetails ---
    List<locationObject> parsedLocations = [];
    if (data['locationDetails'] != null && data['locationDetails'] is List) {
      parsedLocations = (data['locationDetails'] as List)
          .map(
            (locData) =>
                locationObject.fromMap(locData as Map<String, dynamic>),
          )
          .toList();
    }

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
      rentCount: int.tryParse((data['rentCount'] ?? 0).toString()) ?? 0,
      // Use the parsed list here
      locationDetails: parsedLocations,
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
      'locationDetails': locationDetails?.map((loc) => loc.toMap()).toList() ?? [],
    };
  }
}
