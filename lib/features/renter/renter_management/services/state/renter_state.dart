import '../../../../../features/models/rentalitem.dart';

class RenterState {
  final List<RentalItem> rentalitems;
  final bool loading;
  final String? errorMessage;

  const RenterState({
    this.rentalitems = const [],
    this.loading = false,
    this.errorMessage,
  });

  factory RenterState.initial() => const RenterState();

  RenterState copyWith({
    List<RentalItem>? rentalitems,
    bool? loading,
    String? errorMessage,
  }) {
    return RenterState(
      rentalitems: rentalitems ?? this.rentalitems,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}