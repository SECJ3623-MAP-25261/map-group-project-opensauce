import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/features/rentee/checkout/data/provider/checkout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class TotalSectionWidget extends ConsumerStatefulWidget {
  const TotalSectionWidget({super.key});

  @override
  ConsumerState<TotalSectionWidget> createState() => _TotalSectionWidgetState();
}

class _TotalSectionWidgetState extends ConsumerState<TotalSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.05), // A subtle background for total
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Text(
            'Check Out (RM ${ref.read(checkoutProvider.notifier).getTotalFee() == 0? ref.watch(checkoutProvider).items.pricePerDay * 1.3: ref.read(checkoutProvider.notifier).getTotalFee().toStringAsFixed(2)})',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryRed,
            ),
          ),
        ],
      ),
    );
  }
}