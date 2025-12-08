class ShoppingCartState {
  final double totalFee;
  final double renteeFee;
  final String deliveryOption;
  final double depositRate;
  final List<Map<String, dynamic>> items;
  final bool isDBSuccess;

  // Constructor for the initial state
  const ShoppingCartState({
    required this.totalFee,
    required this.renteeFee,
    required this.depositRate,
    required this.deliveryOption,
    required this.items,
    required this.isDBSuccess
  });

  // Helper method to create a new state object (used for updates)
  ShoppingCartState copyWith({
    double? totalFee,
    double? renteeFee,
    String? deliveryOption,
    double? depositRate,
    List<Map<String, dynamic>>? items,
    bool? isDBSuccess
  }) {
    return ShoppingCartState(
      totalFee: totalFee ?? this.totalFee,
      renteeFee: renteeFee ?? this.renteeFee,
      deliveryOption: deliveryOption ?? this.deliveryOption,
      items: items ?? this.items,
      depositRate: depositRate ?? this.depositRate,
      isDBSuccess: isDBSuccess ?? this.isDBSuccess,
    );
  }

    // change to JSON to store in db
  Map<String, dynamic> toJson() {
    return {
      'totalFee': totalFee,
      'renteeFee': renteeFee,
      'deliveryOption': deliveryOption,
      // The items Map is already in the correct format
      'items': items, 
      'depositRate': depositRate,
      // 'startRenting': startRenting?.toIso8601String(),
      // 'endRenting': endRenting?.toIso8601String(), 
      // 'duration': duration,
      // 'isOrderComplete': duration,
    };
  }
}
