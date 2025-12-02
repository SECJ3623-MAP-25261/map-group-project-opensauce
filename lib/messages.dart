import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 定义自定义 Tab Bar 的颜色和高度
const Color kActiveColor = Color(0xFF5D1049); // 深紫色
const Color kInactiveColor = Color(0xFF9E9E9E); // 灰色
const double kNavBarHeight = 80.0;
const int kMessagesTabIndex = 3; // MESSAGES 选项卡索引

void main() {
  runApp(const MessagesApp());
}

class MessagesApp extends StatelessWidget {
  const MessagesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.activeOrange,
        scaffoldBackgroundColor: CupertinoColors.white,
      ),
      home: MessagingListScreen(), // 直接从消息列表页开始
    );
  }
}

// ----------------------------------------------------
// 1. 自定义底部导航栏 (CustomBottomNavBar)
// ----------------------------------------------------
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNavBar({
    required this.currentIndex,
    this.onTap,
    super.key,
  });

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = index == currentIndex;
    return Expanded(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => onTap?.call(index), // 调用传入的点击事件
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? kActiveColor : kInactiveColor,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? kActiveColor : kInactiveColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kNavBarHeight,
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'HOME', 0),
          _buildNavItem(Icons.list_alt, 'LISTING', 1),
          _buildNavItem(Icons.qr_code_scanner, 'SCAN', 2),
          _buildNavItem(Icons.chat_bubble_outline, 'MESSAGES', 3),
          _buildNavItem(Icons.person_outline, 'ACCOUNT', 4),
        ],
      ),
    );
  }
}


// ----------------------------------------------------
// 2. 消息列表页 (MessagingListScreen)
// ----------------------------------------------------
class MessagingListScreen extends StatelessWidget {
  const MessagingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        border: null,
        middle: Text(
          'Messaging',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: ListView.separated(
                itemCount: 15,
                padding: EdgeInsets.zero,
                separatorBuilder: (context, index) => const Divider(
                  indent: 90,
                  endIndent: 20,
                  height: 0.5,
                  color: Color(0xFFE0E0E0),
                ),
                itemBuilder: (context, index) {
                  return _buildMessageListItem(context);
                },
              ),
            ),
            // 消息列表页底部导航栏默认为 MESSAGES 选中
            const CustomBottomNavBar(currentIndex: kMessagesTabIndex, onTap: null),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: CupertinoTextField(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        placeholder: 'Search',
        placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefix: const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Icon(
            CupertinoIcons.search,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageListItem(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        // 跳转到聊天详情页
        Navigator.of(context).push(
            CupertinoPageRoute(builder: (context) => const ChatDetailScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: CupertinoColors.systemGrey,
              backgroundImage: NetworkImage('https://via.placeholder.com/150/0000FF/808080?Text=JD'),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JOHN DOE',
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'LOREM IPSUM DOLOR SIT AMET, CONSECTETUR ADIPISCING ELIT, MAECENAS VEL AUGUE A DUI DIGNISSIM FERMENTUM. ETIAM QUIS',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              '19/11',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// 3. 聊天详情页 (ChatDetailScreen)
// ----------------------------------------------------
class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          _buildCustomHeader(context),
          Expanded(child: _buildChatBody()),
          _buildInputArea(),
          // 聊天详情页底部导航栏默认为 MESSAGES 选中
          CustomBottomNavBar(currentIndex: kMessagesTabIndex, onTap: (index) {
            // 如果点击了 Tab Bar 上的其他 Tab，需要先回到列表页，再处理 Tab 切换
            Navigator.of(context).pop();
            // TODO: 如果需要切换 Tab，在此处处理 MainAppShell 的状态切换
          }), 
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 16),
        color: const Color(0xFFFFC300),
        child: Row(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.all(4),
              onPressed: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back, color: CupertinoColors.black, size: 28),
            ),
            const CircleAvatar(
              radius: 18,
              backgroundColor: CupertinoColors.systemGrey,
              backgroundImage: NetworkImage('https://via.placeholder.com/150/FF8800/FFFFFF?Text=JD'),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JOHN DOE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: CupertinoColors.black),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 8, height: 8,
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                          color: CupertinoColors.systemGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('ONLINE', style: TextStyle(fontSize: 12, color: CupertinoColors.black)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBody() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text('JOHN DOE', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),

        // Incoming Bubble (Left)
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(15),
            ),
            constraints: const BoxConstraints(maxWidth: 250),
            child: const Text('Placeholder: Incoming Message'),
          ),
        ),
        const SizedBox(height: 20),

        // Outgoing Bubble 1 (Customer - Right)
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Costumer', style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGreen,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text('Placeholder', style: TextStyle(color: CupertinoColors.white)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Outgoing Bubble 2 (Customer - Right)
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Costumer', style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGreen,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text('Placeholder', style: TextStyle(color: CupertinoColors.white)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 视频/图库菜单
          Container(
            width: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              children: [
                _MenuItem(text: 'VIDEO'),
                Divider(height: 1, color: CupertinoColors.systemGrey4),
                _MenuItem(text: 'GALLERY'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 输入框和 + 按钮
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kActiveColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(CupertinoIcons.add, color: CupertinoColors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: const Center(
                    child: Text(''),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 辅助函数：菜单项
class _MenuItem extends StatelessWidget {
  final String text;
  const _MenuItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, color: CupertinoColors.black),
        ),
      ),
    );
  }
}
  