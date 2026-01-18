import 'package:easyrent/models/booking_model.dart';
import 'package:easyrent/models/item_model.dart';
import 'package:easyrent/services/rentee_service.dart';
import 'package:easyrent/widgets/renting_status/cancel_order_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InrentingCardWidget extends StatefulWidget {
  final ItemModel item;
  final BookingModel bookingDetails;
  final String status;
  final DateTime returnDate;
  final String orderDate;
  final double totalFee;
  final String productId;

  const InrentingCardWidget({
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
  State<InrentingCardWidget> createState() => _InrentingCardWidgetState();
}

class _InrentingCardWidgetState extends State<InrentingCardWidget> {
  bool cancelledItem = false;
  final RenteeService _service = RenteeService();
  
  Future<bool> _handleReportSubmission(String reason, ItemModel item) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  Future<void> _cancelOrderApiCall(String orderId, String newStatus) async {
    await _service.updateItemStatus(orderId, newStatus);
    setState(() {
      cancelledItem = true;
    });
  }

  @override
  String get formattedEndDate {
    return DateFormat('dd MMM yyyy').format(widget.bookingDetails.endDate);
  }

  String get formattedStartDate {
    return DateFormat('dd MMM yyyy').format(widget.bookingDetails.startDate);
  }

  // void _showQRCodeDialog(BuildContext context) {
  //   final rentalDays = widget.endDate.difference(widget.startDate).inDays;
  //   print("------------showing dialog-------------");
  //   showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder:
  //         (context) => RenteeQRDialog(
  //           item: widget.item,
  //           orderDate: rentalDays,
  //           totalFee: widget.totalPrice,
  //           currentStatus: widget.status,
  //           onSimulateScan: () => _simulateReturnScan(context),
  //           showSimulateButton: kIsWeb,
  //         ),
  //   );
  // }
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
                  widget.item.images.isNotEmpty
                      ? widget.item.images[0]
                      : 'https://www.shutterstock.com/image-vector/missing-picture-page-website-design-600nw-1552421075.jpg',
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
                          widget.item.title,
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
                          'Total Price: RM${widget.bookingDetails.totalPrice.toStringAsFixed(2)}',
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
                                    widget.bookingDetails.status == 'cancelled' ||
                                            cancelledItem == true
                                        ? null
                                        : () {
                                          showCancelConfirmationModal(
                                            context: context,
                                            item: widget.item,
                                            onConfirm:
                                                (item) => _cancelOrderApiCall(
                                                  widget.bookingDetails.bookingId,
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
                            // if (widget.status.toLowerCase() == 'renting')
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
                            //       child: const Row(
                            //         mainAxisSize: MainAxisSize.min,
                            //         children: [
                            //           Icon(Icons.qr_code, size: 14),
                            //           SizedBox(width: 4),
                            //           Text(
                            //             'Return QR',
                            //             style: TextStyle(
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
