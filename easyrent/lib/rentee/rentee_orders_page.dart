import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/rentee_service.dart';
import '../../models/booking_model.dart'; // Make sure you have this model
import 'order_details_page.dart'; // We will create/link this later

class RenteeOrdersPage extends StatelessWidget {
  const RenteeOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final RenteeService service = RenteeService();

    return Scaffold(
      backgroundColor:
          Colors.grey[50], // Light background makes white cards pop
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF800000),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: service
            .getRenteeOrdersStream(), // This uses the Sorted Stream we made
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No orders yet", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(context, orders[index]);
            },
          );
        },
      ),
    );
  }

  // --- THE CARD WIDGET ---
  Widget _buildOrderCard(BuildContext context, BookingModel order) {
    String dateRange =
        "${DateFormat('dd MMM').format(order.startDate)} - ${DateFormat('dd MMM').format(order.endDate)}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OrderDetailsPage(order: order), // Navigate!
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. IMAGE THUMBNAIL
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[100],
                        child: order.itemImage.isNotEmpty
                            ? Image.network(order.itemImage, fit: BoxFit.cover)
                            : const Icon(Icons.inventory_2, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 2. ORDER DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Status Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  order.itemTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              // CALLING THE CUSTOM STATUS FUNCTION HERE
                              _buildStatusChip(order.status),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Price
                          Text(
                            "RM ${order.totalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Color(0xFF800000),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Dates
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dateRange,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Optional: Divider for cleaner look if you add buttons below later
                // const Divider(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 3. CUSTOM STATUS STYLING ---
  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    IconData? icon;

    // NORMALIZE STATUS STRING
    switch (status.toLowerCase()) {
      case 'ongoing':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle; // <--- TICK ICON
        break;
      case 'approved':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        icon = Icons.thumb_up;
        break;
      case 'pending':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.access_time_filled;
        break;
      case 'completed':
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        icon = Icons.history;
        break;
      case 'cancelled':
      case 'declined':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.cancel;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.black;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...[Icon(icon, size: 14, color: textColor), const SizedBox(width: 4)],
          Text(
            // Capitalize first letter
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
