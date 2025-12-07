import '../../../../../features/models/item.dart';
import '../../domain/repositories/renter_repository.dart';
import '../datasources/renter_remote_api.dart';

class RenterRepositoryImpl implements RenterRepository {
  final RenterRemoteApi api;

  RenterRepositoryImpl(this.api);

  @override
  Future<List<Item>> getRequestedItems() async {
    return await api.fetchRequestedItems();
  }

  @override
  Future<void> updateItemStatus(String id, String status) async {
    await api.updateItemStatus(id, status);
  }
}