class CheckoutState {
  final double totalFee;
  final double renteeFee;
  final String deliveryOption;
  final double depositRate;
  final bool isLoading ;
  final bool isDBSuccess;
  final Map<String, dynamic> items;
  final DateTime? startRenting;
  final DateTime? endRenting;
  final int? duration;
  final bool? isOrderComplete; // if the user receive the order, it will be true

  // Constructor for the initial state
  const CheckoutState({
    required this.totalFee,
    required this.renteeFee,
    required this.depositRate,
    required this.deliveryOption,
    required this.items,
    required this.isLoading,
    required this.startRenting,
    required this.endRenting,
    required this.duration,
    required this.isDBSuccess,
    required this.isOrderComplete
  });

  // change to JSON to store in db
  Map<String, dynamic> toJson() {
    return {
      'totalFee': totalFee,
      'renteeFee': renteeFee,
      'deliveryOption': deliveryOption,
      // The items Map is already in the correct format
      'items': items, 
      'depositRate': depositRate,
      'isLoading': isLoading,
      'startRenting': startRenting?.toIso8601String(),
      'endRenting': endRenting?.toIso8601String(), 
      'duration': duration,
      'isOrderComplete': duration,
    };
  }

  // Helper method to create a new state object (used for updates)
  CheckoutState copyWith({
    double? totalFee,
    double? renteeFee,
    String? deliveryOption,
    double? depositRate,
    Map<String, dynamic>? items,
    bool? isLoading,
    DateTime? startRenting,
    DateTime? endRenting,
    int? duration,
    bool? isDBSuccess,
    bool? isOrderComplete
  }) {
    return CheckoutState(
      totalFee: totalFee ?? this.totalFee,
      renteeFee: renteeFee ?? this.renteeFee,
      deliveryOption: deliveryOption ?? this.deliveryOption,
      items: items ?? this.items,
      depositRate: depositRate ?? this.depositRate,
      isLoading: isLoading ?? this.isLoading,
      startRenting: startRenting ?? this.startRenting,
      endRenting: endRenting ?? this.endRenting,
      duration: duration?? this.duration,
      isDBSuccess: isDBSuccess ?? this.isDBSuccess,
      isOrderComplete: isOrderComplete ?? this.isOrderComplete,
    );
  }
}
