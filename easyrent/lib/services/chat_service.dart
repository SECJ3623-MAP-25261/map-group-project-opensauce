import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. GET OR CREATE CHAT
  Future<String> getOrCreateChat(String otherUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    // Check for existing chat
    final QuerySnapshot existingChats = await _db
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .get();

    String? chatId;

    for (var doc in existingChats.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final participants = List<String>.from(data['participants']);
      if (participants.contains(otherUserId)) {
        chatId = doc.id;
        break;
      }
    }

    if (chatId != null) return chatId;

    // Create New Chat
    final docRef = _db.collection('chats').doc();
    await docRef.set({
      'chatId': docRef.id,
      'participants': [currentUser.uid, otherUserId],
      'lastMessage': 'Chat started',
      'lastTime': FieldValue.serverTimestamp(),
      'createdBy': currentUser.uid,
    });

    return docRef.id;
  }

  // 2. SEND PRODUCT CARD (With Smart Duplicate Check)
  Future<void> sendProductMessage(
    String chatId,
    Map<String, dynamic> productData,
  ) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Check duplicate logic
    final bool shouldSend = await _shouldSendProductCard(
      chatId,
      productData['bookingId'],
    );

    if (!shouldSend) {
      print("DEBUG: Skipped sending duplicate product card.");
      return;
    }

    final timestamp = FieldValue.serverTimestamp();
    final String title = productData['title'] ?? 'Item';

    // Add message
    await _db.collection('chats').doc(chatId).collection('messages').add({
      'senderId': currentUser.uid,
      'type': 'product',
      'text': 'Inquiry: $title',
      'productData': productData,
      'timestamp': timestamp,
    });

    // Update summary
    await _db.collection('chats').doc(chatId).update({
      'lastMessage': 'Inquiry: $title',
      'lastTime': timestamp,
    });
  }

  // PRIVATE HELPER: Checks last 20 messages for duplicates
  Future<bool> _shouldSendProductCard(
    String chatId,
    String? currentBookingId,
  ) async {
    if (currentBookingId == null) return true;

    final querySnapshot = await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(20) // Look back 20 messages
        .get();

    if (querySnapshot.docs.isEmpty) return true;

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      if (data['type'] == 'product') {
        final lastData = data['productData'] as Map<String, dynamic>?;
        if (lastData != null && lastData['bookingId'] == currentBookingId) {
          return false; // Found duplicate recently
        }
      }
    }
    return true;
  }

  // 3. SEND TEXT MESSAGE
  Future<void> sendMessage(String chatId, String text) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || text.trim().isEmpty) return;

    final timestamp = FieldValue.serverTimestamp();

    await _db.collection('chats').doc(chatId).collection('messages').add({
      'senderId': currentUser.uid,
      'text': text.trim(),
      'timestamp': timestamp,
      'type': 'text',
    });

    await _db.collection('chats').doc(chatId).update({
      'lastMessage': text.trim(),
      'lastTime': timestamp,
    });
  }

  // 4. STREAM MESSAGES
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 5. GET USER CHATS
  Stream<QuerySnapshot> getUserChats() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.empty();

    return _db
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastTime', descending: true)
        .snapshots();
  }
}
