import '../../../../../features/models/item.dart';

abstract class RenterRepository {
  Future<List<Item>> getRequestedItems();
  Future<void> updateItemStatus(String id, String status);
}