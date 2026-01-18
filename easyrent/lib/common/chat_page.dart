import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/chat_service.dart';
import '../../widgets/chat/message_bubbles.dart';
import '../../widgets/chat/chat_input_field.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const ChatPage({super.key, required this.chatId, required this.otherUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late Stream<QuerySnapshot> _messagesStream;

  @override
  void initState() {
    super.initState();
    // Initialize stream here to prevent keyboard reload glitches
    _messagesStream = _chatService.getMessages(widget.chatId);
  }

  Future<DocumentSnapshot> _getOtherUserProfile() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.otherUserId)
        .get();
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    String text = _controller.text;
    _controller.clear();
    await _chatService.sendMessage(widget.chatId, text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF800000),
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: FutureBuilder<DocumentSnapshot>(
          future: _getOtherUserProfile(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("Chat", style: TextStyle(color: Colors.white));
            }
            var data = snapshot.data!.data() as Map<String, dynamic>;
            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      (data['profileImage'] != null &&
                          data['profileImage'] != "")
                      ? NetworkImage(data['profileImage'])
                      : null,
                  child:
                      (data['profileImage'] == null ||
                          data['profileImage'] == "")
                      ? const Icon(
                          Icons.person,
                          color: Color(0xFF800000),
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  data['displayName'] ?? "User",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.hasData ? snapshot.data!.docs : [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "Say hello! 👋",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    return MessageBubble(
                      data: data,
                      isMe: data['senderId'] == currentUserId,
                      chatId: widget.chatId,
                      messageId: messages[index].id,
                    );
                  },
                );
              },
            ),
          ),
          ChatInputField(controller: _controller, onSend: _sendMessage),
        ],
      ),
    );
  }
}
