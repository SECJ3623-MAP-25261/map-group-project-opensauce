import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../features/models/rentalitem.dart'; 

abstract class RenterRemoteApi {
  Future<List<RentalItem>> fetchRequestedItems();
  Future<void> updateItemStatus(String id, String status);
}

class RenterRemoteApiImpl implements RenterRemoteApi {
  final FirebaseFirestore firestore;

  RenterRemoteApiImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<RentalItem>> fetchRequestedItems() async {
    print("🔥 API: Attempting to fetch items from 'renter_items'..."); // DEBUG 1

    try {
      // 1. Get the raw data from Firestore
      final snapshot = await firestore.collection('renter_items').get();
      
      print("🔥 API: Found ${snapshot.docs.length} documents."); // DEBUG 2

      // 2. Convert each document and print what we find
      return snapshot.docs.map((doc) {
        final data = doc.data();
        print("🔥 API: Processing doc ID: ${doc.id}"); // DEBUG 3
        print("    -> Data: $data"); // DEBUG 4: See exactly what fields exist
        
        try {
          return RentalItem.fromSnapshot(doc);
        } catch (e) {
          print("❌ API: Error converting doc ${doc.id}: $e"); // DEBUG 5: Catch conversion errors
          rethrow;
        }
      }).toList();
      
    } catch (e) {
      print("❌ API CRITICAL ERROR: $e"); // DEBUG 6
      throw e;
    }
  }

  @override
  Future<void> updateItemStatus(String id, String status) async {
    await firestore.collection('renter_items').doc(id).update({'status': status});
  }
}