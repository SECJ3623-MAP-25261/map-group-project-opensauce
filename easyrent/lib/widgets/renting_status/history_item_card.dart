import 'package:easyrent/models/booking_model.dart';
import 'package:easyrent/models/item_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryItemCard extends StatefulWidget {
  final ItemModel item;
  final BookingModel bookingDetails;
  final String status;
  final DateTime returnDate;
  final String orderDate;
  final double totalFee;
  final String productId;
  final int duration;
  
  const HistoryItemCard({
    super.key,
    required this.item,
    required this.bookingDetails,
    required this.returnDate,
    required this.orderDate,
    required this.status,
    required this.totalFee,
    required this.productId,
    required this.duration,
  });

  @override
  State<HistoryItemCard> createState() => _HistoryItemCardState();
}

class _HistoryItemCardState extends State<HistoryItemCard> {
  @override
  String get formattedEndDate {
    return DateFormat('dd MMM yyyy').format(widget.bookingDetails.endDate);
  }

  String get formattedStartDate {
    return DateFormat('dd MMM yyyy').format(widget.bookingDetails.startDate);
  }
  
  @override
  Widget build(BuildContext context) {
    final bool isDeclined = widget.status.toLowerCase() == 'declined';
  final Color statusColor = isDeclined ? Colors.red : Colors.black;
    return  Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side: Image
            ClipRRect(
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
                      child: const Icon(Icons.image, color: Colors.grey),
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
                      Text(
                        widget.item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // Item Count (2 Pcs)
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
                  Column(
                    children: [
                      Text(
                        'Order Date: $formattedStartDate - $formattedEndDate (${widget.duration} Days)',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
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
  
                      SizedBox(
                        height: 28,
                        // 1. Replace OutlinedButton with a Container to hold the styling.
                        child: Container(
                          // 2. Apply styling equivalent to OutlinedButton.styleFrom:
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ), // Padding
                          decoration: BoxDecoration(
                            color:
                                Colors
                                    .transparent, // Background color (optional, but good practice)
                            border: Border.all(
                              color: statusColor,
                            ), // BorderSide (Outline)
                            borderRadius: BorderRadius.circular(4), // Shape
                          ),
                          alignment:
                              Alignment
                                  .center, // Center the text vertically within the container
                          // 3. Place the Text widget inside the Container.
                          child: Text(
                            widget.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isDeclined ? FontWeight.bold : FontWeight.normal,
                              // 3. Apply dynamic text color
                              color: statusColor, 
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Total Rental Summary (The Yellow Section)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100], // Light yellow background
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Price: RM${widget.bookingDetails.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
        
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