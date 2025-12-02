import 'package:easyrent/features/rentee/renting_status/data/provider/renting_status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductRatingWidget extends ConsumerStatefulWidget {
 
  final Future<bool> Function(int rating, String review) onSubmitRating;
  // Optional: Initial rating to display.
  final int initialRating;
  // Optional: Title for the review section.
  final String title;
  // Optional: Hint text for the review field.
  final String reviewHintText;
  // Optional: Whether the review text field is required.
  final bool isReviewRequired;
  final Map<String,dynamic> item;

  const ProductRatingWidget({
    super.key,
    required this.item,
    required this.onSubmitRating,
    this.initialRating = 0,
    this.title = 'Rate this Product',
    this.reviewHintText = 'Share your detailed experience...',
    this.isReviewRequired = false,
  });

  @override
  ConsumerState<ProductRatingWidget> createState() => _ProductRatingWidgetState();
}

class _ProductRatingWidgetState extends ConsumerState<ProductRatingWidget> {
  late int _currentRating;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false; // To manage loading state of the submit button

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // --- Star Rating Builder ---
  Widget _buildStar(int starIndex) {
    return GestureDetector(
      onTap: () {
        if (!_isSubmitting) {
          setState(() {
            _currentRating = starIndex;
          });
        }
      },
      child: Icon(
        starIndex <= _currentRating ? Icons.star : Icons.star_border,
        color: starIndex <= _currentRating ? Colors.amber : Colors.grey,
        size: 36.0,
      ),
    );
  }

  bool finishedReviewLoading = false;
  // --- Submission Logic ---
  void _submitReview(Map<String,dynamic>item) async {
    // Validate rating
    if (_currentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate review text if required
    final reviewText = _reviewController.text.trim();
    if (widget.isReviewRequired && reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a review.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Set submitting state
    setState(() {
      _isSubmitting = true;
    });

    // Close the keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      // Execute the provided submission logic
      final success = await widget.onSubmitRating(_currentRating, reviewText);

      // Show success/failure message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Review submitted successfully! Thank you.'
                : 'Failed to submit review. Please try again.',style: TextStyle(color: Colors.white),),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        
        // Optionally reset the widget state after successful submission
        if (success) {
          setState(() {
            ref.read(rentingStatusProvider.notifier).setHasReviewed(item['id'], true);
            finishedReviewLoading =  true;
            _currentRating = 0; // Reset stars
            _reviewController.clear(); // Clear text field
          });
        }

        if(finishedReviewLoading) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      // Handle any exceptions during submission
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Reset submitting state
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keep column compact
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- Title ---
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // --- Star Rating Row ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => _buildStar(index + 1)),
            ),
            const SizedBox(height: 20),

            // --- Review Text Field (Optional) ---
            TextField(
              controller: _reviewController,
              maxLines: 4,
              minLines: 2,
              enabled: !_isSubmitting, // Disable while submitting
              decoration: InputDecoration(
                hintText: widget.reviewHintText,
                labelText: widget.isReviewRequired ? 'Your Review *' : 'Your Review',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 20),

            // --- Submit Button ---
            ElevatedButton(
              onPressed: _isSubmitting ? null : () async {
                setState(() => _isSubmitting = true);

                 _submitReview(widget.item);

                setState(() => _isSubmitting = false);

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Submit Review',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}