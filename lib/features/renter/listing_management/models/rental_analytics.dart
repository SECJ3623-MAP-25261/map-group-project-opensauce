class RentalAnalytics {
  final int totalEarnings;
  final int totalOrders;
  final int totalDuration;

  RentalAnalytics({
    required this.totalEarnings,
    required this.totalOrders,
    required this.totalDuration,
  });

  factory RentalAnalytics.fromJson(Map<String, dynamic> json) {
    return RentalAnalytics(
      // The '?? 0' part ensures the app doesn't crash if data is missing
      totalEarnings: json['totalEarnings'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalDuration: json['totalDuration'] ?? 0,
    );
  }
}