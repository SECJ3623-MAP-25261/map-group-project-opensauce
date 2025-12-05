import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/features/rentee/checkout/presentation/widgets/order_summary/delivery_place_widget.dart';
import 'package:easyrent/features/rentee/checkout/presentation/widgets/order_summary/start_end_date_widget.dart';
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
    String? selectedPaymentMethod;
    return DraggableScrollableSheet(
      initialChildSize: 0.30,
      minChildSize: 0.25,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(25.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, -5),
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
                    'RM ${(carStateMethods.getRenteeFee() + (carStateMethods.getRenteeFee() * 50 / 100) + (cartState.deliveryOption == 'Delivery' ? 1.00 : 0.00)).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Itemized Fees
              FeeRowWidget(
                title: 'Renting Fee',
                amount: carStateMethods.getRenteeFee(),
              ), // make amount double
              FeeRowWidget(
                title: 'Item deposit',
                amount: carStateMethods.getRenteeFee() * 50 / 100,
              ), // make amount double
              DeliveryOptions(), // Make sure this widget exists

              const SizedBox(height: 16),
              StartEndDateWidget(),
              const SizedBox(height: 16),
              DeliveryPlaceWidget(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Choose a payment method",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  DropdownButton<String>(
                    value: selectedPaymentMethod,
                    hint: const Text("Select"),
                    items: const [
                      DropdownMenuItem(
                        value: 'cash',
                        child: Text("Cash"),
                      ),
                      DropdownMenuItem(
                        value: 'fpx',
                        child: Text("FPX"),
                      ),
                      DropdownMenuItem(
                        value: 'card',
                        child: Text("Card"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Check Out Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    //TODO: SPRINT 3
                    print("direct user to payment page");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Pay',
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
