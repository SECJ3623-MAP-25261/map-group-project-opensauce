import '../entities/item_entity.dart';

abstract class RenterRepository {
  Future<List<ItemEntity>> getRequestedItems();
}
