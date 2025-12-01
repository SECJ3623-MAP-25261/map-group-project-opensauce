class RentingStatusState {
  final bool hasReviewed;
  final List<Map<String,dynamic>> historyItem;

  const RentingStatusState ({
    required this.hasReviewed,
    required this.historyItem,
  });

  RentingStatusState copyWith ({
    bool? hasReviewed,
    List<Map<String,dynamic>>? historyItem
  }) {
    return RentingStatusState(
      hasReviewed: hasReviewed ?? this.hasReviewed,
      historyItem: historyItem ?? this.historyItem,
    );
  }
}
