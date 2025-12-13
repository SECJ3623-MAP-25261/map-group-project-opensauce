import 'package:easyrent/features/models/item.dart';

class RentingStatusState {
  final bool hasReviewed;
  final List<Item> historyItem;

  const RentingStatusState ({
    required this.hasReviewed,
    required this.historyItem,
  });

  RentingStatusState copyWith ({
    bool? hasReviewed,
    List<Item>? historyItem
  }) {
    return RentingStatusState(
      hasReviewed: hasReviewed ?? this.hasReviewed,
      historyItem: historyItem ?? this.historyItem,
    );
  }
}
