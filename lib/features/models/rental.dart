import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyrent/features/models/item.dart';
import 'package:easyrent/features/rentee/rentee_profile/domain/user.dart';

class Rental {
  final String id;
  
  final String status; // 'pending_approval', 'approved', 'in_progress', 'completed', 'cancelled'
  final String? finalStatus; // 'damaged' vs 'completed'

  final User renter; // ID of the User who owns the item (Renter)
  final User rentee; // ID of the User who is borrowing the item (Rentee)

  final Item product; // ID of the Item being rented

  // --- Pricing & Timing ---
  final DateTime startDate;
  final DateTime endDate;
  final int rentalDurationDays;
  final double finalTotalPrice;

  // --- Logistics & Payment ---
  final String returnMethods; // Delivery , PickUp
  final String? dropoffLocation; 
  final String paymentMethods; // Cash up,
  
  // --- Calculated Field (Client-Side or Function) ---
  // daysRemaining is usually calculated on the client side based on DateTime.now() and endDate, 
  // but included here if you intend to store it for quick server checks.
  final int daysRemaining; 

  Rental({
    required this.id,
    required this.status,
    this.finalStatus,
    required this.renter,
    required this.rentee,
    required this.product,
    required this.startDate,
    required this.endDate,
    required this.rentalDurationDays,
    required this.finalTotalPrice,
    required this.returnMethods,
    this.dropoffLocation,
    required this.paymentMethods,
    required this.daysRemaining,
  });

  // --- Serialization (To Firebase/Map) ---
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'final_status': finalStatus,
      'renter': renter,
      'rentee': rentee,
      // Convert DateTime to Firestore Timestamp
      'start_date': Timestamp.fromDate(startDate), 
      'end_date': Timestamp.fromDate(endDate),
      'rental_duration_days': rentalDurationDays,
      'final_total_price': finalTotalPrice,
      'return_methods': returnMethods,
      'dropoff_location': dropoffLocation,
      'payment_methods': paymentMethods,
      'days_remaining': daysRemaining,
    };
  }

  // --- Deserialization (From Firebase/Map) ---
  factory Rental.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Rental data is missing from Firestore snapshot.');
    }
    
    // Helper function to safely convert Timestamp to DateTime
    DateTime _toDateTime(dynamic ts) => (ts is Timestamp) ? ts.toDate() : DateTime.now();

    return Rental(
      id: snapshot.id, // **CRITICAL**: Document ID
      status: data['status'] ?? 'pending_approval',
      finalStatus: data['final_status'],
      rentee: data['rentee'] ?? '',
      renter: data['renter'] ?? '',
      product: data['product'] ?? 'N/A',      
      startDate: _toDateTime(data['start_date']),
      endDate: _toDateTime(data['end_date']),
      rentalDurationDays: data['rental_duration_days'] ?? 0,
      finalTotalPrice: (data['final_total_price'] as num?)?.toDouble() ?? 0.0,
      
      returnMethods: data['return_methods'] ?? 'N/A',
      dropoffLocation: data['dropoff_location'],
      paymentMethods: data['payment_methods'] ?? 'N/A',
      daysRemaining: data['days_remaining'] ?? 0,
    );
  }
}