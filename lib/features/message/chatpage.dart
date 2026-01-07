import 'package:flutter/material.dart';

// Mock数据模型
class ChatMessage {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isSentByMe;
  final MessageStatus status;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isSentByMe,
    this.status = MessageStatus.sent,
    this.imageUrl,
  });
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
}

// Mock数据
class MockChatData {
  static final List<ChatMessage> messages = [
    // Morning conversation about project
    ChatMessage(
      id: '1',
      content: 'Hey! Good morning ☀️',
      timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 30)),
      isSentByMe: false,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '2',
      content: 'Did you finish that sensor integration we talked about?',
      timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 29)),
      isSentByMe: false,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '3',
      content: 'Morning! ☕',
      timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 15)),
      isSentByMe: true,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '4',
      content: 'Yeah! Actually just deployed it last night',
      timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 14)),
      isSentByMe: true,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '5',
      content: 'The DHT11 and AP3216C are working perfectly',
      timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 13)),
      isSentByMe: true,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '6',
      content: 'But the ADXL345 gave me some trouble with the I2C communication',
      timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 12)),
      isSentByMe: true,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '7',
      content: 'Took me like 3 hours to debug 😅',
      timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 11)),
      isSentByMe: true,
      status: MessageStatus.read,
    ),

    // Response after a bit
    ChatMessage(
      id: '8',
      content: 'Wow that\'s awesome! 🎉',
      timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 45)),
      isSentByMe: false,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '9',
      content: 'I2C issues are the worst lol',
      timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 44)),
      isSentByMe: false,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '10',
      content: 'What was the problem?',
      timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 43)),
      isSentByMe: false,
      status: MessageStatus.read,
    ),

    // Detailed explanation
    ChatMessage(
      id: '11',
      content: 'Address conflict with another device on the bus',
      timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
      isSentByMe: true,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '12',
      content: 'Had to change the ADXL345 to its alternate address',
      timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 29)),
      isSentByMe: true,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '13',
      content: 'Classic rookie mistake 😂',
      timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 20)),
      isSentByMe: false,
      status: MessageStatus.read,
    ),

    // Later conversation about lunch
    ChatMessage(
      id: '14',
      content: 'Btw, you free for lunch today?',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      isSentByMe: false,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '15',
      content: 'There\'s this new Malaysian place downtown',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 14)),
      isSentByMe: false,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '16',
      content: 'They have nasi lemak and laksa!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 13)),
      isSentByMe: false,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '17',
      content: 'OMG YES! 🤤',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isSentByMe: true,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '18',
      content: 'I\'ve been craving nasi lemak for weeks',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 59)),
      isSentByMe: true,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '19',
      content: 'What time?',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 58)),
      isSentByMe: true,
      status: MessageStatus.read,
    ),

    // Making plans
    ChatMessage(
      id: '20',
      content: '12:30?',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      isSentByMe: false,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '21',
      content: 'I\'ll pick you up',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 44)),
      isSentByMe: false,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '22',
      content: 'Perfect! See you then 👍',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      isSentByMe: true,
      status: MessageStatus.read,
    ),

    // Recent messages with different statuses
    ChatMessage(
      id: '23',
      content: 'Oh btw',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isSentByMe: false,
      status: MessageStatus.delivered,
    ),
    ChatMessage(
      id: '24',
      content: 'Can you send me that Qt code for the sensor visualization?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
      isSentByMe: false,
      status: MessageStatus.delivered,
    ),
    ChatMessage(
      id: '25',
      content: 'I want to try implementing something similar',
      timestamp: DateTime.now().subtract(const Duration(minutes: 13)),
      isSentByMe: false,
      status: MessageStatus.delivered,
    ),
    ChatMessage(
      id: '26',
      content: 'Sure!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      isSentByMe: true,
      status: MessageStatus.delivered,
    ),
    ChatMessage(
      id: '27',
      content: 'I\'ll push it to GitHub after lunch',
      timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
      isSentByMe: true,
      status: MessageStatus.delivered,
    ),
    ChatMessage(
      id: '28',
      content: 'The repo is opensauce/NewQSensor',
      timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
      isSentByMe: true,
      status: MessageStatus.sent,
    ),
    ChatMessage(
      id: '29',
      content: 'Awesome! Thanks! 🙏',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      isSentByMe: false,
      status: MessageStatus.sent,
    ),
  ];

  static const String contactName = 'Alex Chen';
  static const String contactAvatar = '👨‍💻';
  static const String userAvatar = '🙋‍♂️';
}

// 主聊天页面
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = List.from(MockChatData.messages);

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: _messageController.text.trim(),
          timestamp: DateTime.now(),
          isSentByMe: true,
          status: MessageStatus.sending,
        ),
      );
    });

    _messageController.clear();

    // 滚动到底部
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF517DA2),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {},
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                MockChatData.contactAvatar,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MockChatData.contactName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
        message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isSentByMe) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  MockChatData.contactAvatar,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isSentByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: message.isSentByMe
                        ? const Color(0xFF2B5278)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(message.isSentByMe ? 18 : 4),
                      bottomRight: Radius.circular(message.isSentByMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: message.isSentByMe ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                    if (message.isSentByMe) ...[
                      const SizedBox(width: 4),
                      _buildMessageStatusIcon(message.status),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (message.isSentByMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageStatusIcon(MessageStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Colors.grey;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = const Color(0xFF4CAF50);
        break;
    }

    return Icon(
      icon,
      size: 14,
      color: color,
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey[600]),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.attach_file, color: Colors.grey[600]),
              onPressed: () {},
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF517DA2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes == 1) {
      return '${difference.inMinutes} minute ago';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours == 1) {
      return '${difference.inHours} hour ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

// 主函数
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFE5DDD5),
        fontFamily: 'PingFang SC',
      ),
      home: const ChatPage(),
    );
  }
}