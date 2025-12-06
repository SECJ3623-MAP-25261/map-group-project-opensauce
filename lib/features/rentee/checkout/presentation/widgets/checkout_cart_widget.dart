import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/features/rentee/checkout/data/provider/checkout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutCartWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;

  const CheckoutCartWidget({super.key, required this.item});

  @override
  ConsumerState<CheckoutCartWidget> createState() => _CheckoutCartWidgetState();
}

class _CheckoutCartWidgetState extends ConsumerState<CheckoutCartWidget> {
  @override
  Widget build(BuildContext context) {
    final id = widget.item['id'] as String;
    // Helper function to create the star rating row
    Widget buildRatingRow() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: AppColors.primary, size: 16),
          const SizedBox(width: 4),
          Text(
            '${widget.item['star_rating']}/5.0 (${widget.item['price_per_day']})',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      );
    }

    // Helper function to create the quantity controls
    Widget buildQuantityControl() {
      return Container(
        // padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                if (ref.watch(checkoutProvider.notifier).getItemQuantity(id) > 0) {
                  ref.read(checkoutProvider.notifier).decrementItemQuantity(widget.item['id']);
                }
              },
              icon: const Icon(Icons.remove, size: 16, color: Colors.grey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 4),
            Text(
              ref.watch(checkoutProvider.notifier).getItemQuantity(id).toString(),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () {
                ref.read(checkoutProvider.notifier).incrementItemQuantity(widget.item['id']);
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.grey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0, left: 14.0, right: 14.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Product Image
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

          // Center: Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.item['product_name'],
                        style: const TextStyle(
                          overflow: TextOverflow.clip,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                      IconButton(
                        onPressed: () {
                          ref.read(checkoutProvider.notifier).deleteItem(id);
                        },
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'RM ${widget.item['price_per_day']} per day',
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                buildRatingRow(),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: buildQuantityControl(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
