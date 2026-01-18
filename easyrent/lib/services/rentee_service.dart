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
    if (user == null) throw Exception("User not logged in");

    final batch = _db.batch();

    for (var item in items) {
      DocumentReference bookingRef = _db.collection('bookings').doc();
      DocumentReference cartRef = _db
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(item.cartDocId);

      double rentalTotal = item.totalRentalPrice;
      double grandTotal = rentalTotal + depositPerItem;
      String location = selectedLocations[item.cartDocId] ?? "Contact Owner";

      batch.set(bookingRef, {
        'bookingId': bookingRef.id,
        'itemId': item.itemId,
        'ownerId': item.ownerId,
        'renteeId': user.uid,
        'startDate': Timestamp.fromDate(item.startDate),
        'endDate': Timestamp.fromDate(item.endDate),
        'totalDays': item.days,
        'rentalPrice': rentalTotal,
        'depositAmount': depositPerItem,
        'totalPrice': grandTotal,
        'status': 'pending',
        'pickupLocation': location,
        'itemTitle': item.title,
        'itemImage': item.image,
        'paymentMethod': paymentMethod,
        'isDepositHeldByAdmin': false,
        'isDepositRefunded': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.delete(cartRef);
    }

    await batch.commit();
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

  // --- NEW: CANCEL BOOKING LOGIC ---
  Future<void> cancelBooking(
    String bookingId,
    String ownerId,
    String itemTitle,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // 1. Update Booking Status
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
      'cancelledBy': 'rentee', // Track who cancelled
    });

    // 2. Notify Owner
    // Notification is handled by Cloud Functions (onBookingUpdated trigger)
    // which sends both In-App and Push Notification.
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
