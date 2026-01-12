import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatTile extends StatelessWidget {
  final String chatId;
  final String otherUserId;
  final String lastMessage;
  final Timestamp? lastTime;
  final Function(String chatId, String otherUserId) onTap;

  const ChatTile({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.lastMessage,
    required this.lastTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get(),
      builder: (context, snapshot) {
        String name = "Loading...";
        String image = "";

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData != null) {
            name = userData['displayName'] ?? "Unknown User";
            image = userData['profileImage'] ?? "";
          }
        }

        String timeString = "";
        if (lastTime != null) {
          final date = lastTime!.toDate();
          final now = DateTime.now();
          if (date.year == now.year &&
              date.month == now.month &&
              date.day == now.day) {
            timeString = DateFormat('h:mm a').format(date);
          } else {
            timeString = DateFormat('MMM d').format(date);
          }
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[200],
            backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
            child: image.isEmpty
                ? const Icon(Icons.person, color: Colors.grey, size: 28)
                : null,
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[600], height: 1.5),
          ),
          trailing: Text(
            timeString,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          onTap: () => onTap(chatId, otherUserId),
        );
      },
    );
  }
}
