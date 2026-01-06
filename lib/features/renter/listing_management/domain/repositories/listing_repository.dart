import '../../../../models/item.dart'; 

abstract class ListingRepository {

  Future<List<Item>> getMyItems();
  
  Future<void> addItem(Item item);
  
  Future<void> updateItem(Item item);
  
  Future<void> deleteItem(String id);
}