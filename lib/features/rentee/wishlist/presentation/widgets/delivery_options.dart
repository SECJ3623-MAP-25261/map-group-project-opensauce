import 'package:easyrent/features/rentee/wishlist/data/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Change to ConsumerWidget (Less boilerplate, no internal state needed)
class DeliveryOptions extends ConsumerWidget {
  const DeliveryOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Access ref directly
    
    // 2. Efficiently watch ONLY the deliveryOption string
    final selectedOption = ref.watch(
      shoppingCartProvider.select((state) => state.deliveryOption)
    );
    final shoppingCartMethods = ref.read(shoppingCartProvider.notifier);
    
    // 3. Keep a reference to the Notifier class (using read for non-listening access)
    // We use ref.read directly in the onChanged callback below for max cleanliness.
    // final cartNotifier = ref.read(shoppingCartProvider.notifier); // Optional line

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
                        "Self-pickup (RM 0.00)",
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
                    shoppingCartMethods.setDeliveryOption(newValue);
                    shoppingCartMethods.setTotalFee();
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