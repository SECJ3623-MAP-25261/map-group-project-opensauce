import 'package:easyrent/features/rentee/checkout/data/checkout_dummy_data.dart';
import 'package:easyrent/features/rentee/checkout/domain/checkout_state.dart';
import 'package:flutter_riverpod/legacy.dart';

// The StateNotifier must take your immutable state class as its generic type
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  // Initialize with the starting state (matching your ValueNotifiers)
  CheckoutNotifier() : super(
    const CheckoutState(
      totalFee: 0.0,
      renteeFee: 0.0,
      deliveryOption: 'Self-Pickup',
      items: checkoutProductList,
      depositRate: 30.0,
      isLoading: false
    ),
  );

  void setIsloading(bool isLoading) {
    state = state.copyWith(
      isLoading: isLoading
    );
  }

  // Business Logic: Calculates the delivery fee based on the option
  double _calculateDeliveryFee(String option) {
    // Example logic:
    return option == 'Delivery' ? 1.00 : 0.00;
  }
  
  // Public method to update the delivery option and fees
  void setDeliveryOption(String newOption) {
    final double newFee = _calculateDeliveryFee(newOption);
    setTotalFee();
    // Update the state using copyWith (immutability required!)
    state = state.copyWith(
      renteeFee: newFee,
      deliveryOption: newOption,
    );
  }

  String getDeliveryOptions() {
    return state.deliveryOption;
  }
  // Optional: A helper method for derived state (calculated fields)
  double getTotalAmount() {
    // Here you would add other items, but for now, just the fee.
    return state.renteeFee; 
  }

  void incrementItemQuantity(String itemId) {
    // 1. Create a new list based on the current state's items
    final updatedItems = state.items.map((item) {
      if (item['id'] == itemId) {
        // 2. Return a NEW map with the incremented quantity (immutability)
        return Map<String, dynamic>.from(item) 
            ..['quantity'] = item['quantity'] + 1;
      }
      return item; // Return unchanged item
    }).toList();

    // 3. Set the new, immutable state
    state = state.copyWith(items: updatedItems);
    setTotalFee();
  }

  void decrementItemQuantity(String itemId) {
    final updatedItems = state.items.map((item) {

      if (item['id'] == itemId && item['quantity'] >= 1) {
        return Map<String, dynamic>.from(item) 
            ..['quantity'] = item['quantity'] - 1;
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    getItemQuantity (itemId);
    setTotalFee();
  }

  int getItemQuantity (String itemId) {
    final item = state.items.where((item) => item['id'] == itemId);
    
    if(item.isNotEmpty){
      return item.first['quantity'] ?? 0;
    }
    return 0;
  }

// Update renteeFee based on items
void setRenteeFee() {
  double totalPrice = 0;

  for (var item in state.items) {
    totalPrice += (item['quantity'] * item['price_per_day']);
  }

  state = state.copyWith(
    renteeFee: totalPrice,
  );
}

void setTotalFee () {
  setRenteeFee();
  double totalFee = state.renteeFee + (state.renteeFee * state.depositRate) + (state.deliveryOption == 'Self-Pickup'? 0.0 : 1.0);

  state = state.copyWith(
    totalFee: totalFee
  );
}

double getTotalFee () {
  return state.totalFee;
}

// Get current renteeFee (does not mutate state)
double getRenteeFee() {
  return double.parse(state.renteeFee.toStringAsFixed(2));
}

void deleteItem (String itemId) {
  final updatedItem = state.items.where((item) => item['id'] != itemId).toList();

  state = state.copyWith(
    items: updatedItem,
  );
}
}