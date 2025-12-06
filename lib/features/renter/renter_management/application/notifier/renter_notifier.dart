import 'package:flutter/material.dart';
import '../../domain/repositories/renter_repository.dart';
import '../state/renter_state.dart';

class RenterNotifier extends ChangeNotifier {
  final RenterRepository _repository;

  RenterNotifier(this._repository);

  RenterState _state = RenterState.initial();
  RenterState get state => _state;

  Future<void> loadItems() async {
    _state = _state.copyWith(loading: true, errorMessage: null);
    notifyListeners();

    try {
      final items = await _repository.getRequestedItems();
      _state = _state.copyWith(items: items, loading: false);
    } catch (e) {
      _state = _state.copyWith(loading: false, errorMessage: e.toString());
      print("Error: $e");
    }
    notifyListeners();
  }

  Future<void> approveItem(String id) async {
    await _repository.updateItemStatus(id, 'approved');
    await loadItems(); // Refresh the list
  }

  Future<void> rejectItem(String id) async {
    await _repository.updateItemStatus(id, 'rejected');
    await loadItems(); // Refresh the list
  }
}