import 'package:easyrent/features/models/item.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/widgets/product_rating_widget.dart';
import 'package:flutter/material.dart';
class ProductRatingPage extends StatelessWidget {
  final Item item;

  const ProductRatingPage ({
      super.key,
      required this.item
  });
  // This function simulates an API call to submit the rating and review
  Future<bool> _submitUserRating(int rating, String review) async {
    // print('Submitting review for product: ${item['product_name']}');
    // print('Rating: $rating stars');
    // print('Review: $review');

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate success 80% of the time, failure 20%
    final bool success = DateTime.now().millisecond % 10 < 8;

    if (!success) {
      print('Failed to submit review.');
      // You could throw an error here or just return false
      // throw Exception('Failed to connect to review service.');
    } else {
      print('Review submitted successfully!');
    
    }
    return success;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Review')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'How was your experience with the ${item.productName}?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            
            // --- The Rating Widget Integration ---
            ProductRatingWidget(
              item: item,
              title: 'Rate ${item.productName}',
              // Initial rating could come from user's previous review
              initialRating: 3, 
              reviewHintText: 'Tell us what you think about the ${item.productName}...',
              isReviewRequired: false, // Set to true if review text is mandatory
              onSubmitRating: _submitUserRating, // Your async submission logic
            ),
            // --- End of Integration ---

            const SizedBox(height: 40),
            // Other product details or reviews below
            // Container(
            //   height: 200,
            //   color: Colors.blue.withOpacity(0.1),
            //   alignment: Alignment.center,
            //   child: const Text('Other product details / existing reviews'),
            // ),
          ],
        ),
      ),
    );
  }
}