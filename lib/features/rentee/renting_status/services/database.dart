import 'package:cloud_firestore/cloud_firestore.dart';

class RentingStatusDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'orders';

  // Stream<List<Map<String, dynamic>>> getOrderingItems(String userId) {
  //   // cannot use Item because got the data other than item
  //   print("userId from getOrderingItems: ${userId}");
  //   return _firestore
  //       .collection(_collectionName)
  //       .where('userId', isEqualTo: userId)
  //       .where('status',isEqualTo: "pending")

  //       .snapshots() // Get the real-time stream of QuerySnapshots
  //       .map((snapshot) {

  //           print("result from getOrderingItems ${snapshot.docs[0]}");
  //         return snapshot.docs.map((doc) {

  //           Map<String, dynamic> data = doc.data();
  //           data['id'] = doc.id; // Include the unique Document ID
  //           return data;
  //         }).toList();
  //     });

  // }

  Future<void> updateItemStatus(
    String orderId,
    String newStatus,
  ) async {
    final orderRef = _firestore.collection(_collectionName).doc(orderId);

        await orderRef.update({
          'status':newStatus,
        });
    
  }

  Stream<List<Map<String, dynamic>>> getOrderingItems(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return data;
              })
              // // 💡 FILTER: Only keep documents that actually have an 'items' map
              // .where((data) => data['items'] != null)
              .toList();
        });
  }

  Stream<List<Map<String, dynamic>>> getInRentingItems(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'renting')
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
        .where('status', whereIn: ['history','cancel','complete'])
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
