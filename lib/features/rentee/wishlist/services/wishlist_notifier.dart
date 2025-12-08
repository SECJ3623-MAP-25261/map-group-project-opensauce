import 'package:easyrent/features/rentee/checkout/services/database.dart';
import 'package:easyrent/features/rentee/wishlist/domain/shopping_cart_state.dart';
import 'package:easyrent/features/rentee/wishlist/services/database.dart';
import 'package:flutter_riverpod/legacy.dart';

// The StateNotifier must take your immutable state class as its generic type
class ShoppingCart extends StateNotifier<ShoppingCartState> {
  // Initialize with the starting state (matching your ValueNotifiers)
  ShoppingCart()
    : super(
        const ShoppingCartState(
          totalFee: 0.0,
          renteeFee: 0.0,
          deliveryOption: 'Self-Pickup',
          items: [],
          depositRate: 30.0,
          isDBSuccess: false
        ),
      );

  void setItems(List<Map<String, dynamic>> selectedItems) {
    state = state.copyWith(items: selectedItems);
  }

  // Business Logic: Calculates the delivery fee based on the option
  double _calculateDeliveryFee(String option) {
    // Example logic:
    return option == 'Delivery' ? 1.00 : 0.00;
  }

  // Public method to update the delivery option and fees
  void setDeliveryOption(String newOption) {
    final double newFee = _calculateDeliveryFee(newOption);

    // Update the state using copyWith (immutability required!)
    state = state.copyWith(renteeFee: newFee, deliveryOption: newOption);
  }

  // Optional: A helper method for derived state (calculated fields)
  double getTotalAmount() {
    // Here you would add other items, but for now, just the fee.
    return state.renteeFee;
  }

  void incrementItemQuantity(String itemId) {
    // 1. Create a new list based on the current state's items
    final updatedItems =
        state.items.map((item) {
          if (item['itemId'] == itemId) {
            // 2. Return a NEW map with the incremented quantity (immutability)
            return Map<String, dynamic>.from(item)
              ..['item']['quantity'] = item['item']['quantity'] + 1;
          }
          return item; // Return unchanged item
        }).toList();

    // 3. Set the new, immutable state
    state = state.copyWith(items: updatedItems);
    setRenteeFee();
  }

  void decrementItemQuantity(String itemId) {
    final updatedItems =
        state.items.map((item) {
          if (item['itemId'] == itemId && item['item']['quantity'] >= 1) {
            return Map<String, dynamic>.from(item)
              ..['item']['quantity'] = item['item']['quantity'] - 1;
          }
          return item;
        }).toList();

    state = state.copyWith(items: updatedItems);
    setRenteeFee();
  }

  int getItemQuantity(String itemId) {
    final item = state.items.where((item) => item['itemId'] == itemId);

    if (item.isNotEmpty) {
      //  print("the quantity is ${item.first['id']}");
      return item.first['item']['quantity'] ?? 0;
    }
    return 0;
  }

  // Update renteeFee based on items
  void setRenteeFee() {
    double totalPrice = 0;

    for (var item in state.items) {
      totalPrice += (item['item']['quantity'] * item['item']['price']);
    }

    state = state.copyWith(renteeFee: totalPrice);
  }

  void setTotalFee() {
    setRenteeFee();
    double totalFee =
        state.renteeFee +
        (state.renteeFee * state.depositRate) +
        (state.deliveryOption == 'Self-Pickup' ? 0.0 : 1.0);

    state = state.copyWith(totalFee: totalFee);
  }

  // Get current renteeFee (does not mutate state)
  double getRenteeFee() {
    return double.parse(state.renteeFee.toStringAsFixed(2));
  }

  void deleteItem(String itemId) {
    final updatedItem =
        state.items.where((item) => item['itemId'] != itemId).toList();

    state = state.copyWith(items: updatedItem);
  }

  Future<bool> checkoutToDatabase() async {
    final dbService = CheckoutDatabaseServices();
    try {
      // Assuming you have a function to convert your state to a map
      final Map<String, dynamic> orderDetails = state.toJson();
      // state = state.copyWith(isLoading: true);
      // Assuming you have access to the current user's ID
      const String currentUserId = 'user_abc_123';

      String newOrderId = await dbService.createOrder(
        orderData: orderDetails,
        // userId: currentUserId, // implement after integrate user
      );

      print('Order successfully placed with ID from wishlist page: $newOrderId');
      state = state.copyWith( isDBSuccess: true);
      return true;
    } catch (e) {
      // Handle the error (e.g., show a dialog)
      print('Failed to place order from wishlist page : $e');
      return false;
    }
  }
}

Future<bool> isItemSaveToDB(String itemId) async {
  final dbService = WishlistDatabaseServices();
  return await dbService.doesItemExist(itemIdToCheck: itemId);
}

Future<bool> saveToWishlistDB(Map<String, dynamic> selectedItem) async {
  final dbService = WishlistDatabaseServices();
  try {
    const String currentUserId = 'user_abc_123';
    // check the existence of item
    bool isItemexistinWishlist = await dbService.doesItemExist(
      itemIdToCheck: selectedItem['id'],
    );

    if (!isItemexistinWishlist) {
      // item not exist in the db, save the item to the db
      Map<String, dynamic> wishlistObject() {
        return {"item": selectedItem};
      }

      ;
      Map<String, dynamic> changeToObject = wishlistObject();

      String newOrderId = await dbService.CreateWishlistItem(
        itemId: selectedItem['id'],
        item: changeToObject,
        // userId: currentUserId, // implement after integrate user
      );

      print('Order successfully placed with ID: $newOrderId');
      return true;
    } else {
      // item exist
      print("item already exist in your wishlist");
      return false;
    }
    // state=state.copyWith(
    //   isLoading: false,
    //   isDBSuccess: true,
    // );
    return true;
  } catch (e) {
    // Handle the error (e.g., show a dialog)
    print('Failed to place order: $e');
    return false;
  }
}

Future<bool> removeWishlistItemFromDB(String itemId) async {
  final dbService = WishlistDatabaseServices();
  try {
    const String currentUserId = 'user_abc_123';

    int itemCount = await dbService.deleteItemsByNestedItemId(
      userId: currentUserId,
      itemIdToMatch: itemId,
      // userId: currentUserId, // implement after integrate user
    );

    print('${itemCount} items suceesfully deleted');
    // state=state.copyWith(
    //   isLoading: false,
    //   isDBSuccess: true,
    // );
    return true;
  } catch (e) {
    // Handle the error (e.g., show a dialog)
    print('Failed to place order: $e');
    return false;
  }
}
