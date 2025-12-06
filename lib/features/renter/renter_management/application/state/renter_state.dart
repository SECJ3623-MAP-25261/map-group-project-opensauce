import '../../domain/entities/item_entity.dart';

class RenterState {
  final List<ItemEntity> items;
  final bool loading;
  final String? errorMessage;

  const RenterState({
    this.items = const [],
    this.loading = false,
    this.errorMessage,
  });

  factory RenterState.initial() => const RenterState();

  RenterState copyWith({
    List<ItemEntity>? items,
    bool? loading,
    String? errorMessage,
  }) {
    return RenterState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}