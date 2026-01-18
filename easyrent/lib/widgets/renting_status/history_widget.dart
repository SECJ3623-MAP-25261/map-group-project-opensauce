import 'package:easyrent/core/parse_date.dart';
import 'package:easyrent/models/booking_model.dart';
import 'package:easyrent/models/item_model.dart';
import 'package:easyrent/services/rentee_service.dart';
import 'package:easyrent/widgets/renting_status/history_item_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryWidget extends StatefulWidget {
  const HistoryWidget({super.key});

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  final RenteeService _service = RenteeService();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _service.getHistoryItem(currentUserId), // Changed to Future
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (asyncSnapshot.hasError) {
            return Center(child: Text('Error: ${asyncSnapshot.error}'));
          }

          final bookings = asyncSnapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(child: Text('No ordering items found.'));
          }

          return ListView(
            // Use ListView instead of Column for scrollability
            padding: const EdgeInsets.all(16),
            children: bookings.map((booking) {
              final String itemId = booking['itemId']?.toString() ?? '';
              print("=-------------item: ${booking['itemDetails']}====================================");
             final ItemModel itemDetails = booking['itemDetails'] as ItemModel;
              final endRenting = parseDate(booking['endDate']);

              final cleanMap = Map<String, dynamic>.from(booking);
              cleanMap.remove('itemDetails');
              cleanMap.remove('id');
              final duration = booking['totalDays'] ?? 0;
              final BookingModel bookingModel = BookingModel.fromMap(cleanMap);
              return HistoryItemCard(
                duration: duration,
                item: itemDetails,
                bookingDetails: bookingModel,
                orderDate: booking['totalDays']?.toString() ?? '0',
                returnDate: endRenting ?? DateTime.now(),
                status: booking['status'],
                totalFee: (booking['totalPrice'] as num?)?.toDouble() ?? 0.0,
                productId: itemId,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}