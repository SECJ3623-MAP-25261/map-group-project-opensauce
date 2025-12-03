import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/renter_repository.dart';
import '../datasources/renter_remote_api.dart';

class RenterRepositoryImpl implements RenterRepository {
  final RenterRemoteApi api;

  RenterRepositoryImpl(this.api);

  @override
  Future<List<ItemEntity>> getRequestedItems() async {
    final list = await api.fetchRequestedItems();

    return list.map((e) => ItemEntity(
      id: e["id"],          // make sure id exists
      name: e["name"],
      price: e["price"],
      rentalInfo: e["rentalInfo"],
      imageUrl: e["imageUrl"],
      status: e["status"] ?? "pending",  // optional
    )).toList();
  }
}
