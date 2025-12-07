import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/listing_repository.dart';
import '../../../../models/item.dart';

class ListingRepositoryImpl implements ListingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //String? get _currentUserId => _auth.currentUser?.uid;
  String? get _currentUserId => "UAPrpMnRHvfu47xvzh7L";

  @override
  Future<List<Item>> getMyItems() async {
    try {
      final uid = _currentUserId;
      if (uid == null) {
        print("Error: No user logged in.");
        return []; 
      }

      // 1. Create a Reference to the current user (matches your DB screenshot)
      // Your DB uses references like: /user/UAPrp...
      final userRef = _firestore.doc('user/$uid');

      // 2. Query the 'product' collection
      final snapshot = await _firestore
          .collection('product') 
          .where('owner', isEqualTo: userRef) // Filter by Reference
          .get();

      // 3. Convert to Item objects
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

      // 4. Convert Item to JSON
      final data = item.toJson();
      
      // 5. Force the Owner to be the Current User (Security)
      data['owner'] = _firestore.doc('user/$uid');
      // Ideally, we should also fetch/set 'ownerName' and 'ownerImage' here if they are missing

      await _firestore.collection('product').add(data);
    } catch (e) {
      print("Error adding product: $e");
      throw e;
    }
  }

  @override
  Future<void> updateItem(Item item) async {
    try {
      // 6. Update using item.toJson()
      // Note: This overrides 'owner' again, which is fine as long as item.ownerId is correct
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