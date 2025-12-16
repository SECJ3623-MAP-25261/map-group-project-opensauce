import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/features/models/item.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/cancel_order_widget.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/report_item_widget.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/rentee_qr_dialog.dart';
import 'package:easyrent/features/rentee/renting_status/services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class InrentingItemCardWidget extends StatefulWidget {
  final Item item;
  final String status;
  final double totalPrice;
  final DateTime startDate;
  final DateTime endDate;
  final String returnMethods;

  const InrentingItemCardWidget({
    super.key,
    required this.item,
    required this.status,
    required this.totalPrice,
    required this.startDate,
    required this.endDate,
    required this.returnMethods,
  });

  @override
  State<InrentingItemCardWidget> createState() =>
      _InrentingItemCardWidgetState();
}

class _InrentingItemCardWidgetState extends State<InrentingItemCardWidget> {
  bool cancelledItem = false;

  // This is the function that simulates the API call to report the item
  Future<bool> _handleReportSubmission(String reason, Item item) async {
    print('Reporting item: with ${item.productName} name and ${item.id} id');
    print('Reason: $reason');

    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate a successful submission 80% of the time
    final isSuccessful = DateTime.now().millisecond % 10 < 8;

    return isSuccessful;
  }

  Future<void> _cancelOrderApiCall(String orderId, String newStatus) async {
    print('Attempting to cancel order $orderId...');
    await RentingStatusDatabaseService().updateItemStatus(orderId, newStatus);

    if (DateTime.now().millisecond % 10 < 2) {
      throw Exception('Server error: Could not process cancellation.');
    }
    setState(() {
      cancelledItem = true;
    });
    print('Order $orderId successfully cancelled.');
  }

  // Function to show QR dialog
  void _showQRCodeDialog(BuildContext context) {
    // Calculate rental days
    final rentalDays = widget.endDate.difference(widget.startDate).inDays;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => RenteeQRDialog(
            item: widget.item,
            orderDate: rentalDays,
            totalFee: widget.totalPrice.toInt(),
            currentStatus: widget.status,
            onSimulateScan: () => _simulateReturnScan(context),
            showSimulateButton: kIsWeb,
          ),
    );
  }

  // Function to simulate return scanning
  Future<void> _simulateReturnScan(BuildContext context) async {
    try {
      print('Simulating return scan for item: ${widget.item.id}');
      print('Current status: ${widget.status}');

      // Only allow return simulation for renting items
      if (widget.status.toLowerCase() != 'renting') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cannot return ${widget.status} item")),
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Processing return verification..."),
                ],
              ),
            ),
      );

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Update item status to 'history' via API
      await RentingStatusDatabaseService().updateItemStatus(
        widget.item.id,
        'history',
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              contentPadding: const EdgeInsets.all(20),
              title: const Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 60),
                  SizedBox(height: 10),
                  Text(
                    "Return Verified",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: const Text(
                "Item return confirmed!\n\nStatus updated to 'history'.\n\nItem will now appear in History tab.",
                textAlign: TextAlign.center,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    // ðŸ›‘ FIX: Removed setState((){}) - The Firestore stream will handle the UI refresh.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8BE17),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Done"),
                ),
              ],
            ),
      );
    } catch (e) {
      print('Error simulating return scan: $e');
      if (mounted) Navigator.pop(context); // Close loading dialog

      // Show error dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Error"),
              content: Text("Failed to verify return: $e"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  @override
  String get formattedEndDate {
    return DateFormat('dd MMM yyyy').format(widget.endDate);
  }

  String get formattedStartDate {
    return DateFormat('dd MMM yyyy').format(widget.startDate);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side: Image
            SizedBox(
              width: 80,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.item.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Right Side: Details and Actions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Title, Item Count, Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Return Date: $formattedEndDate',
                        style: TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Rental Rate
                  Row(
                    children: [
                      Text(
                        'RM ${widget.item.pricePerDay} / day',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        height: 28,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.returnMethods,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 28,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.status,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Total Rental Summary (The Yellow Section)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Price: RM${widget.totalPrice}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Cancel Order Button
                            SizedBox(
                              height: 28,
                              child: ElevatedButton(
                                onPressed:
                                    widget.status == 'cancelled' ||
                                            cancelledItem == true
                                        ? null
                                        : () {
                                          showCancelConfirmationModal(
                                            context: context,
                                            item: widget.item,
                                            onConfirm:
                                                (item) => _cancelOrderApiCall(
                                                  widget.item.id,
                                                  'cancel',
                                                ),
                                          );
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  'Cancel Order',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        widget.status == 'cancelled' ||
                                                cancelledItem == true
                                            ? Colors.grey
                                            : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // QR Code Button for Return Verification
                            if (widget.status.toLowerCase() == 'renting')
                              SizedBox(
                                height: 28,
                                child: ElevatedButton(
                                  onPressed: () => _showQRCodeDialog(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF8BE17),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.qr_code, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'Return QR',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (widget.status.toLowerCase() == 'renting')
                              const SizedBox(width: 8),

                            // Report Button (Red)
                            SizedBox(
                              height: 28,
                              child: ReportItemWidget(
                                onSubmitReport: _handleReportSubmission,
                                item: widget.item,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
