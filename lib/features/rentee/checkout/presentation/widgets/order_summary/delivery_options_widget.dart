import 'package:easyrent/features/rentee/checkout/data/provider/checkout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Change to ConsumerWidget (Stateful is not needed here)
class DeliveryOptionsWidget extends ConsumerWidget { 
  const DeliveryOptionsWidget({super.key});

  final List<String> _deliveryOptions = const [
    'Delivery',
    'Self Pickup',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Access ref directly
    
    // 2. WATCH the current delivery option for automatic rebuilds.
    // Use select for efficiency: only rebuilds if deliveryOption changes.
    final selectedOption = ref.watch(checkoutProvider.select(
      (state) => state.deliveryOption,
    ));

    // 3. READ the Notifier to call methods in the onPressed/onChanged callback.
    final checkoutNotifier = ref.read(checkoutProvider.notifier);

    return Container(
      // Removed unnecessary outer Padding/Container, added Padding to Row
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Delivery Options',
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade400), // Added back for cleaner look
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                itemHeight: 50,
                // Removed padding property here, often causes issues.
                
                // 4. Use the watched variable for the current value
                value: selectedOption, 
                
                items: const [
                  DropdownMenuItem<String>( // Explicit generic type is good practice
                    value: 'Self-Pickup',
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        "Self-Pickup (RM 0.00)",
                        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DropdownMenuItem<String>( // Explicit generic type is good practice
                    value: 'Delivery',
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        "Delivery (RM 1.00)",
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    // 5. Use ref.read().notifier to call the method directly
                    checkoutNotifier.setDeliveryOption(newValue);
                    checkoutNotifier.setTotalFee();
                    // You can remove the print statement after debugging
                    // print("Delivery methods: $newValue"); 
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 4. (Optional) Remove the State class since the widget is now StatelessWidget
// If you had local state, you would keep it, but here it's all global.

// class DeliveryOptionsWidget extends ConsumerStatefulWidget { ... } 
// class _DeliveryOptionsWidgetState extends ConsumerState<DeliveryOptionsWidget> { ... } 
// These two are replaced by the single ConsumerWidget.