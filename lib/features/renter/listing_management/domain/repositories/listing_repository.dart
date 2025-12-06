import '../../../renter_management/domain/entities/item_entity.dart';

abstract class ListingRepository {
  Future<List<ItemEntity>> getMyItems();
  Future<void> addItem(ItemEntity item);
  Future<void> updateItem(ItemEntity item);
  Future<void> deleteItem(String id);
}