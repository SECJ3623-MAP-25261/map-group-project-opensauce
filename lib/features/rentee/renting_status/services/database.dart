
import 'package:cloud_firestore/cloud_firestore.dart';

class RentingStatusDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'orders';

  Stream<List<Map<String, dynamic>>> getOrderingItems(String userId) {

    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('status',isEqualTo: 'pending')

        .snapshots() // Get the real-time stream of QuerySnapshots
        .map((snapshot) {

          return snapshot.docs.map((doc) {

            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Include the unique Document ID
            return data;
          }).toList();
      });
  }

  Stream<List<Map<String, dynamic>>> getInRentingItems(String userId) {
     return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('status',isEqualTo: 'renting')

        .snapshots() // Get the real-time stream of QuerySnapshots
        .map((snapshot) {

          return snapshot.docs.map((doc) {

            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Include the unique Document ID
            return data;
          }).toList();
      });
  }
  Stream<List<Map<String, dynamic>>> getHistoryItems(String userId) {
 return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('status',isEqualTo: 'completed')

        .snapshots() // Get the real-time stream of QuerySnapshots
        .map((snapshot) {

          return snapshot.docs.map((doc) {

            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Include the unique Document ID
            return data;
          }).toList();
      });
  }
}