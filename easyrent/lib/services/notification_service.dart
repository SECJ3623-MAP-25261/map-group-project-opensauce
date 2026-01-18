import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Initialize Notifications
  Future<void> initNotifications() async {
    // A. Request Permission (Required for iOS & Android 13+)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');

      // B. Get the Token
      String? token = await _messaging.getToken();
      debugPrint('FCM Token: $token');

      // C. Save to Firestore
      await _saveTokenToFirestore(token);

      // D. Listen for Token Refreshes (e.g., app reinstall)
      _messaging.onTokenRefresh.listen(_saveTokenToFirestore);
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  // 2. Save Token Logic
  Future<void> _saveTokenToFirestore(String? token) async {
    if (token == null) return;

    User? user = _auth.currentUser;
    if (user == null) return; // Wait until user is logged in

    try {
      await _db.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(), // Good for debugging
        'platform': defaultTargetPlatform
            .name, // Optional: helpful to know if iOS/Android
      });
      debugPrint("Token saved to Firestore for user: ${user.uid}");
    } catch (e) {
      debugPrint("Error saving token: $e");
    }
  }

  // 3. Send In-App Notification (Writes to Firestore)
  Future<void> sendInAppNotification({
    required String receiverId,
    required String title,
    required String body,
    required String type, // e.g., 'order_update', 'chat'
  }) async {
    try {
      await _db
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .add({
            'title': title,
            'body': body,
            'type': type,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint("Error sending in-app notification: $e");
    }
  }
}
