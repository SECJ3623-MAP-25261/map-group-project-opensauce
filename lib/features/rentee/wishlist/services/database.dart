import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyrent/features/models/item.dart';

class WishlistDatabaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 2. Define the collection reference
  final String _collectionName = 'wishlist';
  final String _userCollectionName = 'user';
  
  Future<String> CreateWishlistItem({
    required Item item, required itemId,
    // required String userId,
  }) async {
    try {
     // get demo userId (first userId document in the 'user' collection)
      final users = await _firestore.collection(_userCollectionName).limit(1).get();
      if (users.docs.isEmpty) {
        print(' No users found. Please add a user first.');
        return 'null';
      }

      final userDoc = users.docs.first;
      // final userRef = _firestore.collection(_userCollectionName).doc(userDoc.id);
      // 3. Prepare the final data to store
      final Map<String, dynamic> finalData = {
        ...item.toMap(), // Spread the data passed from the application logic
        'ownerId': userDoc.id,
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

  Future<bool> doesItemExist({required String itemIdToCheck,required DocumentReference user}) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection(_collectionName)
              .where('itemId', isEqualTo: itemIdToCheck)
              .where('owner', isEqualTo: user)
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
Stream<List<Item>> getWishlistItems(String userId) {
    print("Userid: $userId");

    final wishlist = _firestore
        .collection(_collectionName)
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
            return snapshot.docs.map((doc) {
                final rawData = doc.data();
                return Item.fromMap(rawData, doc.id);
            }).toList();
        });

    // for debugging purpose 
    wishlist.listen((List<Item> items) {
        print("Total items: ${items.length}");
        
        // Print the details of the first item
        if (items.isNotEmpty) {
            // print("First Item Name: ${items.first.productName}");
            // print("First Item Price: ${items.first.pricePerDay}");
        } else {
            print("Wishlist is currently empty.");
        }
    }).onError((error) {
        print("Error receiving wishlist data: $error");
    });
    
    // The function must return the stream immediately
    return wishlist;
}
}
