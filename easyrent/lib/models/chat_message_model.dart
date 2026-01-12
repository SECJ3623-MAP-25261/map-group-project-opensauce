import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String text;
  final String type; // 'text' or 'product'
  final Timestamp timestamp;
  final Map<String, dynamic>? productData;

  ChatMessage({
    required this.senderId,
    required this.text,
    required this.type,
    required this.timestamp,
    this.productData,
  });

  // Factory to create from Firestore Map
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      type: map['type'] ?? 'text',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      productData: map['productData'],
    );
  }
}
