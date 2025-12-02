import 'package:easyrent/features/rentee/wishlist/domain/shopping_cart_state.dart';
import 'package:easyrent/features/rentee/wishlist/application/wishlist_notifier.dart';
import 'package:flutter_riverpod/legacy.dart';

final shoppingCartProvider = StateNotifierProvider<ShoppingCart, ShoppingCartState>(
  (ref) {
    return ShoppingCart();
  },
);