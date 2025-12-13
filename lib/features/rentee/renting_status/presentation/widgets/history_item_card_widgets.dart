import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/features/models/item.dart';
import 'package:easyrent/features/rentee/renting_status/data/provider/renting_status_provider.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/pages/product_rating_page.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/report_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HistoryItemCardWidgets extends ConsumerStatefulWidget {
  final Item item;
  final DateTime startDate;
  final DateTime endDate;
  final int duration;
  final String status;
  final double totalPrice;

  const HistoryItemCardWidgets({super.key,required this.item, required this.startDate, required this.endDate, required this.duration, required this.status, required this.totalPrice});

  @override
  ConsumerState<HistoryItemCardWidgets> createState() => _HistoryItemCardWidgetsState();
}

class _HistoryItemCardWidgetsState extends ConsumerState<HistoryItemCardWidgets> {
  bool openReport = false;
  Future<bool> _handleReportSubmission(String reason, Item item) async {

    print('Reporting item: with ${item.productName} name and ${item.id} id');
    print('Reason: $reason');
    
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 2)); 

    // Simulate a successful submission 80% of the time
    final isSuccessful = DateTime.now().millisecond % 10 < 8; 

    return isSuccessful;
  }
  
  @override
  String get formattedEndDate {
    return DateFormat('dd MMM yyyy').format(widget.endDate);
  }
  String get formattedStartDate {
    return DateFormat('dd MMM yyyy').format(widget.startDate);
  }
  Widget build(BuildContext context) {
    final historyItemState = ref.read(rentingStatusProvider.notifier);

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
                widget.item.imageUrl,
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
                        widget.item.productName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // Item Count (2 Pcs)
                      Text(
                        '${widget.item.quantity} Pcs',
                        style: TextStyle(color: AppColors.primaryRed, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Column(
                    children: [
                      Text(
                        'Order Date: ${formattedStartDate} - ${formattedEndDate} (${widget.duration} Days)',
                        style: TextStyle(color: AppColors.primaryRed, fontSize: 10),
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
                      const SizedBox(width: 10,),
                      //   SizedBox(
                      //   height: 28,
                      //   // 1. Replace OutlinedButton with a Container to hold the styling.
                      //   child: Container(
                      //     // 2. Apply styling equivalent to OutlinedButton.styleFrom:
                      //     padding: const EdgeInsets.symmetric(horizontal: 10), // Padding
                      //     decoration: BoxDecoration(
                      //       color: Colors.transparent, // Background color (optional, but good practice)
                      //       border: Border.all(color: Colors.grey[400]!), // BorderSide (Outline)
                      //       borderRadius: BorderRadius.circular(4), // Shape
                      //     ),
                      //     alignment: Alignment.center, // Center the text vertically within the container
                      //     // 3. Place the Text widget inside the Container.
                      //     child: Text(
                      //       widget.item['paymentMethod'],
                      //       style: TextStyle(
                      //         fontSize: 12, 
                      //         color: Colors.black,
                      //         // Optional: Ensure text height aligns well with the 28px height constraint
                      //         // height: 1.0, 
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(width: 5,),
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
                            widget.status,
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
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100], // Light yellow background
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Price: RM${widget.totalPrice}',
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
                            
                            SizedBox(
                              height: 30,
                              
                              child: ElevatedButton(
                                onPressed: historyItemState.getHasReviewed(widget.item.id) ?  null : (){
                                   Navigator.push(context, MaterialPageRoute(builder: (context) => ProductRatingPage(item: widget.item,),));
                                }                       
                                ,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300], // Grey color
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  'Rate Order',
                                  style: TextStyle(fontSize: 12, color: historyItemState.getHasReviewed(widget.item.id) ? Colors.grey : Colors.black),
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