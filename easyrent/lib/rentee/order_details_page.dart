import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/booking_model.dart';
import '../../services/chat_service.dart';
import '../common/chat_page.dart';
import '../../widgets/orders/order_status_badge.dart'; // Import the badge widget

class OrderDetailsPage extends StatefulWidget {
  final BookingModel order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final ChatService _chatService = ChatService();
  bool _isLoadingChat = false;

  void _handleMessageOwner() async {
    setState(() => _isLoadingChat = true);
    try {
      String chatId = await _chatService.getOrCreateChat(widget.order.ownerId);

      final productData = {
        'title': widget.order.itemTitle,
        'image': widget.order.itemImage,
        'price': 'RM ${widget.order.totalPrice.toStringAsFixed(2)}',
        'status': widget.order.status,
        'bookingId': widget.order.bookingId,
      };

      await _chatService.sendProductMessage(chatId, productData);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChatPage(chatId: chatId, otherUserId: widget.order.ownerId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoadingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Order Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF800000),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OrderStatusBadge(status: widget.order.status),
            const SizedBox(height: 16),
            _ItemSummaryCard(
              order: widget.order,
              isLoadingChat: _isLoadingChat,
              onMessageTap: _handleMessageOwner,
            ),
            const SizedBox(height: 16),
            _RentalDetailsCard(order: widget.order),
            const SizedBox(height: 16),
            _PaymentSummaryCard(order: widget.order),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Widget? _buildBottomAction(BuildContext context) {
    if (widget.order.status == 'approved') {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton.icon(
          onPressed: () => _showQRDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF800000),
            padding: const EdgeInsets.symmetric(vertical: 15),
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.qr_code),
          label: const Text("Show Pickup QR Code"),
        ),
      );
    }
    return null;
  }

  void _showQRDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pickup Verification",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                width: 200,
                child: QrImageView(
                  data: widget.order.bookingId,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- LOCAL WIDGETS ---

class _ItemSummaryCard extends StatelessWidget {
  final BookingModel order;
  final bool isLoadingChat;
  final VoidCallback onMessageTap;

  const _ItemSummaryCard({
    required this.order,
    required this.isLoadingChat,
    required this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: order.itemImage.isNotEmpty
                      ? Image.network(order.itemImage, fit: BoxFit.cover)
                      : const Icon(Icons.inventory_2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.itemTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Booking ID: #${order.bookingId.substring(0, 8)}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoadingChat ? null : onMessageTap,
              icon: isLoadingChat
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chat_bubble_outline, size: 18),
              label: Text(isLoadingChat ? "Connecting..." : "Message Owner"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF800000),
                side: const BorderSide(color: Color(0xFF800000)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RentalDetailsCard extends StatelessWidget {
  final BookingModel order;
  const _RentalDetailsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    String startDate = DateFormat('dd MMM yyyy').format(order.startDate);
    String endDate = DateFormat('dd MMM yyyy').format(order.endDate);
    int days = order.endDate.difference(order.startDate).inDays + 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVerticalInfo(Icons.calendar_today, "Duration", "$days Days"),
          const Divider(height: 24),
          _buildVerticalInfo(
            Icons.date_range,
            "Dates",
            "$startDate - $endDate",
          ),
          const Divider(height: 24),
          _buildVerticalInfo(
            Icons.location_on,
            "Pickup At",
            order.pickupLocation,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalInfo(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF800000)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  final BookingModel order;
  const _PaymentSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Paid",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "RM ${order.totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF800000),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
