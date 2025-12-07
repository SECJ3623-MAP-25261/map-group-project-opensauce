import 'package:cloud_firestore/cloud_firestore.dart';

class Rental {
  final String id;
  final String status;
  final String? finalStatus;

  // CHANGED: Use String IDs
  final String renterId;
  final String renteeId;
  final String productId;

  final DateTime startDate;
  final DateTime endDate;
  final int rentalDurationDays;
  final double finalTotalPrice;
  final String returnMethods;
  final String? dropoffLocation;
  final String paymentMethods;
  final int daysRemaining;

  Rental({
    required this.id,
    required this.status,
    this.finalStatus,
    required this.renterId,
    required this.renteeId,
    required this.productId,
    required this.startDate,
    required this.endDate,
    required this.rentalDurationDays,
    required this.finalTotalPrice,
    required this.returnMethods,
    this.dropoffLocation,
    required this.paymentMethods,
    required this.daysRemaining,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'final_status': finalStatus,
      'renter': FirebaseFirestore.instance.doc('user/$renterId'),
      'rentee': FirebaseFirestore.instance.doc('user/$renteeId'),
      'product': FirebaseFirestore.instance.doc('product/$productId'),
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

  factory Rental.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw StateError('Rental data missing.');

    DateTime toDate(dynamic ts) => (ts is Timestamp) ? ts.toDate() : DateTime.now();
    
    // Helper to extract ID
    String getId(dynamic value) {
      if (value is DocumentReference) return value.id;
      return '';
    }

    return Rental(
      id: snapshot.id,
      status: data['status'] ?? 'pending',
      finalStatus: data['final_status'],
      renterId: getId(data['renter']),
      renteeId: getId(data['rentee']),
      productId: getId(data['product']),
      startDate: toDate(data['start_date']),
      endDate: toDate(data['end_date']),
      rentalDurationDays: (data['rental_duration_days'] as num?)?.toInt() ?? 0,
      finalTotalPrice: (data['final_total_price'] as num?)?.toDouble() ?? 0.0,
      returnMethods: data['return_methods'] ?? '',
      dropoffLocation: data['dropoff_location'],
      paymentMethods: data['payment_methods'] ?? '',
      daysRemaining: (data['days_remaining'] as num?)?.toInt() ?? 0,
    );
  }
}