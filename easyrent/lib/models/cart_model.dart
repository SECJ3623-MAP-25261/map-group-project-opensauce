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
  // added 
  final List<locationObject> locationDetails; // New field
  final String location; // Consolidating location
  final double locationLat; // Consolidating locationLat
  final double locationLong; // Consolidating locationLong



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
    this.locationDetails = const [],
    this.location = '',
    this.locationLat = 0.0,
    this.locationLong = 0.0,
  });

  // Factory: Firestore Document -> CartItemModel Object
  factory CartItemModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    List<locationObject> parsedLocations = [];
    if (data['locationDetails'] != null && data['locationDetails'] is List) {
      parsedLocations = (data['locationDetails'] as List)
          .map(
            (locData) =>
                locationObject.fromMap(locData as Map<String, dynamic>),
          )
          .toList();
    }
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
      location: '',
      locationLat: 0.0,
      locationLong: 0.0,
      locationDetails: parsedLocations,
    );
  }

  // Logic: Calculate Duration and Total Price
  int get days {
    // Add 1 because if start=today and end=today, it is 1 day rental
    return endDate.difference(startDate).inDays + 1;
  }

  double get totalRentalPrice => pricePerDay * days;
}
