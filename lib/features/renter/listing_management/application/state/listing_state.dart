import '../../../renter_management/domain/entities/item_entity.dart';

class ListingState {
  final List<ItemEntity> myItems; 
  final bool isLoading;           

  const ListingState({
    this.myItems = const [],
    this.isLoading = false,
  });

  ListingState copyWith({
    List<ItemEntity>? myItems,
    bool? isLoading,
  }) {
    return ListingState(
      myItems: myItems ?? this.myItems,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}