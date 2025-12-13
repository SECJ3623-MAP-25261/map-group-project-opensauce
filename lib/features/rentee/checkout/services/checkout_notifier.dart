import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/features/models/item.dart';
import 'package:easyrent/features/rentee/checkout/domain/checkout_state.dart';
import 'package:easyrent/features/rentee/checkout/services/database.dart';
import 'package:flutter_riverpod/legacy.dart';

// The StateNotifier must take your immutable state class as itse
class CheckoutNotifier extends StateNotifier<CheckoutState> {

  static final DocumentReference ownerRef = FirebaseFirestore.instance
    .collection('user') // Use the correct collection name for owners/users
    .doc('UAPrpMnRHvfu47xvzh7L');

  // Initial state of items
  static final Item dummyItem  = Item(
  id: 'product_456',
  ownerRef: ownerRef,
  ownerId: 'owner_456',
  ownerName: 'Jane Doe',
  ownerImage: 'jane_profile.jpg',
  productName: '4K Camera',
  pricePerDay: 50.0,
  imageUrl: 'camera_main.jpg',
  imageUrls: ['camera_1.jpg', 'camera_2.jpg'],
  description: 'A professional camera for rent.',
  quantity: 1,
  rentingDuration: 'Daily',
  deliveryMethods: 'Courier Only',
  averageRating: 4.8,
  reviews: [],
  location: 'Kuala Lumpur',
);

  // Initialize with the starting state (matching your ValueNotifiers)
  CheckoutNotifier()
    : super(
        CheckoutState(
          totalFee: 0.0,
          renteeFee: 0.0,
          deliveryOption: 'Self-Pickup',
          items: dummyItem,
          depositRate: 30.0,
          isLoading: false,
          startRenting: DateTime.now(),
          endRenting: DateTime.now(),
          duration: 0,
          isDBSuccess: false,
          isOrderComplete: false,
          userId: ''
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

  void setItems(Item selectedItems, int duration) {
    state = state.copyWith(items: selectedItems, renteeFee: selectedItems.pricePerDay, totalFee: selectedItems.pricePerDay * 1.3 * selectedItems.quantity * duration);
  }

  // Business Logic: Calculates the delivery fee based on the option
  double _calculateDeliveryFee(String option) {
    // Example logic:
    return option == 'Delivery' ? 1.00 : 0.00;
  }

  // Public method to update the delivery option and fees
  void setDeliveryOption(String newOption) {
    // 1. Calculate the new delivery fee (assuming this is done correctly outside)
    final double newDeliveryFee = _calculateDeliveryFee(newOption);

    // 2. Update the state with the new delivery data first
    state = state.copyWith(
      deliveryOption: newOption,
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

  void incrementItemQuantity() {
    final currentItem = state.items;

    final updatedItem = currentItem.copyWith(
      quantity: currentItem.quantity + 1,
    );

    state = state.copyWith(items: updatedItem);

    setTotalFee();
  }

  void decrementItemQuantity() {
    final currentItem = state.items;

    if (currentItem.quantity > 1) {
      final updatedItem = currentItem.copyWith(
        quantity: currentItem.quantity - 1,
      );

      state = state.copyWith(items: updatedItem);
    }

    setTotalFee();
  }

  int getItemQuantity(String itemId) {
    print("getItemQuantity: ${state.items.quantity}");
    return state.items.quantity;
  }

  void setInitialRenteeFee (double total) {
      state=state.copyWith(
        totalFee: total
      );
  }

  // Update renteeFee based on items
  void setRenteeFee() { 
    double totalPrice = 0.0;

    Item currentItem = state.items;

    // Safely extract item properties, providing defaults for robustness
    final double pricePerDay = currentItem.pricePerDay;
    final int quantity = currentItem.quantity;

    // Calculate price for this single item and add it to the total

    totalPrice += pricePerDay * quantity * state.duration!;
    print("the totalPrice is ${totalPrice} and the duration ${state.duration}");

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
            : 1.0);
    
    double depositAmount =
        state.renteeFee * (state.depositRate / 100); // Deposit is a percentage
        
    double totalFee = state.renteeFee + depositAmount + deliveryCost;
 
    state = state.copyWith(totalFee: totalFee);
  }

  double getTotalFee() {
    return state.totalFee;
  }

  // Get current renteeFee (does not mutate state)
  double getRenteeFee() {
    return double.parse(state.renteeFee.toStringAsFixed(2));
  }

  Future<bool> checkoutToDatabase() async {
    final dbService = CheckoutDatabaseServices();
    try {
      // Assuming you have a function to convert your state to a map
      final Map<String,dynamic> orderDetails = state.toJson();
      state = state.copyWith(isLoading: true);
      // Assuming you have access to the current user's ID

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
