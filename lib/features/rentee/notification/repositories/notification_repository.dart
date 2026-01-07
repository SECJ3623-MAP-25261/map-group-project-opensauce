import 'package:easyrent/features/models/rentalitem.dart';
import '../datasources/notification_remote_api.dart';

abstract class NotificationRepository {
  Future<List<RentalItem>> getApprovedItems();
}

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteApi api;

  NotificationRepositoryImpl(this.api);

  @override
  Future<List<RentalItem>> getApprovedItems() async {
    // 1. Get ALL items
    final allItems = await api.fetchApprovedNotifications();

    // 2. Filter manually in Dart (Case Insensitive!)
    final approvedList =
        allItems.where((item) {
          final status = item.status.toLowerCase().trim(); // Make it lowercase
          return status == 'approved'; // Check against lowercase
        }).toList();

    print("✅ REPO: Filtered down to ${approvedList.length} approved items.");
    return approvedList;
  }
}
