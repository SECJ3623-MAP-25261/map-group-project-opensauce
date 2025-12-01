import 'package:easyrent/features/rentee/renting_status/data/dummy_data/renting_status_dummy.dart';
import 'package:easyrent/features/rentee/renting_status/domain/renting_status_state.dart';
import 'package:flutter_riverpod/legacy.dart';

class RentingStatusNotifier extends StateNotifier<RentingStatusState> {

  RentingStatusNotifier() : super (
    const RentingStatusState(
      hasReviewed: false,
      historyItem: userOrderHistory,
    )
  );

  void setHasReviewed (String itemId , bool review) {
    final updateItem = state.historyItem.map((item) {
        if(item['id'] == itemId) {
            return Map<String, dynamic>.from(item) 
            ..['hasReviewed'] = review; 
        }
        return item;
    }).toList();
      state = state.copyWith(
        historyItem: updateItem,
      );
  }

  bool getHasReviewed (String itemId) {
    final findItem = state.historyItem.where((item) => item['id'] == itemId);

    if(findItem.isNotEmpty){
      return findItem.first['hasReviewed'] ?? false;
    }
    return false;
  }
}