import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ListingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 1. UPLOAD IMAGES
  Future<List<String>> uploadImages(List<File> newFiles) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user");

    List<String> uploadedUrls = [];
    for (var file in newFiles) {
      final ref = _storage
          .ref()
          .child('item_images')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(file);
      uploadedUrls.add(await ref.getDownloadURL());
    }
    return uploadedUrls;
  }

  // 2. ADD LISTING
  Future<void> addListing({
    required String title,
    required String description,
    required double price,
    required String category,
    required String address,
    required List<String> images,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await _db.collection('items').add({
      'ownerId': user.uid,
      'title': title,
      'description': description,
      'pricePerDay': price,
      'category': category,
      'address': address,
      'images': images,
      'isAvailable': true, // Default to true
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 3. UPDATE LISTING
  Future<void> updateListing({
    required String docId,
    required String title,
    required String description,
    required double price,
    required String category,
    required String address,
    required List<String> images,
    required bool isAvailable,
  }) async {
    await _db.collection('items').doc(docId).update({
      'title': title,
      'description': description,
      'pricePerDay': price,
      'category': category,
      'address': address,
      'images': images,
      'isAvailable': isAvailable,
    });
  }

  // 4. DELETE LISTING
  Future<void> deleteListing(String docId) async {
    await _db.collection('items').doc(docId).delete();
  }

  // 5. GET SHOP ADDRESS (Helper)
  Future<String?> getRenterDefaultAddress() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data()?['pickupAddress'];
  }
}
