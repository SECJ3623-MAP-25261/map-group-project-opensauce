class Review {
  final double star; // Rating out of 5
  final String reviewText; // The written review

  Review({
    required this.star,
    required this.reviewText,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      star: (map['star'] as num?)?.toDouble() ?? 0.0,
      reviewText: map['reviewText'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'star': star,
      'reviewText': reviewText,
    };
  }
}