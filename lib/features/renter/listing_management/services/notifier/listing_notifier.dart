import 'package:flutter/material.dart';
import '../../domain/repositories/listing_repository.dart';
import '../state/listing_state.dart';
import '../../../renter_management/domain/entities/item_entity.dart';

class ListingNotifier extends ChangeNotifier {
  final ListingRepository repository;

  ListingNotifier(this.repository);

  ListingState state = const ListingState();

  List<ItemEntity> _fullList = []; 

  // Load Items
  Future<void> loadMyItems() async {
    state = state.copyWith(isLoading: true);
    notifyListeners();

    final items = await repository.getMyItems();

    _fullList = items; 
    state = state.copyWith(myItems: items, isLoading: false);
    
    notifyListeners();
  }

  // Search Items
  void searchItems(String query) {
    if (query.isEmpty) {
      state = state.copyWith(myItems: _fullList);
    } else {
      final filtered = _fullList.where((item) {
        return item.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      state = state.copyWith(myItems: filtered);
    }
    notifyListeners();
  }

  //  Add Item
  Future<void> addItem(ItemEntity newItem) async {
    state = state.copyWith(isLoading: true);
    notifyListeners();

    await repository.addItem(newItem);
    await loadMyItems(); 
  }

  //  Update Item
  Future<void> updateItem(ItemEntity updatedItem) async {
    state = state.copyWith(isLoading: true);
    notifyListeners();

    await repository.updateItem(updatedItem);
    await loadMyItems();
  }

  //  Delete Item
  Future<void> deleteItem(String itemId) async {
    state = state.copyWith(isLoading: true);
    notifyListeners();

    await repository.deleteItem(itemId);
    await loadMyItems();
  }
}