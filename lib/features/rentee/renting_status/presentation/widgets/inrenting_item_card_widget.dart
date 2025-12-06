import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/cancel_order_widget.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/report_item_widget.dart';
import 'package:flutter/material.dart';

class InrentingItemCardWidget extends StatefulWidget {
  final Map<String,dynamic> item;
  const InrentingItemCardWidget({super.key,required this.item});

  @override
  State<InrentingItemCardWidget> createState() => _InrentingItemCardWidgetState();
}

class _InrentingItemCardWidgetState extends State<InrentingItemCardWidget> {
  bool cancelledItem = false;
    // This is the function that simulates the API call to report the item
  Future<bool> _handleReportSubmission(String reason, Map<String,dynamic> item) async {

    print('Reporting item: with ${item['product_name']} name and ${item['id']} id');
    print('Reason: $reason');
    
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 2)); 

    // Simulate a successful submission 80% of the time
    final isSuccessful = DateTime.now().millisecond % 10 < 8; 

    return isSuccessful;
  }
  
    Future<void> _cancelOrderApiCall( Map<String,dynamic> item) async {
    print('Attempting to cancel order ${item['id']}...');
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate failure 20% of the time for testing the error state
    if (DateTime.now().millisecond % 10 < 2) {
      throw Exception('Server error: Could not process cancellation.');
    }
    setState(() {
      cancelledItem = true;
    });
    print('Order ${item['id']} successfully cancelled.');
    // In a real app, you would typically refresh the order status here
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
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
                       Expanded(
                         child: Text(
                          widget.item['product_name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                                               ),
                       ),
                      // Days Remaining
                      Text(
                        '${widget.item['daysRemaining']} days',
                        style: TextStyle(color: AppColors.primaryRed, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Return Date: ${widget.item['returnDate']}',
                        style: TextStyle(color: AppColors.primaryRed, fontSize: 12),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Rental Rate
                  Row(
                    children: [
                      Text(
                        'RM ${widget.item['price_per_day']} / day',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(width: 10,),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      SizedBox(
                        height: 28,
                        // 1. Replace OutlinedButton with a Container to hold the styling.
                        child: Container(
                          // 2. Apply styling equivalent to OutlinedButton.styleFrom:
                          padding: const EdgeInsets.symmetric(horizontal: 10), // Padding
                          decoration: BoxDecoration(
                            color: Colors.transparent, // Background color (optional, but good practice)
                            border: Border.all(color: Colors.grey[400]!), // BorderSide (Outline)
                            borderRadius: BorderRadius.circular(4), // Shape
                          ),
                          alignment: Alignment.center, // Center the text vertically within the container
                          // 3. Place the Text widget inside the Container.
                          child: Text(
                            //TODO: Change the data format and use function to convert to readable type
                            widget.item['returnMethod'],
                            style: TextStyle(
                              fontSize: 12, 
                              color: Colors.black,
                              // Optional: Ensure text height aligns well with the 28px height constraint
                              // height: 1.0, 
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10,),
                        SizedBox(
                        height: 28,
                        // 1. Replace OutlinedButton with a Container to hold the styling.
                        child: Container(
                          // 2. Apply styling equivalent to OutlinedButton.styleFrom:
                          padding: const EdgeInsets.symmetric(horizontal: 10), // Padding
                          decoration: BoxDecoration(
                            color: Colors.transparent, // Background color (optional, but good practice)
                            border: Border.all(color: Colors.grey[400]!), // BorderSide (Outline)
                            borderRadius: BorderRadius.circular(4), // Shape
                          ),
                          alignment: Alignment.center, // Center the text vertically within the container
                          // 3. Place the Text widget inside the Container.
                          child: Text(
                            
                            widget.item['currentStatus'],
                            style: TextStyle(
                              fontSize: 12, 
                              color: Colors.black,
                              // Optional: Ensure text height aligns well with the 28px height constraint
                              // height: 1.0, 
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
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
                          'Total Price: RM${widget.item['totalPrice']}',
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
                            // Cancel Order Button
                             SizedBox(
                              height: 28,
                              child: ElevatedButton(
                                onPressed: widget.item['status'] == 'cancelled' || cancelledItem == true? null : () {
                                    showCancelConfirmationModal(context: context, item: widget.item, onConfirm: (item) => _cancelOrderApiCall(widget.item));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300], // Grey color
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  'Cancel Order',
                                  style: TextStyle(fontSize: 12, color: widget.item['status'] == 'cancelled' || cancelledItem == true ? Colors.grey : Colors.black),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Report Button (Red)
                            SizedBox(
                              height: 28,
                              child: ReportItemWidget(onSubmitReport: _handleReportSubmission, item: widget.item)                                                    
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