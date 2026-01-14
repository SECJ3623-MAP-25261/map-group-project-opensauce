import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/listing_services.dart'; // Import your ListingService

class OfflineQueueService {
  static const String _boxName = 'offline_items';
  final ListingService _listingService =
      ListingService(); // Use the existing service logic

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  // --- 1. QUEUE ITEM (For both ADD and EDIT) ---
  Future<void> queueItem({
    String? listingId, // If null, it's a NEW item. If set, it's an EDIT.
    required String title,
    required double price,
    required String description,
    required String category,
    required String address,
    required List<String> localImagePaths, // New photos from phone gallery
    required List<String>
    existingImageUrls, // Old photos (URLs) kept during edit
    required String userId,
  }) async {
    final box = Hive.box(_boxName);

    final Map<String, dynamic> offlineItem = {
      'action': listingId == null ? 'create' : 'update', // Track action type
      'listingId': listingId,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'address': address,
      'localImagePaths': localImagePaths,
      'existingImageUrls': existingImageUrls,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await box.add(offlineItem);
    print("OFFLINE: Item queued! Action: ${offlineItem['action']}");
  }

  // --- 2. SYNC PROCESS ---
  Future<void> syncPendingItems() async {
    final box = Hive.box(_boxName);
    if (box.isEmpty) return;

    final connectivityResult = await Connectivity().checkConnectivity();
    // Handle connectivity check (support new and old versions)
    bool hasInternet = connectivityResult != ConnectivityResult.none;
    if (connectivityResult is List) {
      hasInternet = !(connectivityResult as List).contains(
        ConnectivityResult.none,
      );
    }

    if (!hasInternet) return;

    print("SYNC: Internet found. Syncing ${box.length} items...");

    // Iterate keys safely
    final keys = box.keys.toList();

    for (var key in keys) {
      final item = box.get(key) as Map;

      try {
        await _processSingleItem(item);
        await box.delete(key); // Remove from queue on success
        print("SYNC: Item '$key' synced successfully.");
      } catch (e) {
        print("SYNC ERROR for item $key: $e");
      }
    }
  }

  // --- 3. PROCESS SINGLE ITEM (Reuse ListingService) ---
  Future<void> _processSingleItem(Map item) async {
    // Convert paths back to File objects
    List<String> paths = List<String>.from(item['localImagePaths'] ?? []);
    List<File> newImageFiles = paths.map((path) => File(path)).toList();

    // Get existing URLs (for edits)
    List<String> existingUrls = List<String>.from(
      item['existingImageUrls'] ?? [],
    );

    // REUSE your existing ListingService logic!
    // This handles image uploading + Firestore saving for both Add and Edit.
    await _listingService.addOrUpdateListing(
      listingId:
          item['listingId'], // If null, it creates. If exists, it updates.
      title: item['title'],
      description: item['description'],
      price: (item['price'] as num).toDouble(),
      category: item['category'],
      address: item['address'] ?? '',
      existingImageUrls: existingUrls,
      newImageFiles: newImageFiles,
      userId: item['userId'],
    );
  }
}
