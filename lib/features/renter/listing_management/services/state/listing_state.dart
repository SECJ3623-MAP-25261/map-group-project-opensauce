import '../../../../models/item.dart'; 

class ListingState {
  final List<Item> myItems;
  final bool isLoading;

  const ListingState({
    this.myItems = const [],
    this.isLoading = false,
  });

  ListingState copyWith({
    List<Item>? myItems,
    bool? isLoading,
  }) {
    return ListingState(
      myItems: myItems ?? this.myItems,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}