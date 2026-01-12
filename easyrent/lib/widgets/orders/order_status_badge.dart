import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'ongoing':
        color = Colors.green;
        text = "Item is with you";
        icon = Icons.check_circle;
        break;
      case 'approved':
        color = Colors.blue;
        text = "Ready for Pickup";
        icon = Icons.store;
        break;
      case 'pending':
        color = Colors.orange;
        text = "Waiting for Owner";
        icon = Icons.hourglass_top;
        break;
      default:
        color = Colors.grey;
        text = status.toUpperCase();
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
