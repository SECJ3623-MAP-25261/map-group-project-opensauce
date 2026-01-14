import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/booking_model.dart';
import '../../services/renter_service.dart';
import '../../services/chat_service.dart';
import '../common/chat_page.dart';

class RenterOrderDetailPage extends StatefulWidget {
  final String bookingId;

  const RenterOrderDetailPage({super.key, required this.bookingId});

  @override
  State<RenterOrderDetailPage> createState() => _RenterOrderDetailPageState();
}

class _RenterOrderDetailPageState extends State<RenterOrderDetailPage> {
  final ChatService _chatService = ChatService();
  bool _isLoadingChat = false;

  // --- LOGIC: MESSAGE RENTEE ---
  Future<void> _handleMessageRentee(
    String renteeId,
    String renteeName,
    BookingModel booking,
  ) async {
    setState(() => _isLoadingChat = true);

    try {
      String chatId = await _chatService.getOrCreateChat(renteeId);

      final productData = {
        'title': booking.itemTitle,
        'image': booking.itemImage,
        'price': 'RM ${booking.totalPrice.toStringAsFixed(2)}',
        'status': booking.status,
        'bookingId': booking.bookingId,
      };
      await _chatService.sendProductMessage(chatId, productData);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(chatId: chatId, otherUserId: renteeId),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoadingChat = false);
    }
  }

  // --- LOGIC: SHOW RETURN QR CODE ---
  void _showReturnQRDialog(String bookingId) {
    // Safety check
    if (bookingId.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor:
            Colors.white, // Ensures pure white on newer Android/iOS
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Shrink to fit content
          children: [
            const Text(
              "Return Verification",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Container with FIXED height/width is crucial for QrImageView in Dialogs
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: QrImageView(
                    data: 'RETURN:$bookingId',
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Show this to the Rentee.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(color: Color(0xFF800000)),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get status data safely
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
          'icon': Icons.check_circle,
        };
      case 'completed':
        return {'color': Colors.grey, 'text': 'Completed', 'icon': Icons.info};
      case 'declined':
        return {'color': Colors.red, 'text': 'Declined', 'icon': Icons.cancel};
      default:
        return {'color': Colors.grey, 'text': status, 'icon': Icons.info};
    }
  }

  @override
  Widget build(BuildContext context) {
    final RenterService renterService = RenterService();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Order not found"));
          }

          final booking = BookingModel.fromSnapshot(snapshot.data!);

          // Get Status Style
          final statusData = _getStatusData(booking.status);
          final Color statusColor = statusData['color'];

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. STATUS BANNER (New!)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
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
                        "Booking ID: #${booking.bookingId.substring(0, 6).toUpperCase()}",
                        style: TextStyle(
                          color: statusColor.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 2. RENTEE PROFILE CARD
                      _RenteeProfileCard(
                        renteeId: booking.renteeId,
                        isLoadingChat: _isLoadingChat,
                        onMessageTap: (fetchedName) => _handleMessageRentee(
                          booking.renteeId,
                          fetchedName,
                          booking,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 3. ORDER DETAILS CARD
                      Container(
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        booking.itemTitle,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
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
                              Icons.location_on,
                              "Pickup Location",
                              booking.pickupLocation.isNotEmpty
                                  ? booking.pickupLocation
                                  : "No address provided",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 4. ACTION BUTTONS

                      // A) Pending: Approve / Decline
                      if (booking.status == 'pending')
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  renterService.declineOrder(booking.bookingId,booking.itemId);
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text("Decline"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => renterService.approveOrder(
                                  booking.bookingId,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text("Approve"),
                              ),
                            ),
                          ],
                        ),

                      // B) Ongoing: Show Return QR Code Button
                      if (booking.status == 'ongoing')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _showReturnQRDialog(booking.bookingId),
                            icon: const Icon(Icons.qr_code),
                            label: const Text("Show Return QR Code"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF800000),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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

// --- STABLE PROFILE CARD ---
class _RenteeProfileCard extends StatefulWidget {
  final String renteeId;
  final bool isLoadingChat;
  final Function(String name) onMessageTap;

  const _RenteeProfileCard({
    required this.renteeId,
    required this.isLoadingChat,
    required this.onMessageTap,
  });

  @override
  State<_RenteeProfileCard> createState() => _RenteeProfileCardState();
}

class _RenteeProfileCardState extends State<_RenteeProfileCard> {
  late Future<Map<String, dynamic>> _profileFuture;
  final RenterService _service = RenterService();

  @override
  void initState() {
    super.initState();
    _profileFuture = _service.getUserProfile(widget.renteeId);
  }

  @override
  void didUpdateWidget(covariant _RenteeProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.renteeId != oldWidget.renteeId) {
      _profileFuture = _service.getUserProfile(widget.renteeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        String renteeName = "";
        String renteeImage = "";

        if (snapshot.connectionState == ConnectionState.waiting) {
          renteeName = "Loading...";
        } else if (snapshot.hasData) {
          renteeName =
              snapshot.data!['displayName'] ??
              snapshot.data!['username'] ??
              "Unknown Rentee";
          renteeImage = snapshot.data!['profileImage'] ?? "";
        } else {
          renteeName = "Unknown Rentee";
        }

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
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[200],
                backgroundImage: renteeImage.isNotEmpty
                    ? NetworkImage(renteeImage)
                    : null,
                child: renteeImage.isEmpty
                    ? const Icon(Icons.person, size: 35, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                renteeName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Rentee",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: widget.isLoadingChat
                    ? const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: () => widget.onMessageTap(
                          renteeName == "Loading..." ? "Rentee" : renteeName,
                        ),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text("Message Rentee"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF800000),
                          side: const BorderSide(color: Color(0xFF800000)),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
