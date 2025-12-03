import 'package:flutter/material.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/renter_repository.dart';
import 'package:easyrent/features/renter/renter_management/application/state/renter_state.dart';

class RenterNotifier extends ChangeNotifier {
  final RenterRepository repository;

  RenterNotifier(this.repository);

  RenterState state = const RenterState();

  // Load requested items
  Future<void> loadItems() async {
    state = state.copyWith(loading: true);
    notifyListeners();

    final items = await repository.getRequestedItems();
    state = state.copyWith(items: items, loading: false);

    notifyListeners();
  }

  // Approve item
  void approveItem(String id) {
    final index = state.items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final updatedItem = state.items[index].copyWith(status: "approved");
      final updatedItems = List<ItemEntity>.from(state.items);
      updatedItems[index] = updatedItem;
      state = state.copyWith(items: updatedItems);
      notifyListeners();
    }
  }

  // Reject item
  void rejectItem(String id) {
    final index = state.items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final updatedItem = state.items[index].copyWith(status: "rejected");
      final updatedItems = List<ItemEntity>.from(state.items);
      updatedItems[index] = updatedItem;
      state = state.copyWith(items: updatedItems);
      notifyListeners();
    }
  }
}
