import 'package:flutter/material.dart';

void main() => runApp(const ChatApp());

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: const Color(0xFFFFC107)),
      home: const MessageScreen(),
    );
  }
}

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  bool _showPlusMenu = false; // 控制左下角 "+" 菜单的显示

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('JOHN DOE', style: TextStyle(color: Colors.black87, fontSize: 16)),
                    const Text('Placeholder', style: TextStyle(color: Colors.grey, fontSize: 20)),
                    const SizedBox(height: 30),
                    _buildMessageBubble("Placeholder", hasMenu: false),
                    const SizedBox(height: 20),
                    _buildMessageBubble("Placeholder", hasMenu: true), // 带弹出菜单的消息
                  ],
                ),
              ),
              _buildBottomInputSection(),
              _buildBottomNavBar(),
            ],
          ),
          // 左下角弹出的 Video/Gallery 菜单
          if (_showPlusMenu) _buildMediaPopup(),
        ],
      ),
    );
  }

  // 1. 顶部导航栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFFC107),
      leading: const Icon(Icons.arrow_back, color: Colors.black),
      title: Row(
        children: [
          const CircleAvatar(radius: 16, backgroundColor: Colors.blueGrey),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('JOHN DOE', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('ONLINE', style: TextStyle(color: Colors.black54, fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
      elevation: 0,
    );
  }

  // 2. 消息气泡（含长按弹出效果模拟）
  Widget _buildMessageBubble(String text, {bool hasMenu = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 8, bottom: 4),
          child: Text('Costumer', style: TextStyle(fontSize: 12, color: Colors.black54)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF68B454),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
        if (hasMenu) ...[
          const SizedBox(height: 4),
          // 模拟图片中的操作菜单
          Container(
            width: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Column(
              children: ['REPLY', 'COPY', 'SELECT', 'DELETE'].map((action) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade400))),
                  child: Text(action, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
          ),
        ]
      ],
    );
  }

  // 3. 左下角媒体弹出框
  Widget _buildMediaPopup() {
    return Positioned(
      bottom: 120, // 位于输入框上方
      left: 10,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Column(
          children: ['VIDEO', 'GALLERY', '', ''].map((label) {
            return Container(
              height: 35,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 25),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade400))),
              child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 4. 输入框区域
  Widget _buildBottomInputSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showPlusMenu = !_showPlusMenu),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
              child: const Icon(Icons.add, size: 30),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // 5. 底部导航栏
  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavIcon(Icons.home_outlined, "HOME"),
          _NavIcon(Icons.inventory_2_outlined, "LISTING"),
          _NavIcon(Icons.qr_code_scanner, "SCAN"),
          _NavIcon(Icons.chat_bubble_outline, "MESSAGES", isActive: true),
          _NavIcon(Icons.person_outline, "ACCOUNT"),
        ],
      ),
    );
  }
}

// 导航图标小组件
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  const _NavIcon(this.icon, this.label, {this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? Colors.brown : Colors.black54, size: 28),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? Colors.brown : Colors.black54, fontWeight: FontWeight.bold)),
      ],
    );
  }
}