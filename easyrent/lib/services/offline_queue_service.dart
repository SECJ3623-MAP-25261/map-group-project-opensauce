import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class OfflineQueueService {
  static const String _boxName = 'offline_items';

  // 1. Initialize Hive (Call this in main.dart)
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  // 2. Save Item for Later (The "Waiting Room")
  Future<void> queueItem({
    required String title,
    required double price,
    required String description,
    required String category,
    required List<String> localImagePaths, // Path on phone, not URL!
    required String userId,
  }) async {
    final box = Hive.box(_boxName);

    final Map<String, dynamic> offlineItem = {
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'localImagePaths': localImagePaths,
      'userId': userId,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await box.add(offlineItem);
    print("OFFLINE: Item queued! Total pending: ${box.length}");
  }

  // 3. The Sync Process (Called when internet returns)
  Future<void> syncPendingItems() async {
    final box = Hive.box(_boxName);
    if (box.isEmpty) return;

    // Check internet just to be safe
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    print("SYNC: Internet found. Syncing ${box.length} items...");

    // Iterate through all queued items
    // We use a reversed loop or keys to safely delete while iterating
    final keys = box.keys.toList();

    for (var key in keys) {
      final item = box.get(key) as Map;

      try {
        await _processSingleItem(item);
        await box.delete(key); // Remove from queue only if successful
        print("SYNC: Item '$key' uploaded successfully.");
      } catch (e) {
        print("SYNC ERROR for item $key: $e");
        // Keep in queue to try again later
      }
    }
  }

  // 4. Helper: Upload Image -> Get URL -> Save to Firestore
  Future<void> _processSingleItem(Map item) async {
    List<String> imageUrls = [];
    List<String> localPaths = List<String>.from(item['localImagePaths']);

    // A. Upload Images to Firebase Storage
    for (String path in localPaths) {
      File file = File(path);
      if (await file.exists()) {
        String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        Reference ref = FirebaseStorage.instance.ref().child(
          'items/${item['userId']}/$fileName',
        );

        await ref.putFile(file);
        String downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
    }

    // B. Upload Data to Firestore
    await FirebaseFirestore.instance.collection('items').add({
      'title': item['title'],
      'pricePerDay': item['price'],
      'description': item['description'],
      'category': item['category'],
      'images': imageUrls, // Now we have real URLs
      'firstImage': imageUrls.isNotEmpty ? imageUrls.first : null,
      'ownerId': item['userId'],
      'userId': item['userId'], // Save both for safety
      'createdAt': FieldValue.serverTimestamp(),
      'isAvailable': true,
    });
  }
}
