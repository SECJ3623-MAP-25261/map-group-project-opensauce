import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyrent/core/constants/constants.dart';

class CheckoutDatabaseServices {
  // 1. Get a reference to the Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 2. Define the collection reference
  final String _collectionName = 'orders';

  Future<String> createOrder({
    required Map<String, dynamic> orderData,
    // required String userId,
  }) async {
    try {
      final Map<String, dynamic> finalData = {
        ...orderData, // Spread the data passed from the application logic
        'userId': AppString.userSampleId,
        'timestamp':
            FieldValue.serverTimestamp(), // Firestore automatically sets server time
        'status': 'pending', // Initial status
      };

      DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(finalData);

      return docRef.id;
    } on FirebaseException catch (e) {
      print('Firebase Order Creation Error: ${e.message}');
      rethrow; // Re-throw the exception for the calling layer to handle (e.g., show a snackbar)
    } catch (e) {
      print('General Order Creation Error: $e');
      rethrow;
    }
  }

  Future<int> deleteItemsFromDBWithItemId({
    required String fieldName,
    required dynamic requiredValue,
  }) async {
    try {
      // 3. Perform the query to get a QuerySnapshot of matching documents
      QuerySnapshot snapshot =
          await _firestore
              .collection(_collectionName)
              .where(
                fieldName,
                isEqualTo: requiredValue,
              ) // The requirement filter
              .get();

      if (snapshot.docs.isEmpty) {
        print('No documents found matching $fieldName == $requiredValue.');
        return 0; // Return 0 if no documents were found
      }

      int deletedCount = 0;

      // 4. Use a Write Batch for efficient, atomic deletion of multiple documents
      WriteBatch batch = _firestore.batch();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        // Add a delete operation for each matching document to the batch
        batch.delete(doc.reference);
        deletedCount++;
      }

      // 5. Commit the batch to execute all deletions at once
      await batch.commit();

      print(
        '$deletedCount documents deleted successfully where $fieldName == $requiredValue.',
      );
      return deletedCount;
    } on FirebaseException catch (e) {
      print('Firebase Deletion Query Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('General Deletion Query Error: $e');
      rethrow;
    }
  }


}
