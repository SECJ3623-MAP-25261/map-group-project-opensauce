import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String reviewerId;
  final String reviewerName;
  final String reviewerImage;
  final DateTime date;
  final double star;
  final String reviewText;

  Review({
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerImage,
    required this.date,
    required this.star,
    required this.reviewText,
  });

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

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? 'Anonymous',
      reviewerImage: map['reviewerImage'] ?? 'https://i.pravatar.cc/150?img=1',
      date: Review._parseDate(map['date'])!,
      // date: (map['date'] as Timestamp).toDate(),
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


static DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  
  // 1. If it's already a Timestamp (Direct Firestore)
  if (value is Timestamp) return value.toDate();
  
  // 2. If it's a Map (Node.js/HTTP format: {_seconds: ..., _nanoseconds: ...})
  if (value is Map) {
    final seconds = value['_seconds'];
    if (seconds != null) {
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    }
  }
  
  // 3. If it's a String (ISO format)
  if (value is String) return DateTime.tryParse(value);
  
  return null;
}
}