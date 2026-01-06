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

  Future<bool> _handleReportSubmission(String reason, Item item) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  Future<void> _cancelOrderApiCall(String orderId, String newStatus) async {
    await RentingStatusDatabaseService().updateItemStatus(orderId, newStatus);
    setState(() {
      cancelledItem = true;
    });
  }

  void _showQRCodeDialog(BuildContext context) {
    final rentalDays = widget.endDate.difference(widget.startDate).inDays;
    print("------------showing dialog-------------");
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => RenteeQRDialog(
            item: widget.item,
            orderDate: rentalDays,
            totalFee: widget.totalPrice,
            currentStatus: widget.status,
            onSimulateScan: () => _simulateReturnScan(context),
            showSimulateButton: kIsWeb,
          ),
    );
  }

  // --- FIXED METHOD START ---
  Future<void> _simulateReturnScan(BuildContext context) async {
    // 1. Capture the navigator BEFORE the async gap
    final navigator = Navigator.of(context);

    try {
      if (widget.status.toLowerCase() != 'renting') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cannot return ${widget.status} item")),
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
                  Text("Processing return verification..."),
                ],
              ),
            ),
      );

      await Future.delayed(const Duration(seconds: 1));

      // 2. Perform DB Update
      await RentingStatusDatabaseService().updateItemStatus(
        widget.item.id,
        'history',
      );

      // 3. Pop unconditionally using captured navigator
      navigator.pop();

      // 4. Show success dialog ONLY if mounted
      if (mounted) {
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
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8BE17),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Done"),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      navigator.pop(); // Ensure pop on error
      print('Error simulating return scan: $e');

      if (mounted) {
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
  }
  // --- FIXED METHOD END ---

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
                          'Total Price: RM${widget.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: [
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
