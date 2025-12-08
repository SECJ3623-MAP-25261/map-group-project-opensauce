import 'package:easyrent/features/rentee/checkout/domain/checkout_state.dart';
import 'package:easyrent/features/rentee/checkout/services/database.dart';
import 'package:easyrent/features/rentee/data/dummy_data.dart';
import 'package:flutter_riverpod/legacy.dart';

// The StateNotifier must take your immutable state class as its generic type
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  // Initialize with the starting state (matching your ValueNotifiers)
  CheckoutNotifier()
    : super(
        CheckoutState(
          totalFee: 0.0,
          renteeFee: 0.0,
          deliveryOption: 'Self-Pickup',
          items: dummyProducts[0],
          depositRate: 30.0,
          isLoading: false,
          startRenting: DateTime.now(),
          endRenting: DateTime.now(),
          duration: 0,
          isDBSuccess: false,
          isOrderComplete: false,
        ),
      );

  void setIsloading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setStartEndRenting(DateTime? start, DateTime? end) {
    final Duration difference;
    if (start != null && end != null) {
      difference = end.difference(start);

      state = state.copyWith(
        startRenting: start,
        endRenting: end,
        duration: difference.inDays,
      );
    }
  }

  void setItems(Map<String, dynamic> selectedItems) {
    state = state.copyWith(items: selectedItems);
  }

  // Business Logic: Calculates the delivery fee based on the option
  double _calculateDeliveryFee(String option) {
    // Example logic:
    return option == 'Delivery' ? 1.00 : 0.00;
  }

  // Public method to update the delivery option and fees
  // Public method to update the delivery option and fees
  void setDeliveryOption(String newOption) {
    // 1. Calculate the new delivery fee (assuming this is done correctly outside)
    final double newDeliveryFee = _calculateDeliveryFee(newOption);

    // 2. Update the state with the new delivery data first
    state = state.copyWith(
      deliveryOption: newOption,
      // The delivery fee should be added to the total fee logic, not renteeFee.
      // If you need a separate `deliveryFee` field in your state, use it here.
      // Assuming newDeliveryFee is the cost of delivery, let's keep it separate
      // but update the state with the option first.
    );

    // 3. Recalculate ALL fees now that the option is updated
    setTotalFee();
  }

  String getDeliveryOptions() {
    return state.deliveryOption;
  }

  // Optional: A helper method for derived state (calculated fields)
  double getTotalAmount() {
    // Here you would add other items, but for now, just the fee.
    return state.renteeFee;
  }

  // use in list
  // void incrementItemQuantity(String itemId) {
  //   // 1. Create a new list based on the current state's items
  //   final updatedItems = state.items.map((item) {
  //     if (item['id'] == itemId) {
  //       // 2. Return a NEW map with the incremented quantity (immutability)
  //       return Map<String, dynamic>.from(item)
  //           ..['quantity'] = item['quantity'] + 1;
  //     }
  //     return item; // Return unchanged item
  //   }).toList();

  //   // 3. Set the new, immutable state
  //   state = state.copyWith(items: updatedItems);
  //   setTotalFee();
  // }

  void incrementItemQuantity() {
    final Map<String, dynamic> currentItems = Map.from(state.items);

    int currentQuantity = currentItems['quantity'] as int? ?? 0;

    final int newQuantity = currentQuantity + 1;

    currentItems['quantity'] = newQuantity;

    state = state.copyWith(items: currentItems);

    setTotalFee();
  }

  void decrementItemQuantity() {
    final Map<String, dynamic> currentItems = Map.from(state.items);

    int currentQuantity = currentItems['quantity'] as int? ?? 0;

    final int newQuantity = currentQuantity - 1;

    currentItems['quantity'] = newQuantity;

    state = state.copyWith(items: currentItems);

    setTotalFee();
  }
  // used in list
  // void decrementItemQuantity(String itemId) {
  //   final updatedItems = state.items.map((item) {

  //     if (item['id'] == itemId && item['quantity'] >= 1) {
  //       return Map<String, dynamic>.from(item)
  //           ..['quantity'] = item['quantity'] - 1;
  //     }
  //     return item;
  //   }).toList();

  //   state = state.copyWith(items: updatedItems);
  //   getItemQuantity (itemId);
  //   setTotalFee();
  // }

  // int getItemQuantity (String itemId) {
  //   final item = state.items['quantity'];

  //   if(item.isNotEmpty){
  //     return item.first['quantity'] ?? 0;
  //   }
  //   return 0;
  // }
  int getItemQuantity(String itemId) {
    final Map<String, dynamic> currentItems = Map.from(state.items);
    final item = currentItems['quantity'];
    if (item != null) {
      return item;
    }
    return 0;
  }

  // Update renteeFee based on items
  // Update renteeFee based on items
  void setRenteeFee() {
    double totalPrice = 0.0;

    Map<String, dynamic> currentItem = Map.from(state.items);

    // Loop over the VALUES of the items map (the individual item detail maps)
    print(
      "the type is : ${state.items['price'].runtimeType} ${state.items['quantity'].runtimeType}",
    );

    // Safely extract item properties, providing defaults for robustness
    final double pricePerDay = currentItem['price'].toDouble();
    final int quantity = currentItem['quantity'];

    // Calculate price for this single item and add it to the total
    totalPrice += pricePerDay * quantity * state.duration!;
    print("the totalPrice is ${totalPrice}");

    // print("total Price: ${totalPrice.toString()}"); // You can put your debug print back here

    state = state.copyWith(renteeFee: totalPrice);
  }

  void setTotalFee() {
    // 1. ENSURE renteeFee is calculated first (This calls setRenteeFee, which updates state.renteeFee)
    setRenteeFee();

    // 2. Calculate Delivery/Pickup Cost (Assuming _calculateDeliveryFee provides the cost)
    final double deliveryCost =
        (state.deliveryOption == 'Self-Pickup'
            ? 0.0
            : _calculateDeliveryFee(state.deliveryOption));

    // 3. Calculate Total Fee: Base Rental + Deposit + Delivery Cost
    // NOTE: I replaced the `state.renteeFee * state.depositRate` with a more standard deposit calculation.
    double depositAmount =
        state.renteeFee * (state.depositRate / 100); // Deposit is a percentage

    double totalFee = state.renteeFee + depositAmount + deliveryCost;
    print(
      "renteeFee: ${state.renteeFee} depositAmount: ${depositAmount} deliveryCost: ${deliveryCost}",
    );
    state = state.copyWith(totalFee: totalFee);
  }

  double getTotalFee() {
    return state.totalFee;
  }

  // Get current renteeFee (does not mutate state)
  double getRenteeFee() {
    return double.parse(state.renteeFee.toStringAsFixed(2));
  }

  // void deleteItem (String itemId) {
  //   final updatedItem = state.items.where((item) => item['id'] != itemId).toList();

  //   state = state.copyWith(
  //     items: updatedItem,
  //   );
  // }

  Future<bool> checkoutToDatabase() async {
    final dbService = CheckoutDatabaseServices();
    try {
      // Assuming you have a function to convert your state to a map
      final Map<String, dynamic> orderDetails = state.toJson();
      state = state.copyWith(isLoading: true);
      // Assuming you have access to the current user's ID
      const String currentUserId = 'user_abc_123';

      String newOrderId = await dbService.createOrder(
        orderData: orderDetails,
        // userId: currentUserId, // implement after integrate user
      );

      print('Order successfully placed with ID: $newOrderId');
      state = state.copyWith(isLoading: false, isDBSuccess: true);
      return true;
    } catch (e) {
      // Handle the error (e.g., show a dialog)
      print('Failed to place order: $e');
      return false;
    }
  }
}
