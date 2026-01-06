import 'package:flutter/material.dart';
import '../../domain/repositories/listing_repository.dart';
import '../state/listing_state.dart';
import '../../../../models/item.dart';

class ListingNotifier extends ChangeNotifier {
  final ListingRepository repository;

  ListingNotifier(this.repository);

  ListingState state = const ListingState();

  // Hidden Memory for Search
  List<Item> _fullList = []; 

  // 1. Load Items
  Future<void> loadMyItems() async {
    state = state.copyWith(isLoading: true);
    notifyListeners();

    final items = await repository.getMyItems();

    _fullList = items; 
    state = state.copyWith(myItems: items, isLoading: false);
    notifyListeners();
  }

  // 2. Search
  void searchItems(String query) {
    if (query.isEmpty) {
      state = state.copyWith(myItems: _fullList);
    } else {
      final filtered = _fullList.where((item) {
        return item.productName.toLowerCase().contains(query.toLowerCase());
      }).toList();
      state = state.copyWith(myItems: filtered);
    }
    notifyListeners();
  }

  // 3. Add
  Future<void> addItem(Item newItem) async {
    state = state.copyWith(isLoading: true);
    notifyListeners();

    await repository.addItem(newItem);
    await loadMyItems(); 
  }

  // 4. Update
  Future<void> updateItem(Item updatedItem) async {
    state = state.copyWith(isLoading: true);
    notifyListeners();

    await repository.updateItem(updatedItem);
    await loadMyItems();
  }

  // 5. Delete
  Future<void> deleteItem(String itemId) async {
    state = state.copyWith(isLoading: true);
    notifyListeners();

    await repository.deleteItem(itemId);
    await loadMyItems();
  }
}