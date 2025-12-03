import '../../domain/repositories/listing_repository.dart';
import '../../../renter_management/domain/entities/item_entity.dart';
import '../../../renter_management/data/mock/dummy_data.dart';

class ListingRepositoryImpl implements ListingRepository {
  @override
  Future<List<ItemEntity>> getMyItems() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return dummyItems;
  }

  @override
  Future<void> addItem(ItemEntity item) async {
    await Future.delayed(const Duration(milliseconds: 500));
    dummyItems.add(item);
  }

  @override
  Future<void> updateItem(ItemEntity item) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = dummyItems.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      dummyItems[index] = item;
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    dummyItems.removeWhere((item) => item.id == id);
  }
}