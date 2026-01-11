import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.amber),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 1. 顶部状态栏与导航
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBC02D), // 接近图片的黄色
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'), // 替换为真实头像
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('JOHN DOE', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text('ONLINE', style: TextStyle(color: Colors.black54, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 2. 聊天消息列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('JOHN DOE', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const Text('Placeholder', style: TextStyle(fontSize: 18, color: Colors.black54)),
                const SizedBox(height: 20),
                
                // 右侧绿色气泡
                _buildChatBubble(message: "Placeholder", isMe: true, icon: Icons.thumb_up),
                const SizedBox(height: 10),
                _buildChatBubble(message: "Placeholder", isMe: true, icon: Icons.sentiment_satisfied_alt),
              ],
            ),
          ),
          
          // 3. 底部输入框
          _buildInputSection(),
          
          // 4. 底部导航栏
          _buildBottomNav(),
        ],
      ),
    );
  }

  // 构建聊天气泡组件
  Widget _buildChatBubble({required String message, required bool isMe, required IconData icon}) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        const Text('Costumer', style: TextStyle(fontSize: 12, color: Colors.grey)), // 注意：图中拼写是Costumer
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF7CB342), // 绿色气泡
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
        Icon(icon, size: 40, color: Colors.black), // 图片中的点赞和笑脸图标
      ],
    );
  }

  // 构建输入框
  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.add, size: 30, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建底部导航栏
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[300]!))),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'LISTING'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'SCAN'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'MESSAGES'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'ACCOUNT'),
        ],
      ),
    );
  }
}
