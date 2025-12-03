import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/features/rentee/checkout/data/checkout_dummy_data.dart';
import 'package:easyrent/features/rentee/checkout/data/provider/checkout_provider.dart';
import 'package:easyrent/features/rentee/checkout/presentation/widgets/order_summary/delivery_options_widget.dart';
import 'package:easyrent/features/rentee/checkout/presentation/widgets/order_summary/summary_row_widget.dart';
import 'package:easyrent/features/rentee/checkout/presentation/widgets/order_summary/total_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomSummaryWidget extends ConsumerStatefulWidget {
  const BottomSummaryWidget({super.key});
  @override
  ConsumerState<BottomSummaryWidget> createState() =>
      _BottomSummaryWidgetState();
}

class _BottomSummaryWidgetState extends ConsumerState<BottomSummaryWidget> {

  void _checkout(String selectedDeliveryOption, double totalAmount ) {
    // Implement your checkout logic here
    print('Proceeding to checkout with:');
    for (var item in checkoutProductList) {
      print('${item['name']} x ${item['quantity']}');
    }
    print('Delivery Option: $selectedDeliveryOption');
    print('Total: RM ${totalAmount.toStringAsFixed(2)}');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Processing your order...')));
    // Navigate to payment or confirmation screen
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.read(checkoutProvider.notifier);
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            amount: 'RM ${checkoutState.getRenteeFee().toStringAsFixed(2)}',
          ),
          SumarryRowWidget(
            title: 'Item Deposit',
            amount: 'RM ${checkoutState.getRenteeFee() * 50 / 100}',
          ),
          DeliveryOptionsWidget(),
          const SizedBox(height: 20),
          TotalSectionWidget(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _checkout(checkoutState.getDeliveryOptions(),checkoutState.getTotalFee());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed, // A nice purple for checkout
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: Text(
                'Check Out (RM ${checkoutState.getTotalFee().toStringAsFixed(2)})',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
