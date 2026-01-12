import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';

// --- WIDGET 1: STATUS BANNER ---
class RenterOrderStatusBanner extends StatelessWidget {
  final String status;
  final String bookingId;

  const RenterOrderStatusBanner({
    super.key,
    required this.status,
    required this.bookingId,
  });

  Map<String, dynamic> _getStatusData(String status) {
    switch (status) {
      case 'pending':
        return {
          'color': Colors.orange,
          'text': 'Pending Request',
          'icon': Icons.hourglass_empty,
        };
      case 'approved':
        return {
          'color': Colors.blue,
          'text': 'Approved',
          'icon': Icons.thumb_up,
        };
      case 'ongoing':
        return {
          'color': Colors.green,
          'text': 'Ongoing Rental',
          'icon': Icons.play_circle_filled,
        };
      case 'completed':
        return {
          'color': Colors.grey,
          'text': 'Completed',
          'icon': Icons.check_circle,
        };
      case 'declined':
        return {'color': Colors.red, 'text': 'Declined', 'icon': Icons.cancel};
      default:
        return {'color': Colors.black, 'text': status, 'icon': Icons.info};
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData(status);
    final Color statusColor = statusData['color'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: statusColor.withOpacity(0.1),
      child: Column(
        children: [
          Icon(statusData['icon'], size: 40, color: statusColor),
          const SizedBox(height: 12),
          Text(
            statusData['text'].toString().toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Booking ID: #${bookingId.substring(0, 6).toUpperCase()}",
            style: TextStyle(color: statusColor.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET 2: INFO CARD ---
class RenterOrderInfoCard extends StatelessWidget {
  final BookingModel booking;

  const RenterOrderInfoCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Information",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    booking.itemImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.itemTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "RM ${booking.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Color(0xFF800000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.calendar_today,
            "Duration",
            "${DateFormat('dd MMM').format(booking.startDate)} - ${DateFormat('dd MMM').format(booking.endDate)}",
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time,
            "Pickup Time",
            "10:00 AM (Estimated)",
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on,
            "Pickup Location",
            booking.pickupLocation.isNotEmpty
                ? booking.pickupLocation
                : "No address provided",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
