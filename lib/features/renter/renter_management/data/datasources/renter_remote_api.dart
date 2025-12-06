import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

abstract class RenterRemoteApi {
  Future<List<ItemModel>> fetchRequestedItems();
  Future<void> updateItemStatus(String id, String status);
}

class RenterRemoteApiImpl implements RenterRemoteApi {
  final FirebaseFirestore firestore;

  RenterRemoteApiImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ItemModel>> fetchRequestedItems() async {
    final snapshot = await firestore.collection('renter_items').get();
    return snapshot.docs.map((doc) => ItemModel.fromSnapshot(doc)).toList();
  }

  @override
  Future<void> updateItemStatus(String id, String status) async {
    await firestore.collection('renter_items').doc(id).update({
      'status': status,
    });
  }
}