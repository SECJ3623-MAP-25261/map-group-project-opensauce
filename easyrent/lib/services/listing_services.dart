import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyrent/models/cart_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ListingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Main function to Create or Update an item
  Future<void> addOrUpdateListing({
    String? listingId, // If null, we create new. If exists, we update.
    required String title,
    required String description,
    required double price,
    required String category,
    required String address,
    required List<String> existingImageUrls, // Images already in the cloud
    required List<File> newImageFiles, // Images from phone gallery
    required String userId,
    required List<locationObject> locationDetails,
  }) async {
    // 1. Upload NEW images (if any)
    List<String> newUrls = await _uploadImages(newImageFiles, userId);

    // 2. Combine with EXISTING images
    // (This keeps images you didn't delete, and adds the new ones)
    List<String> finalImageUrls = [...existingImageUrls, ...newUrls];

    // 3. Prepare Data
    Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'pricePerDay': price,
      'category': category,
      'address': "N/A",
      'images': finalImageUrls,
      'firstImage': finalImageUrls.isNotEmpty ? finalImageUrls.first : '',
      'ownerId': userId, // CRITICAL for your booking logic
      'userId': userId, // Keep for legacy support
      'locationDetails': locationDetails
          .map((loc) => {
                'locationName': loc.locationName,
                'latitude': loc.latitude,
                'longitude': loc.longitude,
              })
          .toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // 4. Save to Firestore
    if (listingId == null) {
      // --- CREATE NEW ---
      data['createdAt'] = FieldValue.serverTimestamp();
      data['isAvailable'] = true; // Default availability

      await _db.collection('items').add(data);
    } else {
      // --- UPDATE EXISTING ---
      await _db.collection('items').doc(listingId).update(data);
    }
  }

  /// Helper: Uploads a list of Files and returns their download URLs
  Future<List<String>> _uploadImages(List<File> files, String userId) async {
    List<String> urls = [];

    for (var file in files) {
      // Create a unique filename: items/user_id/timestamp.jpg
      String fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${urls.length}.jpg";
      Reference ref = _storage.ref().child("items/$userId/$fileName");

      // Upload
      UploadTask task = ref.putFile(file);
      TaskSnapshot snapshot = await task;

      // Get URL
      String url = await snapshot.ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  Future<void> deleteListing(String listingId) async {
    try {
      // 1. Delete from Firestore
      await _db.collection('items').doc(listingId).delete();

      // (Optional) You could also delete images from Storage here
      // if you want to save space, but it's not strictly required.
    } catch (e) {
      throw Exception("Failed to delete item: $e");
    }
  }
}
