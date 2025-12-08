import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/listing_repository.dart';
import '../../../../models/item.dart';

class ListingRepositoryImpl implements ListingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // String? get _currentUserId => _auth.currentUser?.uid;
  String? get _currentUserId => "UAPrpMnRHvfu47xvzh7L"; // TEST

  @override
  Future<List<Item>> getMyItems() async {
    try {
      final uid = _currentUserId;
      if (uid == null) return [];

      final userRef = _firestore.doc('user/$uid');

      final snapshot = await _firestore
          .collection('product') 
          .where('owner', isEqualTo: userRef)
          .get();

      return snapshot.docs.map((doc) => Item.fromSnapshot(doc)).toList();
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  @override
  Future<void> addItem(Item item) async {
    try {
      final uid = _currentUserId;
      if (uid == null) throw Exception("User must be logged in");

      // 1. Fetch User Profile
      final userDoc = await _firestore.collection('user').doc(uid).get();
      
      String ownerName = "Unknown Renter";
      String ownerImage = "";
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        // Assuming your user collection uses 'fname', 'lname', 'profile_image'
        ownerName = "${userData['fname'] ?? ''} ${userData['lname'] ?? ''}".trim();
        ownerImage = userData['profile_image'] ?? "";
      }

      // 2. Overwrite Item with Real Owner Data
      final data = item.toJson();
      data['owner'] = _firestore.doc('user/$uid'); // Reference
      data['ownerName'] = ownerName;               // String
      data['ownerImage'] = ownerImage;             // String

      await _firestore.collection('product').add(data);
    } catch (e) {
      print("Error adding product: $e");
      throw e;
    }
  }

  @override
  Future<void> updateItem(Item item) async {
    try {
      await _firestore.collection('product').doc(item.id).update(item.toJson());
    } catch (e) {
      print("Error updating product: $e");
      throw e;
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      await _firestore.collection('product').doc(id).delete();
    } catch (e) {
      print("Error deleting product: $e");
      throw e;
    }
  }
}