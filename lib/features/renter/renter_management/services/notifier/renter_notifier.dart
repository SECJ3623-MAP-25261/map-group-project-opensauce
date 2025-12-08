import 'package:flutter/material.dart';
import '../../../../models/rentalitem.dart';
import '../../domain/repositories/renter_repository.dart';
import 'package:easyrent/features/renter/renter_management/services/state/renter_state.dart';

class RenterNotifier extends ChangeNotifier {
  final RenterRepository repository;

  RenterNotifier(this.repository);

  RenterState state = const RenterState();

  Future<void> loadItems() async {
    if (state.rentalitems.isEmpty) {
      state = state.copyWith(loading: true);
      notifyListeners();
    }

    try {
      final rentalitems = await repository.getRequestedItems();
      state = state.copyWith(rentalitems: rentalitems, loading: false);
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