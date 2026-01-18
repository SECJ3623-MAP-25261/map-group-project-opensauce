import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/item_model.dart';
import '../models/cart_model.dart';
import '../models/booking_model.dart';

class RenteeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String _baseUrl =
      "https://us-central1-easyrent-b11f2.cloudfunctions.net/api";

  // Fetch "Most Rented" (Calculated on Server)
  Future<List<Map<String, dynamic>>> fetchMostRented() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/items/most-rented"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching most rented: $e");
      return [];
    }
  }

  // Fetch "New Arrivals" (Sorted on Server)
  Future<List<Map<String, dynamic>>> fetchNewItems() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/items/new-arrivals"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching new items: $e");
      return [];
    }
  }

  Future<ItemModel> getCartItemDetailsById(String id) async {
    final doc = await _db.collection('items').doc(id).get();

    // 1. Get the data as a map
    Map<String, dynamic>? data = doc.data();

    if (data != null) {
      // 2. Create a modifiable copy and remove the problematic timestamps
      data = Map<String, dynamic>.from(data);
      data.remove('createdAt');
      data.remove('updatedAt');
    }

    print("========== Cleaned data for item: $data ==========");

    // 3. Pass the cleaned map to your fromMap factory instead of fromSnapshot
    // This prevents the factory from ever seeing the Timestamps
    return ItemModel.fromMap(data ?? {});
  }

  Stream<List<Map<String, dynamic>>> getOrderingItems(String userId) {
    return _db
        .collection('bookings')
        .where('renteeId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots() // 1. Listen for real-time changes
        .asyncMap((snapshot) async {
          // 2. Use asyncMap to handle the nested Future

          List<Map<String, dynamic>> results = [];

          for (var doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data();
            String itemId = data['itemId'] ?? '';

            try {
              // 3. Fetch the item details for each booking in the stream
              final itemDetails = await getCartItemDetailsById(itemId);

              data['id'] = doc.id;
              data['itemDetails'] = itemDetails;
              results.add(data);
            } catch (e) {
              print("Error fetching details for $itemId: $e");
              // Optionally add the data without details so the app doesn't crash
              results.add(data);
            }
          }

          return results;
        });
  }

  Stream<List<Map<String, dynamic>>> getInRentingItems(String userId) {
    return _db
        .collection('bookings')
        .where('renteeId', isEqualTo: userId)
        .where('status', isEqualTo: 'approved')
        .snapshots() // 1. Listen for real-time changes
        .asyncMap((snapshot) async {
          // 2. Use asyncMap to handle the nested Future

          List<Map<String, dynamic>> results = [];

          for (var doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data();
            String itemId = data['itemId'] ?? '';

            try {
              // 3. Fetch the item details for each booking in the stream
              final itemDetails = await getCartItemDetailsById(itemId);

              data['id'] = doc.id;
              data['itemDetails'] = itemDetails;
              results.add(data);
            } catch (e) {
              print("Error fetching details for $itemId: $e");
              // Optionally add the data without details so the app doesn't crash
              results.add(data);
            }
          }

          return results;
        });
  }

  Stream<List<Map<String, dynamic>>> getHistoryItem(String userId) {
    return _db
        .collection('bookings')
        .where('renteeId', isEqualTo: userId)
        .where('status', whereIn: ["completed", "declined","approved"])
        .snapshots() // 1. Listen for real-time changes
        .asyncMap((snapshot) async {
          // 2. Use asyncMap to handle the nested Future

          List<Map<String, dynamic>> results = [];

          for (var doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data();
            String itemId = data['itemId'] ?? '';

            try {
              // 3. Fetch the item details for each booking in the stream
              final itemDetails = await getCartItemDetailsById(itemId);

              data['id'] = doc.id;
              data['itemDetails'] = itemDetails;
              results.add(data);
            } catch (e) {
              print("Error fetching details for $itemId: $e");
              // Optionally add the data without details so the app doesn't crash
              results.add(data);
            }
          }

          return results;
        });
  }

  Future<void> updateItemStatus(String orderId, String newStatus) async {
    print("---------- Updating order $orderId to status $newStatus ----------");
    final orderRef = _db.collection('bookings').doc(orderId);

    await orderRef.update({'status': newStatus});
  }

  Future<bool> decreaseItemOrderCounts({required String productId}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/items/decrease-orderCounts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'itemId': productId}),
      );

      if (response.statusCode == 400) {
        print(
          '---------- Failed to  decrease orderCounts for: $productId ----------',
        );
        return false;
      }

      if (response.statusCode == 200) {
        print(
          '---------- Successfully updated orderCounts for: $productId ----------',
        );
        return true;
      }

      return false;
    } catch (e) {
      // Handle specific cases (like the document being deleted mid-process)
      print('Firebase Update Error: ${e}');
      return false;
    }
  }
  // // --- MARKET LOGIC ---
  // Stream<QuerySnapshot> getNewArrivals() {
  //   return _db
  //       .collection('items')
  //       .where('isAvailable', isEqualTo: true)
  //       .orderBy('createdAt', descending: true)
  //       .snapshots();
  // }

  // Stream<QuerySnapshot> getItemsByCategory(String category) {
  //   return _db
  //       .collection('items')
  //       .where('isAvailable', isEqualTo: true)
  //       .where('category', isEqualTo: category)
  //       .snapshots();
  // }

  // --- WISHLIST LOGIC ---
  Stream<bool> isItemWishlisted(String itemId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(itemId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Future<bool> toggleWishlist(ItemModel item) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Login required");

    final docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(item.id);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.delete();
      return false; // Removed
    } else {
      await docRef.set({
        'itemId': item.id,
        'title': item.title,
        'price': item.pricePerDay,
        'image': item.firstImage ?? '',
        'description': item.description,
        'ownerId': item.ownerId,
        'addedAt': FieldValue.serverTimestamp(),
      });
      return true; // Added
    }
  }

  // --- CART LOGIC ---
  Stream<List<CartItemModel>> getCartStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CartItemModel.fromSnapshot(doc))
              .toList(),
        );
  }

  Future<void> removeFromCart(String cartDocId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(cartDocId)
        .delete();
  }

  Future<void> updateCartDates(
    String cartDocId,
    DateTime start,
    DateTime end,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(cartDocId)
        .update({
          'startDate': Timestamp.fromDate(start),
          'endDate': Timestamp.fromDate(end),
        });
  }

  // --- CHECKOUT LOGIC (Fixes the Payment Page Error) ---
  Future<void> processCheckout({
    required List<CartItemModel> items,
    required String paymentMethod,
    required Map<String, String?> selectedLocations,
    required double depositPerItem,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      print("User not logged in");
      return;
    }

    try {
      print("Processing checkout via Cloud Function...");

      final response = await http.post(
        Uri.parse(
          "$_baseUrl/items/place-order",
        ), // Ensure this matches your Function trigger URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": user.uid,
          "paymentMethod": paymentMethod,
          "depositPerItem": depositPerItem,
          "selectedLocations": selectedLocations,
          // Map the list of items to a list of JSON maps
          "items": items
              .map(
                (item) => {
                  "cartDocId": item.cartDocId,
                  "itemId": item.itemId,
                  "ownerId": item.ownerId,
                  "title": item.title,
                  "image": item.image,
                  "totalRentalPrice": item.totalRentalPrice,
                  "days": item.days,
                  // Convert DateTime to ISO8601 strings for the backend
                  "startDate": item.startDate.toIso8601String(),
                  "endDate": item.endDate.toIso8601String(),
                },
              )
              .toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Checkout Success: ${data['message']}");
      } else {
        print("Checkout Failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error connecting to server: $e");
    }
  }

  // --- NEW: ORDERS LOGIC ---
  Stream<List<BookingModel>> getRenteeOrdersStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('bookings')
        .where('renteeId', isEqualTo: user.uid)
        // We still sort by time first so items within the same status are ordered by date
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => BookingModel.fromSnapshot(doc))
              .toList();

          // CUSTOM SORTING LOGIC
          orders.sort((a, b) {
            int rankA = _getStatusRank(a.status);
            int rankB = _getStatusRank(b.status);
            return rankA.compareTo(rankB);
          });

          return orders;
        });
  }

  // Helper function to assign priority (Lower number = Higher position)
  int _getStatusRank(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return 1; // Highest Priority
      case 'approved':
        return 2; // Ready for pickup
      case 'pending':
        return 3; // Waiting for owner
      case 'completed':
      case 'returned':
      case 'declined':
      case 'cancelled':
        return 4; // History (Bottom)
      default:
        return 5;
    }
  }

  // --- NEW: PROCESS RETURN HANDSHAKE (SCANNER LOGIC) ---
  Future<void> verifyReturnHandshake(String scannedData) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    // 1. Validate QR Format
    // Format must be "RETURN:bookingId123"
    final parts = scannedData.split(':');
    if (parts.length != 2 || parts[0] != 'RETURN') {
      throw Exception(
        "Invalid QR Code. Please scan the correct Renter's Return Code.",
      );
    }

    String bookingId = parts[1];

    // 2. Fetch the Booking
    DocumentSnapshot doc = await _db
        .collection('bookings')
        .doc(bookingId)
        .get();

    if (!doc.exists) {
      throw Exception("Booking not found in system.");
    }

    final data = doc.data() as Map<String, dynamic>;

    // 3. Security Checks
    // Ensure the person scanning is actually the Rentee of this order
    if (data['renteeId'] != currentUser.uid) {
      throw Exception("This booking does not belong to you.");
    }

    // Ensure it hasn't already been completed
    if (data['status'] == 'completed') {
      throw Exception("This order is already completed.");
    }

    // 4. Update Status to Completed
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'completed',
      'returnedAt': FieldValue.serverTimestamp(),
    });
  }
}
