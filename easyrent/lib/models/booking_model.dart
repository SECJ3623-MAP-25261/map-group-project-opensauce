import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingModel {
  final String bookingId;
  final String itemId;
  final String itemTitle;
  final String itemImage;
  final String pickupLocation;
  final String status; // pending, approved, ongoing, completed, cancelled
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String ownerId;
  final String renteeId;

  BookingModel({
    required this.bookingId,
    required this.itemId,
    required this.itemTitle,
    required this.itemImage,
    required this.pickupLocation,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.ownerId,
    required this.renteeId,
  });

  factory BookingModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      bookingId: data['bookingId'] ?? doc.id,
      itemId: data['itemId'] ?? '',
      itemTitle: data['itemTitle'] ?? 'Unknown Item',
      itemImage: data['itemImage'] ?? '',
      pickupLocation: data['pickupLocation'] ?? 'Contact Owner',
      status: data['status'] ?? 'pending',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      totalPrice: double.tryParse(data['totalPrice'].toString()) ?? 0.0,
      ownerId: data['ownerId'] ?? '',
      renteeId: data['renteeId'] ?? '',
    );
  }

  // --- LOGIC: Derived Properties ---

  String get dateRangeText {
    return "${DateFormat('dd MMM').format(startDate)} - ${DateFormat('dd MMM').format(endDate)}";
  }

  bool get isOverdue {
    // It is overdue if status is 'ongoing' AND today is after the end date
    if (status != 'ongoing') return false;
    final now = DateTime.now();
    // Compare dates (ignoring time if you prefer, but strict comparison is safer)
    return now.isAfter(endDate);
  }

  // Helper to get display color/text for UI
  Map<String, dynamic> get statusDisplay {
    if (status == 'pending') {
      return {
        'text': 'Pending Approval',
        'color': Colors.orange,
        'icon': Icons.hourglass_empty,
      };
    } else if (status == 'approved') {
      return {
        'text': 'Ready for Pickup',
        'color': Colors.blue,
        'icon': Icons.store,
      };
    } else if (status == 'ongoing') {
      if (isOverdue) {
        return {
          'text': 'Overdue / Late',
          'color': Colors.red,
          'icon': Icons.warning,
        };
      }
      return {
        'text': 'On-going',
        'color': Colors.green,
        'icon': Icons.directions_car,
      };
    } else if (status == 'completed') {
      return {
        'text': 'Completed',
        'color': Colors.grey,
        'icon': Icons.check_circle,
      };
    } else if (status == 'rejected' || status == 'cancelled') {
      return {
        'text': 'Cancelled',
        'color': Colors.red[900],
        'icon': Icons.cancel,
      };
    }
    return {
      'text': status.toUpperCase(),
      'color': Colors.grey,
      'icon': Icons.info,
    };
  }
}
