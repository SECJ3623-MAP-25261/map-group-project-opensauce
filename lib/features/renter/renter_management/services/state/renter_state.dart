import '../../domain/entities/item_entity.dart';

class RenterState {
  final List<ItemEntity> items;
  final bool loading;

  const RenterState({
    this.items = const [],
    this.loading = false,
  });

  RenterState copyWith({
    List<ItemEntity>? items,
    bool? loading,
  }) {
    return RenterState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
    );
  }
}
