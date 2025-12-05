
import 'package:easyrent/features/rentee/checkout/services/checkout_notifier.dart';
import 'package:easyrent/features/rentee/checkout/domain/checkout_state.dart';
import 'package:flutter_riverpod/legacy.dart';

final checkoutProvider = StateNotifierProvider<CheckoutNotifier,CheckoutState>(
  (ref) {
      return CheckoutNotifier();
  }
);