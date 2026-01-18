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

  // 2. Save Item for Later (ADD or UPDATE)
  Future<void> queueItem({
    required Map<String, dynamic> data,
    required String action, // 'create' or 'update'
    String? docId, // Required for 'update'
    required String userId,
    List<String>? localImagePaths, // For new images
  }) async {
    final box = Hive.box(_boxName);

    final Map<String, dynamic> offlineItem = {
      'action': action,
      'docId': docId,
      'userId': userId,
      'data': data,
      'localImagePaths': localImagePaths ?? [],
      'createdAt': DateTime.now().toIso8601String(),
    };

    await box.add(offlineItem);
    print("OFFLINE: Item queued ($action)! Total pending: ${box.length}");
  }

  // 3. The Sync Process (Called when internet returns)
  Future<void> syncPendingItems() async {
    final box = Hive.box(_boxName);
    if (box.isEmpty) return;

    // Check internet just to be safe
    final connectivityResult = await Connectivity().checkConnectivity();
    // Support new connectivity_plus list return
    final hasConnection = connectivityResult != ConnectivityResult.none;
    if (!hasConnection) return;

    print("SYNC: Internet found. Syncing ${box.length} items...");

    // Iterate through all queued items
    final keys = box.keys.toList();

    for (var key in keys) {
      final item = box.get(key) as Map;

      try {
        if (item['action'] == 'update') {
          await _processUpdateItem(item);
        } else {
          await _processCreateItem(item); // Original logic
        }
        await box.delete(key); // Remove from queue only if successful
        print("SYNC: Item '$key' processed successfully.");
      } catch (e) {
        print("SYNC ERROR for item $key: $e");
        // Keep in queue to try again later
      }
    }
  }

  // 4a. Helper: Process CREATE
  Future<void> _processCreateItem(Map item) async {
    List<String> imageUrls = [];
    List<String> localPaths = List<String>.from(item['localImagePaths'] ?? []);
    Map<String, dynamic> data = Map<String, dynamic>.from(item['data']);

    // Upload Images
    imageUrls = await _uploadImages(localPaths, item['userId']);

    // Save to Firestore
    await FirebaseFirestore.instance.collection('items').add({
      ...data,
      'images': imageUrls,
      'firstImage': imageUrls.isNotEmpty ? imageUrls.first : null,
      'ownerId': item['userId'],
      'userId': item['userId'],
      'createdAt': FieldValue.serverTimestamp(),
      'isAvailable': true,
    });
  }

  // 4b. Helper: Process UPDATE
  Future<void> _processUpdateItem(Map item) async {
    String docId = item['docId'];
    List<String> localPaths = List<String>.from(item['localImagePaths'] ?? []);
    Map<String, dynamic> data = Map<String, dynamic>.from(item['data']);

    // 1. Upload NEW images
    List<String> newImageUrls = await _uploadImages(localPaths, item['userId']);

    // 2. Merge with existing images (passed in data['images'])
    List<dynamic> currentImages = List<dynamic>.from(data['images'] ?? []);
    currentImages.addAll(newImageUrls);
    
    // Update data with final image list
    data['images'] = currentImages;
    data['firstImage'] = currentImages.isNotEmpty ? currentImages.first : null;
    data['updatedAt'] = FieldValue.serverTimestamp();

    // 3. Update Firestore
    await FirebaseFirestore.instance.collection('items').doc(docId).update(data);
  }

  // 5. Shared Helper: Upload Images
  Future<List<String>> _uploadImages(List<String> paths, String userId) async {
    List<String> urls = [];
    for (String path in paths) {
      File file = File(path);
      if (await file.exists()) {
        String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        Reference ref = FirebaseStorage.instance.ref().child(
          'items/$userId/$fileName',
        );
        await ref.putFile(file);
        String downloadUrl = await ref.getDownloadURL();
        urls.add(downloadUrl);
      }
    }
    return urls;
  }
}
