import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/core/utils/convert_to_frontend_string.dart';
import 'package:easyrent/features/models/item.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/cancel_order_widget.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/report_item_widget.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/rentee_qr_dialog.dart';
import 'package:easyrent/features/rentee/renting_status/services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class RentalItemCardWidget extends StatefulWidget {
  final Item item;
  final String status;
  final DateTime returnDate;
  final int orderDate;
  // CHANGE: Updated type from int to double
  final double totalFee; 

  const RentalItemCardWidget({
    super.key,
    required this.item,
    required this.returnDate,
    required this.orderDate,
    required this.status,
    required this.totalFee,
  });

  @override
  State<RentalItemCardWidget> createState() => _RentalItemCardWidgetState();
}

class _RentalItemCardWidgetState extends State<RentalItemCardWidget> {
  bool cancelledItem = false;

  Future<bool> _handleReportSubmission(String reason, Item item) async {
    print('Reporting item: with ${item.productName} name and ${item.id} id');
    print('Reason: $reason');

    await Future.delayed(const Duration(seconds: 2));
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

  void _showQRCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => RenteeQRDialog(
            item: widget.item,
            orderDate: widget.orderDate,
            totalFee: widget.totalFee, // Ensure RenteeQRDialog also accepts double!
            currentStatus: widget.status, 
            onSimulateScan: () => _simulatePickupScan(context),
            showSimulateButton: kIsWeb,
          ),
    );
  }

  Future<void> _simulatePickupScan(BuildContext context) async {
    try {
      print('Simulating pickup scan for item: ${widget.item.id}');
      print('Current status: ${widget.status}');

      if (widget.status.toLowerCase() != 'pending') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cannot pickup ${widget.status} item")),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Processing pickup verification..."),
                ],
              ),
            ),
      );

      await Future.delayed(const Duration(seconds: 1));

      await RentingStatusDatabaseService().updateItemStatus(
        widget.item.id,
        'renting',
      );

      if (mounted) Navigator.pop(context);

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
                    "Pickup Verified",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: const Text(
                "Item pickup confirmed!\n\nStatus updated to 'renting'.\n\nItem will now appear in In Renting tab.",
                textAlign: TextAlign.center,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
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
      print('Error simulating pickup scan: $e');
      if (mounted) Navigator.pop(context);

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Error"),
              content: Text("Failed to verify pickup: $e"),
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

  String get formattedReturnDate {
    return DateFormat('dd MMM yyyy').format(widget.returnDate);
  }

  @override
  Widget build(BuildContext context) {
    bool canShowQR =
        widget.status.toLowerCase() == 'pending' ||
        widget.status.toLowerCase() == 'renting';

    String qrButtonText =
        widget.status.toLowerCase() == 'pending' ? 'Pickup QR' : 'Return QR';

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      Text(
                        '${widget.item.quantity} Pcs',
                        style: TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Return Date: $formattedReturnDate',
                        style: TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'RM ${widget.item.pricePerDay} / day',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
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
                            widget.item.deliveryMethods,
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
                            convertToFrontendString(widget.status),
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
                        // CHANGE: Format double with toStringAsFixed(2)
                        Text(
                          'Total ${widget.orderDate} days: RM ${widget.totalFee.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 28,
                              child: ElevatedButton(
                                onPressed:
                                    widget.status.toLowerCase() ==
                                                'cancelled' ||
                                            cancelledItem == true ||
                                            widget.status.toLowerCase() ==
                                                'history'
                                        ? null
                                        : () {
                                          showCancelConfirmationModal(
                                            context: context,
                                            item: widget.item,
                                            onConfirm:
                                                (item) => _cancelOrderApiCall(
                                                  widget.item.id,
                                                  "history",
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
                                        widget.status.toLowerCase() ==
                                                    'cancelled' ||
                                                cancelledItem == true ||
                                                widget.status.toLowerCase() ==
                                                    'history'
                                            ? Colors.grey
                                            : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            SizedBox(
                              height: 28,
                              child: ReportItemWidget(
                                onSubmitReport: _handleReportSubmission,
                                item: widget.item,
                              ),
                            ),

                            const SizedBox(width: 8),

                            if (canShowQR)
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.qr_code, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        qrButtonText,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
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