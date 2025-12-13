import 'package:easyrent/features/models/review.dart';
import 'package:easyrent/features/rentee/renting_status/data/dummy_data/renting_status_dummy.dart';
import 'package:easyrent/features/rentee/renting_status/domain/renting_status_state.dart';
import 'package:flutter_riverpod/legacy.dart';

class RentingStatusNotifier extends StateNotifier<RentingStatusState> {
  RentingStatusNotifier()
    : super(
      const RentingStatusState(
        hasReviewed: false, historyItem: []
      ));

  void setHasReviewed(String itemId, String review, double starRating) {
    final updatedItems =
        state.historyItem.map((item) {
          if (item.id == itemId) {
            final newReview = Review(
              reviewerId: item.ownerId,
              reviewerName: item.ownerName,
              reviewerImage: item.ownerImage,
              date: DateTime.now(),
              star: starRating,
              reviewText: review,
            );

            // Create a new list to maintain immutability
            final updatedReviews = List<Review>.from(item.reviews)
              ..add(newReview);

            return item.copyWith(reviews: updatedReviews);
          }
          return item;
        }).toList();

    state = state.copyWith(historyItem: updatedItems);
  }

  bool getHasReviewed(String itemId) {
    final findItem = state.historyItem.where((item) => item.id == itemId);

    if (findItem.isNotEmpty) {
      return findItem.first.reviews.isEmpty;
    }
    return false;
  }
}
