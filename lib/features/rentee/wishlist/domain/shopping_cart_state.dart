class ShoppingCartState {
  final double totalFee;
  final double renteeFee;
  final String deliveryOption;
  final double depositRate;
  final List<Map<String, dynamic>> items;

  // Constructor for the initial state
  const ShoppingCartState({
    required this.totalFee,
    required this.renteeFee,
    required this.depositRate,
    required this.deliveryOption,
    required this.items,
  });

  // Helper method to create a new state object (used for updates)
  ShoppingCartState copyWith({
    double? totalFee,
    double? renteeFee,
    String? deliveryOption,
    double? depositRate,
    List<Map<String, dynamic>>? items,
  }) {
    return ShoppingCartState(
      totalFee: totalFee ?? this.totalFee,
      renteeFee: renteeFee ?? this.renteeFee,
      deliveryOption: deliveryOption ?? this.deliveryOption,
      items: items ?? this.items,
      depositRate: depositRate ?? this.depositRate,
    );
  }
}
