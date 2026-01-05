import 'package:flutter/material.dart';
import 'package:easyrent/features/models/rentalitem.dart';
import '../repositories/notification_repository.dart';

// 1. The State Class (Simple version of RenterState)
class NotificationState {
  final List<RentalItem> items;
  final bool loading;
  final String? errorMessage;

  const NotificationState({
    this.items = const [],
    this.loading = false,
    this.errorMessage,
  });

  NotificationState copyWith({
    List<RentalItem>? items,
    bool? loading,
    String? errorMessage,
  }) {
    return NotificationState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}

// 2. The Notifier Class
class NotificationNotifier extends ChangeNotifier {
  final NotificationRepository repository;

  NotificationNotifier(this.repository);

  NotificationState state = const NotificationState();

  Future<void> loadNotifications() async {
    // Set loading to true
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      // Fetch from Repository
      final items = await repository.getApprovedItems();

      // Update State with Success
      state = state.copyWith(items: items, loading: false);
    } catch (e) {
      // Update State with Error
      state = state.copyWith(loading: false, errorMessage: e.toString());
    }
    notifyListeners();
  }
}
