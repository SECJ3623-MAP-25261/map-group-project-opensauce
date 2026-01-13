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

    try {
      final items = await repository.getMyItems().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          return _fullList;
        },
      );

      _fullList = items;
      state = state.copyWith(myItems: items);
    } catch (e) {
      print("Load Items Error: $e");
    } finally {
      state = state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  // 2. Search
  void searchItems(String query) {
    if (query.isEmpty) {
      state = state.copyWith(myItems: _fullList);
    } else {
      final filtered =
          _fullList.where((item) {
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

    try {
      await repository
          .addItem(newItem)
          .timeout(const Duration(seconds: 3), onTimeout: () {});

      await loadMyItems();
    } catch (e) {
      print("Add Item Error: $e");
    } finally {
      state = state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  // 4. Update
  Future<void> updateItem(Item updatedItem) async {
    state = state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await repository
          .updateItem(updatedItem)
          .timeout(const Duration(seconds: 3), onTimeout: () {});

      await loadMyItems();
    } catch (e) {
      print("Update Item Error: $e");
    } finally {
      state = state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  // 5. Delete
  Future<void> deleteItem(String itemId) async {
    state = state.copyWith(isLoading: true);
    notifyListeners();

    await repository.deleteItem(itemId);
    await loadMyItems();
  }
}
