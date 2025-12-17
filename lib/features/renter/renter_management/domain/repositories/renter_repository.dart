import '../../../../../features/models/rentalitem.dart';

abstract class RenterRepository {
  Future<List<RentalItem>> getRequestedItems();
  Future<void> updateItemStatus(String id, String status);
}