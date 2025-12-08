import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistDatabaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 2. Define the collection reference
  final String _collectionName = 'wishlist';

  Future<String> CreateWishlistItem({
    required Map<String, dynamic> item, required itemId,
    // required String userId,
  }) async {
    try {
      // 3. Prepare the final data to store
      final Map<String, dynamic> finalData = {
        ...item, // Spread the data passed from the application logic
        'userId': 'testing User Ling',
        'itemId':itemId,
        'timestamp':
            FieldValue.serverTimestamp(), // Firestore automatically sets server time
      };

      DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(finalData);

      // 5. Return the ID of the new order
      return docRef.id;
    } on FirebaseException catch (e) {
      // Handle potential errors like permission denied, network issues, etc.
      print('Firebase Order Creation Error: ${e.message}');
      rethrow; // Re-throw the exception for the calling layer to handle (e.g., show a snackbar)
    } catch (e) {
      print('General Order Creation Error: $e');
      rethrow;
    }
  }

  // delete item from wishlist
  Future<int> deleteItemsByNestedItemId({
    required String itemIdToMatch,
    required String userId,
  }) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection(_collectionName)
              .where('itemId', isEqualTo: itemIdToMatch)
              .get();

      if (snapshot.docs.isEmpty) {
        print('No documents found matching item.id == $itemIdToMatch.');
        return 0;
      }

      int deletedCount = 0;

      WriteBatch batch = _firestore.batch();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
        deletedCount++;
      }

      await batch.commit();

      print(
        '$deletedCount documents deleted successfully where item.id == $itemIdToMatch.',
      );
      return deletedCount;
    } on FirebaseException catch (e) {
      print('Firebase Nested Field Deletion Query Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('General Nested Field Deletion Query Error: $e');
      rethrow;
    }
  }

  Future<bool> doesItemExist({required String itemIdToCheck}) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection(_collectionName)
              .where('item.id', isEqualTo: itemIdToCheck)
              .limit(
                1,
              ) // Optimize: Stop searching after the first match is found
              .get();

      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      print('Firebase Existence Check Error: ${e.message}');

      rethrow;
    } catch (e) {
      print('General Existence Check Error: $e');
      rethrow;
    }
  }
  Stream<List<Map<String, dynamic>>> getWishlistItems(String userId) {
    // 3. Perform the query to filter by userId and sort the results
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId) // Filter: Only documents matching the userId

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
