import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/chat_service.dart'; // Import ChatService

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isMe;
  final String chatId;
  final String messageId;

  const MessageBubble({
    super.key,
    required this.data,
    required this.isMe,
    required this.chatId,
    required this.messageId,
  });

  @override
  Widget build(BuildContext context) {
    Widget bubble;
    if (data['type'] == 'product') {
      bubble = _ProductMessageCard(data: data, isMe: isMe);
    } else {
      bubble = _TextMessageBubble(data: data, isMe: isMe);
    }

    return _ReactionWrapper(
      chatId: chatId,
      messageId: messageId,
      data: data,
      isMe: isMe,
      child: bubble,
    );
  }
}

class _TextMessageBubble extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isMe;

  const _TextMessageBubble({required this.data, required this.isMe});

  @override
  Widget build(BuildContext context) {
    String time = _formatTime(data['timestamp']);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF800000) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              data['text'] ?? "",
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductMessageCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isMe;

  const _ProductMessageCard({required this.data, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final product = data['productData'] as Map<String, dynamic>? ?? {};
    final String image = product['image'] ?? '';
    final String title = product['title'] ?? 'Item Inquiry';
    final String price = product['price'] ?? '';
    final String status = product['status'] ?? '';
    String time = _formatTime(data['timestamp']);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: 260,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Inquiry: ${status.toUpperCase()}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: image.isNotEmpty
                          ? Image.network(image, fit: BoxFit.cover)
                          : const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          price,
                          style: const TextStyle(
                            color: Color(0xFF800000),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  time,
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(dynamic timestamp) {
  if (timestamp != null && timestamp is Timestamp) {
    return DateFormat('h:mm a').format(timestamp.toDate());
  }
  return "";
}

// WRAPPER FOR GESTURE + REACTION DISPLAY
class _ReactionWrapper extends StatelessWidget {
  final String chatId;
  final String messageId;
  final Map<String, dynamic> data;
  final bool isMe;
  final Widget child;

  const _ReactionWrapper({
    required this.chatId,
    required this.messageId,
    required this.data,
    required this.isMe,
    required this.child,
  });

  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["👍", "❤️", "😂", "😮", "😢", "😡"].map((emoji) {
              return GestureDetector(
                onTap: () {
                  ChatService().toggleReaction(chatId, messageId, emoji);
                  Navigator.pop(context);
                },
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> reactions = data['reactions'] != null
        ? Map<String, dynamic>.from(data['reactions'])
        : {};

    // Group reactions count
    final Map<String, int> counts = {};
    reactions.forEach((uid, emoji) {
      counts[emoji] = (counts[emoji] ?? 0) + 1;
    });

    return GestureDetector(
      onLongPress: () => _showReactionPicker(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          if (counts.isNotEmpty)
            Positioned(
              bottom: -15, // moved up slightly
              right: isMe ? 10 : null,
              left: isMe ? null : 10, // Show reactions on correct side
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(blurRadius: 2, color: Colors.black12),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: counts.entries.map((e) {
                    return Text(
                      "${e.key} ${e.value > 1 ? e.value : ''}",
                      style: const TextStyle(fontSize: 12),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
