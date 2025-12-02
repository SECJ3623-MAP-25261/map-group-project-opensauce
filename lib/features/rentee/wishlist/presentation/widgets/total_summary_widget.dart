import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/features/rentee/wishlist/data/provider/provider.dart';
import 'package:easyrent/features/rentee/wishlist/presentation/widgets/delivery_options.dart';
import 'package:easyrent/features/rentee/wishlist/presentation/widgets/fee_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TotalSummaryWidget extends ConsumerStatefulWidget {
  const TotalSummaryWidget({super.key});

  @override
  ConsumerState<TotalSummaryWidget> createState() => _TotalSummaryWidgetState();
}

class _TotalSummaryWidgetState extends ConsumerState<TotalSummaryWidget> {
  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(shoppingCartProvider); 
    final carStateMethods = ref.read(shoppingCartProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.12,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Total Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'RM ${
                      (carStateMethods.getRenteeFee() + (carStateMethods.getRenteeFee() * 50 / 100) + (cartState.deliveryOption == 'Delivery' ? 1.00 : 0.00)).toStringAsFixed(2)
                    }',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Itemized Fees
              FeeRowWidget(title: 'Renting Fee', amount: carStateMethods.getRenteeFee()), // make amount double
              FeeRowWidget(title: 'Item deposit', amount:  carStateMethods.getRenteeFee() * 50 / 100), // make amount double
              DeliveryOptions(), // Make sure this widget exists

              const SizedBox(height: 16),

              // Check Out Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Checkout logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Check Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
