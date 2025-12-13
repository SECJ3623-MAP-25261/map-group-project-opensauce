import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/features/rentee/checkout/data/checkout_dummy_data.dart';
import 'package:easyrent/features/rentee/checkout/data/provider/checkout_provider.dart';
import 'package:easyrent/features/rentee/checkout/presentation/widgets/order_summary/delivery_options_widget.dart';
import 'package:easyrent/features/rentee/checkout/presentation/widgets/order_summary/delivery_place_widget.dart';
import 'package:easyrent/features/rentee/checkout/presentation/widgets/order_summary/start_end_date_widget.dart';
import 'package:easyrent/features/rentee/checkout/presentation/widgets/order_summary/summary_row_widget.dart';
import 'package:easyrent/features/rentee/checkout/presentation/widgets/order_summary/total_section_widget.dart';
import 'package:easyrent/features/rentee/homePage/home_page.dart';
import 'package:easyrent/features/rentee/renting_status/presentation/pages/renting_status_page.dart';
import 'package:easyrent/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomSummaryWidget extends ConsumerStatefulWidget {
  const BottomSummaryWidget({super.key,required this.duration});
  final int duration;
  @override
  ConsumerState<BottomSummaryWidget> createState() =>
      _BottomSummaryWidgetState();
}

class _BottomSummaryWidgetState extends ConsumerState<BottomSummaryWidget> {
    String? selectedPaymentMethod;
  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.read(checkoutProvider.notifier);
    final checkout = ref.watch(checkoutProvider);
    final totalFee = checkoutState.getTotalFee();

    double calculated =
        totalFee == 0
            ? (checkout.items.pricePerDay * widget.duration) +
                (checkout.items.pricePerDay * 0.30)
            : totalFee;

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.25,
      maxChildSize: 0.8,
      expand: true,
      snap: false,
      builder:
          (context, scrollController) => Container(
            padding: const EdgeInsets.all(20.0),
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
              padding: EdgeInsets.all(2),
              controller: scrollController,
              children: [
                Text(
                  'Order Summary',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Divider(height: 30, thickness: 1.5, color: Colors.grey),
                SumarryRowWidget(
                  title: 'Renting Fee',
                  amount:
                      'RM ${checkoutState.getRenteeFee() == 0 ? ref.watch(checkoutProvider).items.pricePerDay.toString() : checkoutState.getRenteeFee().toStringAsFixed(2)}',
                ),
                SumarryRowWidget(
                  title: 'Item Deposit',
                  amount:
                      'RM ${checkoutState.getRenteeFee() == 0 ? ref.watch(checkoutProvider).items.pricePerDay * 30 / 100 : checkoutState.getRenteeFee() * 30 / 100}',
                ),
                StartEndDateWidget(),
                const SizedBox(height: 20),
                DeliveryOptionsWidget(),
                const SizedBox(height: 20),
                DeliveryPlaceWidget(),
                const SizedBox(height: 20),
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
                        DropdownMenuItem(value: 'Cash', child: Text("Cash")),
                        DropdownMenuItem(value: 'FPX', child: Text("FPX")),
                        DropdownMenuItem(value: 'Card', child: Text("Card")),
                      ],
                       dropdownColor: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TotalSectionWidget(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Await the database operation. Assume it returns true on success, false on failure.
                      final bool success =
                          await ref
                              .read(checkoutProvider.notifier)
                              .checkoutToDatabase();

                      if (success) {
                        print(".................order success.................");
                        navigatorKey.currentState!.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => RentingStatusPage()),
                          (route) => false,
                        );
                      }
                      
                      else {
                        // 3. FAILURE: Show the Snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Order failed to create. Please try again.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red.shade700,
                            duration: const Duration(seconds: 4),
                            behavior:
                                SnackBarBehavior.floating, // Looks cleaner
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primaryRed, // A nice purple for checkout
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      
                      'Check Out (RM ${calculated})',
                      // {checkoutState.getTotalFee() == 0 ? ref.watch(checkoutProvider).items.pricePerDay + (ref.watch(checkoutProvider).items.pricePerDay * 30 / 100) * ref.watch(checkoutProvider).duration! : checkoutState.getTotalFee().toStringAsFixed(2)}
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
