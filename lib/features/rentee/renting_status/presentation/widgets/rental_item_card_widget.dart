import 'package:easyrent/core/constants/constants.dart';
import 'package:flutter/material.dart';

class RentalItemCardWidget extends StatefulWidget {
  final Map<String,dynamic> item;
  const RentalItemCardWidget({super.key, required this.item});
  @override
  State<RentalItemCardWidget> createState() => _RentalItemCardWidgetState();
}

class _RentalItemCardWidgetState extends State<RentalItemCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side: Image
              ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.item['imageUrl'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
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
                        widget.item['product_name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // Item Count (2 Pcs)
                      Text(
                        '${widget.item['quantity']} Pcs',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Rental Rate
                  Text(
                    'RM ${widget.item['price_per_day']} / day',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 8),

                  // Total Rental Summary (The Yellow Section)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100], // Light yellow background
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total ${widget.item['orderDate']} days: RM 100',
                          style: TextStyle(
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
                            // Self Pickup Button
                            SizedBox(
                              height: 28,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  side: BorderSide(color: Colors.grey[400]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  widget.item['deliveryMethods'],
                                  style: TextStyle(fontSize: 12, color: Colors.black),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Cancel Order Button
                            SizedBox(
                              height: 28,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300], // Grey color
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel Order',
                                  style: TextStyle(fontSize: 12, color: Colors.black),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Report Button (Red)
                            SizedBox(
                              height: 28,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryRed, // Dark Red color
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: const Text(
                                  'Report',
                                  style: TextStyle(fontSize: 12, color: Colors.white),
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