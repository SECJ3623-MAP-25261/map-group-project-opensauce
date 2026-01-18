import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? parseDate(dynamic value) {
  if (value == null) return null;

  if (value is DateTime) return value;

  if (value is Timestamp) return value.toDate();

  if (value is String) return DateTime.parse(value);

  return null;
}
