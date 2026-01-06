import 'package:easyrent/features/rentee/checkout/data/provider/checkout_provider.dart';
import 'package:easyrent/features/rentee/checkout/domain/checkout_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class StartEndDateWidget extends ConsumerWidget {
  const StartEndDateWidget({super.key});
  
  @override
  // Check if a date range was selected before trying to format
  
  Widget build(BuildContext context, WidgetRef ref) {
  CheckoutState CheckoutNotifier = ref.watch(checkoutProvider);
  String startDateString = DateFormat('MMMM d, yyyy').format(CheckoutNotifier.startRenting ?? DateTime.now());
  String endDateString = DateFormat('MMMM d, yyyy').format(CheckoutNotifier.endRenting ?? DateTime.now());

    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Start Renting Date",style: TextStyle(color: Colors.black),),
              Text(
                startDateString
                )
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("End Renting Date"),
              Text(endDateString)
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Duration"),
              Text(CheckoutNotifier.duration.toString())
            ],
          )
        ],
      ),
    );
  }
}