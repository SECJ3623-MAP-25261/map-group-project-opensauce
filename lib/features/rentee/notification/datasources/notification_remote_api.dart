import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyrent/features/models/rentalitem.dart';

abstract class NotificationRemoteApi {
  Future<List<RentalItem>> fetchApprovedNotifications();
}

class NotificationRemoteApiImpl implements NotificationRemoteApi {
  final FirebaseFirestore firestore;

  NotificationRemoteApiImpl({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<RentalItem>> fetchApprovedNotifications() async {
    print("🔥 API: Fetching ALL items to check for approvals...");

    try {
      // 1. FETCH EVERYTHING (Safer than filtering in Firestore for now)
      final snapshot = await firestore.collection('renter_items').get();

      print("🔥 API: Found ${snapshot.docs.length} total documents.");

      // 2. Convert to RentalItem objects
      List<RentalItem> allItems =
          snapshot.docs.map((doc) {
            try {
              return RentalItem.fromSnapshot(doc);
            } catch (e) {
              print("⚠️ Error converting doc ${doc.id}: $e");
              // Return a placeholder or null if needed, but for now we skip invalid ones
              throw e;
            }
          }).toList();

      return allItems;
    } catch (e) {
      print("❌ API Error: $e");
      rethrow;
    }
  }
}
