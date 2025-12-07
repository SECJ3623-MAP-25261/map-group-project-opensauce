import 'package:flutter/material.dart';
import '../../../../models/item.dart';
import '../../domain/repositories/renter_repository.dart';
import '../state/renter_state.dart';

class RenterNotifier extends ChangeNotifier {
  final RenterRepository repository;

  RenterNotifier(this.repository);

  RenterState state = const RenterState();

  Future<void> loadItems() async {
    if (state.items.isEmpty) {
      state = state.copyWith(loading: true);
      notifyListeners();
    }

    try {
      final items = await repository.getRequestedItems();
      state = state.copyWith(items: items, loading: false);
    } catch (e) {
      print("Error loading items: $e");
      state = state.copyWith(loading: false, errorMessage: e.toString());
    }
    notifyListeners();
  }

  // --- Status Updates ---

  Future<void> approveItem(String id) async {
    await repository.updateItemStatus(id, "approved");
    await loadItems(); 
  }

  Future<void> rejectItem(String id) async {
    await repository.updateItemStatus(id, "rejected");
    await loadItems(); 
  }

  Future<void> stopRent(String id) async {
    await repository.updateItemStatus(id, "completed");
    await loadItems(); 
  }

  // NEW: Toggle Availability
  Future<void> setAvailability(String id, String newStatus) async {
    // newStatus should be 'available' or 'on_hold'
    await repository.updateItemStatus(id, newStatus);
    await loadItems();
  }
}