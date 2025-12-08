import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String reviewerName;
  final String reviewerImage;
  final DateTime date;
  final double star;
  final String reviewText;

  Review({
    required this.reviewerName,
    required this.reviewerImage,
    required this.date,
    required this.star,
    required this.reviewText,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewerName': reviewerName,
      'reviewerImage': reviewerImage,
      'date': Timestamp.fromDate(date),
      'star': star,
      'reviewText': reviewText,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      reviewerName: map['reviewerName'] ?? 'Anonymous',
      reviewerImage: map['reviewerImage'] ?? 'https://i.pravatar.cc/150?img=1',
      date: (map['date'] as Timestamp).toDate(),
      star: (map['star'] as num?)?.toDouble() ?? 0.0,
      reviewText: map['reviewText'] ?? '',
    );
  }
}