class CheckoutState {
  final double totalFee;
  final double renteeFee;
  final String deliveryOption;
  final double depositRate;
  final bool isLoading ;
  final List<Map<String, dynamic>> items;

  // Constructor for the initial state
  const CheckoutState({
    required this.totalFee,
    required this.renteeFee,
    required this.depositRate,
    required this.deliveryOption,
    required this.items,
    required this.isLoading,
  });

  // Helper method to create a new state object (used for updates)
  CheckoutState copyWith({
    double? totalFee,
    double? renteeFee,
    String? deliveryOption,
    double? depositRate,
    List<Map<String, dynamic>>? items,
    bool? isLoading,
  }) {
    return CheckoutState(
      totalFee: totalFee ?? this.totalFee,
      renteeFee: renteeFee ?? this.renteeFee,
      deliveryOption: deliveryOption ?? this.deliveryOption,
      items: items ?? this.items,
      depositRate: depositRate ?? this.depositRate,
      isLoading: isLoading ?? this.isLoading
    );
  }
}
