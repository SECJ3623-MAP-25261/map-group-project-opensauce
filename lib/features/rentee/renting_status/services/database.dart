import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyrent/core/constants/constants.dart';
import 'package:http/http.dart' as http;

class RentingStatusDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'orders';
  static const String baseUrl = AppString.baseUrl;

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

  Future<void> updateItemStatus(String orderId, String newStatus) async {
    final orderRef = _firestore.collection(_collectionName).doc(orderId);

    await orderRef.update({'status': newStatus});
  }

  Future<bool> decreaseItemOrderCounts({required String productId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/product/decrease-orderCounts'),
        headers: {
          'Content-Type' : 'application/json',
        },
        body: jsonEncode({
          'productId':productId
        })
      );

      if(response.statusCode == 400 ){
        print(
          '---------- Failed to  decrease orderCounts for: $productId ----------',
        );
        return false;
      }

      if(response.statusCode == 200 ){
         print(
          '---------- Successfully updated orderCounts for: $productId ----------',
        );
        return true;
      }

     return false;

    } catch (e) {
      // Handle specific cases (like the document being deleted mid-process)
      print('Firebase Update Error: ${e}');
      return false;
    } 
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
                Map<String, dynamic> data = doc.data();
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
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id; // Include the unique Document ID
            return data;
          }).toList();
        });
  }

  Stream<List<Map<String, dynamic>>> getHistoryItems(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['history', 'cancel', 'complete'])
        .snapshots() // Get the real-time stream of QuerySnapshots
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id; // Include the unique Document ID
            return data;
          }).toList();
        });
  }

}
