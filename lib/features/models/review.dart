import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String reviewerId;
  final String reviewerName;
  final String reviewerImage;
  final DateTime date;
  final double star; // Rating out of 5
  final String reviewText; // The written review

  Review({
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerImage,
    required this.date,
    required this.star,
    required this.reviewText,
  });

  // Convert to Map for uploading to Firestore
  Map<String, dynamic> toMap() {
    return {
      'reviewerId' : reviewerId,
      'reviewerName': reviewerName,
      'reviewerImage': reviewerImage,
      'date': Timestamp.fromDate(date),
      'star': star,
      'reviewText': reviewText,
    };
  }

  // Create Review object from Firestore Map
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? 'Anonymous',
      reviewerImage: map['reviewerImage'] ?? 'https://i.pravatar.cc/150?img=1',
      date: (map['date'] as Timestamp).toDate(),
      star: (map['star'] as num?)?.toDouble() ?? 0.0,
      reviewText: map['reviewText'] ?? '',
    );
    }

    Review copyWith({
    String? reviewerName,
    String? reviewerImage,
    DateTime? date,
    double? star,
    String? reviewText,
    String? reviewerId
  }) {
    return Review(
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerImage: reviewerImage ?? this.reviewerImage,
      date: date ?? this.date,
      star: star ?? this.star,
      reviewText: reviewText ?? this.reviewText,
    );
  }

}
