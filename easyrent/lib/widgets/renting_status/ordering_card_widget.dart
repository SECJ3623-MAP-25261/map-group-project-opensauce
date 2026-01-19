import 'package:easyrent/models/booking_model.dart';
import 'package:easyrent/models/item_model.dart';
import 'package:easyrent/services/rentee_service.dart';
import 'package:easyrent/widgets/renting_status/cancel_order_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderingCardWidget extends StatefulWidget {
  final ItemModel item;
  final BookingModel bookingDetails;
  final String status;
  final DateTime returnDate;
  final String orderDate;
  final double totalFee;
  final String productId;

  const OrderingCardWidget({
    super.key,
    required this.item,
    required this.bookingDetails,
    required this.returnDate,
    required this.orderDate,
    required this.status,
    required this.totalFee,
    required this.productId,
  });

  @override
  State<OrderingCardWidget> createState() => _OrderingCardWidgetState();
}

class _OrderingCardWidgetState extends State<OrderingCardWidget> {

  bool cancelledItem = false;
  RenteeService renteeService = RenteeService();
  Future<bool> _handleReportSubmission(String reason, BookingModel item) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

Future<void> _cancelOrderApiCall(
  String orderId,
  String newStatus,
  String productId,
) async {
  try {
    await renteeService.updateItemStatus(orderId, newStatus);
    await renteeService.decreaseItemOrderCounts(productId: productId);
    
    // Check if the widget still exists before updating local state
    if (mounted) {
      setState(() {
        cancelledItem = true;
      });
    }
  } catch (e) {
    print("Error cancelling order: $e");
    // Optionally show a SnackBar here
  }
}

  // void _showQRCodeDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (context) => RenteeQRDialog(
  //       item: widget.item,
  //       orderDate: widget.orderDate,
  //       totalFee: widget.totalFee,
  //       currentStatus: widget.status,
  //       onSimulateScan: () => _simulatePickupScan(context),
  //       showSimulateButton: kIsWeb,
  //     ),
  //   );
  // }

  // --- FIXED METHOD START ---
  Future<void> _simulatePickupScan(BuildContext context) async {
    // 1. Capture the navigator BEFORE the async gap
    final navigator = Navigator.of(context);
  
    try {
      if (widget.status.toLowerCase() != 'pending') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cannot pickup ${widget.status} item")),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
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

      // 2. Perform DB Update
      await renteeService.updateItemStatus(
        widget.bookingDetails.itemId,
        'renting',
      );

      // 3. Pop the dialog unconditionally using the captured navigator
      // We do NOT check 'mounted' here, because we must close the dialog
      // even if this widget is about to be disposed (moved to another tab).
      navigator.pop();

      // 4. Show success dialog ONLY if widget is still alive (optional)
      // Since the item moves to another tab, this widget might be unmounted.
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
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
      // Ensure loader is popped on error too
      navigator.pop();
      print('Error simulating pickup scan: $e');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
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
  }
  // --- FIXED METHOD END ---

  String get formattedReturnDate {
    return DateFormat('dd MMM yyyy').format(widget.returnDate);
  }

  @override
  Widget build(BuildContext context) {
    bool canShowQR =
        widget.status.toLowerCase() == 'pending' ||
        widget.status.toLowerCase() == 'renting';

  final String currentStatus = widget.bookingDetails.status.toLowerCase();
  final bool isTaskDone = currentStatus == 'cancelled' || 
                        currentStatus == 'declined' || 
                        currentStatus == 'history' || 
                        cancelledItem;

    String qrButtonText = widget.status.toLowerCase() == 'pending'
        ? 'Pickup QR'
        : 'Return QR';

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
                  widget.item.images.isNotEmpty
                      ? widget.item.images[0]
                      : 'https://www.shutterstock.com/image-vector/missing-picture-page-website-design-600nw-1552421075.jpg',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
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
                          widget.item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Text(
                      //   '${widget.item.quantity} Pcs',
                      //   style: TextStyle(
                      //     color: AppColors.primaryRed,
                      //     fontSize: 13,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Return Date: $formattedReturnDate',
                        style: TextStyle(
                          color: Colors.red,
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
                            "Pickup",
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
                            widget.bookingDetails.status,
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
                    width: double.infinity,
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
                          'Total ${widget.orderDate} days: RM ${widget.totalFee.toStringAsFixed(2)}',
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
                                    isTaskDone? null
                                    : () {
                                        showCancelConfirmationModal(
                                          context: context,
                                          item: widget.item,
                                          onConfirm: (item) =>
                                              _cancelOrderApiCall(
                                                widget.bookingDetails.bookingId,
                                                "declined",
                                                widget.productId,
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

                            // if (canShowQR)
                            //   SizedBox(
                            //     height: 28,
                            //     child: ElevatedButton(
                            //       onPressed: () => _showQRCodeDialog(context),
                            //       style: ElevatedButton.styleFrom(
                            //         backgroundColor: const Color(0xFFF8BE17),
                            //         padding: const EdgeInsets.symmetric(
                            //           horizontal: 10,
                            //         ),
                            //         elevation: 0,
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(4),
                            //         ),
                            //       ),
                            //       child: Row(
                            //         mainAxisSize: MainAxisSize.min,
                            //         children: [
                            //           const Icon(Icons.qr_code, size: 14),
                            //           const SizedBox(width: 4),
                            //           Text(
                            //             qrButtonText,
                            //             style: const TextStyle(
                            //               fontSize: 12,
                            //               color: Colors.black,
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
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
