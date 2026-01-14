import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart'; // Ensure this matches your file path

class RenterService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String _baseUrl =
      "https://us-central1-easyrent-b11f2.cloudfunctions.net/api";

  // --- CACHE: Stores user profiles to prevent flickering on UI updates ---
  final Map<String, Map<String, dynamic>> _userCache = {};

  // ====================================================
  // FEATURE 1: SETTINGS (Address & Bank)
  // ====================================================

  Future<Map<String, dynamic>> loadRenterSettings() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data() == null) return {};

    final data = doc.data() as Map<String, dynamic>;
    return {
      'pickupAddress': data['pickupAddress'] ?? '',
      'bankName': data['payoutDetails']?['bankName'] ?? '',
      'accountNumber': data['payoutDetails']?['accountNumber'] ?? '',
    };
  }

  Future<void> saveRenterSettings({
    required String pickupAddress,
    required String bankName,
    required String accountNumber,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    await _db.collection('users').doc(user.uid).set({
      'pickupAddress': pickupAddress.trim(),
      'payoutDetails': {
        'bankName': bankName.trim(),
        'accountNumber': accountNumber.trim(),
      },
    }, SetOptions(merge: true));
  }

  // ====================================================
  // FEATURE 2: ORDER MANAGEMENT
  // ====================================================

  // 1. STREAM ALL ORDERS FOR THIS RENTER
  Stream<List<BookingModel>> getRenterOrdersStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('bookings')
        .where('ownerId', isEqualTo: user.uid) // Filter: Get items *I* own
        .snapshots()
        .map((snapshot) {
          // Convert Firestore docs to BookingModel objects
          final orders = snapshot.docs
              .map((doc) => BookingModel.fromSnapshot(doc))
              .toList();

          // Sort: 'pending' requests show up first, then sort by date
          orders.sort((a, b) {
            if (a.status == 'pending' && b.status != 'pending') return -1;
            if (a.status != 'pending' && b.status == 'pending') return 1;
            // If status is same, show newest start date first
            return b.startDate.compareTo(a.startDate);
          });

          return orders;
        });
  }

  // 2. APPROVE ORDER
  Future<void> approveOrder(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'approved',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // String localURL = 'http://10.160.34.10/api';
  // 3. DECLINE ORDER
  Future<void> declineOrder(String bookingId, String itemId) async {
    try {
      print("cancelling product");
      final response = await http.post(
        Uri.parse("$_baseUrl/items/decline-items"),
        headers: {
          "Content-Type": "application/json", // Tells the server to expect JSON
        },
        body: jsonEncode({"bookingId": bookingId, "itemId": itemId}),
      );

      if (response.statusCode == 200) {
        print("Order declined successfully");
      } else {
        // Handle server-side errors (e.g., 400 or 500)
        print("Failed to decline order: ${response.body}");
      }
    } catch (e) {
      // Handle network errors
      print("Error connecting to server: $e");
    }
  }

  // 4. GET RENTEE PROFILE (With Caching)
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    // A. Check Memory Cache First
    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }

    // B. If not in cache, fetch from Firestore
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // C. Save to Cache for next time
        _userCache[userId] = data;
        return data;
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // --- NEW: PROCESS PICKUP HANDSHAKE (SCANNER LOGIC) ---
  Future<void> verifyPickupHandshake(String scannedData) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    // 1. Parse Data
    // We assume the Rentee shows a QR code containing JUST the bookingId
    // OR a format like "PICKUP:bookingId". Let's handle both for safety.
    String bookingId = scannedData;
    if (scannedData.startsWith("PICKUP:")) {
      bookingId = scannedData.split(':')[1];
    }
    // If you used the 'RETURN:' format previously, ensure we don't mix them up
    if (scannedData.startsWith("RETURN:")) {
      throw Exception(
        "Wrong QR Code. This is a Return code, not a Pickup code.",
      );
    }

    // 2. Fetch Booking
    DocumentSnapshot doc = await _db
        .collection('bookings')
        .doc(bookingId)
        .get();

    if (!doc.exists) {
      throw Exception("Booking not found.");
    }

    final data = doc.data() as Map<String, dynamic>;

    // 3. Security Checks
    // Ensure the person scanning (Renter) is actually the Owner of this item
    if (data['ownerId'] != currentUser.uid) {
      throw Exception("This booking does not belong to your shop.");
    }

    // Ensure status is correct (Must be 'approved' to start 'ongoing')
    if (data['status'] != 'approved') {
      if (data['status'] == 'ongoing') {
        throw Exception("Item is already picked up.");
      }
      throw Exception("Invalid Status: Item must be 'Approved' before pickup.");
    }

    // 4. Update Status to ONGOING
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'ongoing',
      'pickupTime':
          FieldValue.serverTimestamp(), // Optional: Track actual pickup time
    });
  }

  // ====================================================
  // THE DASHBOARD FETCH (PURE API)
  // ====================================================
  Future<Map<String, dynamic>> getDashboardStats() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    try {
      // 1. Call the Cloud Function
      final response = await http.get(
        Uri.parse("$_baseUrl/dashboard/renter-stats?userId=${user.uid}"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 2. Process Chart Data (String -> DateTime)
        List<dynamic> rawChartData = data['chartData'] ?? [];

        List<Map<String, dynamic>> processedChartData = rawChartData.map((
          item,
        ) {
          return {
            'date': DateTime.parse(item['date']),
            'amount': (item['amount'] ?? 0).toDouble(),
          };
        }).toList();

        // 3. Return Data
        return {
          'totalEarnings': (data['totalEarnings'] ?? 0).toDouble(),
          'activeCount': data['activeCount'] ?? 0,
          'pendingCount': data['pendingCount'] ?? 0,
          'completedCount': data['completedCount'] ?? 0,
          'chartData': processedChartData,
        };
      } else {
        print("Dashboard API Error: ${response.body}");
        return {};
      }
    } catch (e) {
      print("Error fetching dashboard stats: $e");
      return {};
    }
  }
}
