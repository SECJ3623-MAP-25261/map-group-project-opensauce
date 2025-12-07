import '../../../../models/item.dart'; 

class ListingState {
  final List<Item> myItems; // Change type to Item
  final bool isLoading;

  const ListingState({
    this.myItems = const [],
    this.isLoading = false,
  });

  ListingState copyWith({
    List<Item>? myItems, // Change type to Item
    bool? isLoading,
  }) {
    return ListingState(
      myItems: myItems ?? this.myItems,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}