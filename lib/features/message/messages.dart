// messaging_ui.dart
// Single-file Flutter app demonstrating a mobile messaging UI.
// Paste into `lib/main.dart` of a new Flutter project and run.

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// void main() {
//   runApp(const MessagingApp());
// }

// class MessagingApp extends StatelessWidget {
//   const MessagingApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Messaging UI',
//       theme: ThemeData(
//         primarySwatch: Colors.indigo,
//         scaffoldBackgroundColor: Colors.grey[100],
//       ),
//       home: const ChatPage(),
//     );
//   }
// }

// class ChatPage extends StatefulWidget {
//   const ChatPage({Key? key}) : super(key: key);

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final List<Message> _messages = [
//     Message(text: 'Hey! Are you coming to the meeting later?', isMe: false, time: DateTime.now().subtract(const Duration(minutes: 18))),
//     Message(text: 'Yes — I\'ll be there around 3:15pm.', isMe: true, time: DateTime.now().subtract(const Duration(minutes: 17))),
//     Message(text: 'Great. Don\'t forget the presentation slides.', isMe: false, time: DateTime.now().subtract(const Duration(minutes: 16))),
//     Message(text: 'Already uploaded to the drive. 👍', isMe: true, time: DateTime.now().subtract(const Duration(minutes: 6))),
//     Message(text: 'Perfect, thanks!', isMe: false, time: DateTime.now().subtract(const Duration(minutes: 2))),
//   ];

//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   bool _isTyping = false;

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _sendMessage() {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;
//     final msg = Message(text: text, isMe: true, time: DateTime.now());
//     setState(() {
//       _messages.add(msg);
//       _controller.clear();
//       _isTyping = false;
//     });
//     _scrollToBottom();

//     // Simulate a quick reply for demo purposes
//     Future.delayed(const Duration(milliseconds: 600), () {
//       setState(() {
//         _isTyping = true;
//       });
//     });
//     Future.delayed(const Duration(milliseconds: 1400), () {
//       setState(() {
//         _isTyping = false;
//         _messages.add(Message(text: 'Nice! Got it.', isMe: false, time: DateTime.now()));
//       });
//       _scrollToBottom();
//     });
//   }

//   void _scrollToBottom() async {
//     await Future.delayed(const Duration(milliseconds: 50));
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent + 80,
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   Widget _buildMessageComposer() {
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         color: Colors.white,
//         child: Row(
//           children: [
//             IconButton(
//               onPressed: () {
//                 // Placeholder for attachments
//               },
//               icon: const Icon(Icons.attach_file),
//             ),
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _controller,
//                         textCapitalization: TextCapitalization.sentences,
//                         decoration: const InputDecoration(
//                           hintText: 'Type a message',
//                           border: InputBorder.none,
//                         ),
//                         minLines: 1,
//                         maxLines: 5,
//                         onChanged: (s) {
//                           setState(() {
//                             _isTyping = s.trim().isNotEmpty;
//                           });
//                         },
//                         onSubmitted: (_) => _sendMessage(),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () {
//                         // Insert emoji picker integration here if wanted
//                         final text = _controller.text;
//                         _controller.text = '$text🙂';
//                         _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
//                       },
//                       icon: const Icon(Icons.emoji_emotions_outlined),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             FloatingActionButton(
//               onPressed: _isTyping ? _sendMessage : null,
//               mini: true,
//               backgroundColor: _isTyping ? Theme.of(context).primaryColor : Colors.grey[300],
//               child: const Icon(Icons.send, color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0.5,
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.black87),
//         title: Row(
//           children: [
//             const CircleAvatar(child: Text('A')),
//             const SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text('Alex Morgan', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
//                 SizedBox(height: 2),
//                 Text('Online', style: TextStyle(color: Colors.green, fontSize: 12)),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(onPressed: () {}, icon: const Icon(Icons.call, color: Colors.black87)),
//           IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.black87)),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//               ),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: ListView.builder(
//                       controller: _scrollController,
//                       itemCount: _messages.length + (_isTyping ? 1 : 0),
//                       itemBuilder: (context, index) {
//                         if (_isTyping && index == _messages.length) {
//                           return const TypingIndicator();
//                         }
//                         final message = _messages[index];
//                         final showAvatar = !message.isMe;
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 6),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//                             children: [
//                               if (!message.isMe) ...[
//                                 if (showAvatar)
//                                   const Padding(
//                                     padding: EdgeInsets.only(right: 8.0),
//                                     child: CircleAvatar(radius: 18, child: Text('B')),
//                                   )
//                                 else
//                                   const SizedBox(width: 44),
//                               ],

//                               Flexible(
//                                 child: Column(
//                                   crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                                       decoration: BoxDecoration(
//                                         color: message.isMe ? Colors.indigo[400] : Colors.grey[200],
//                                         borderRadius: BorderRadius.only(
//                                           topLeft: const Radius.circular(14),
//                                           topRight: const Radius.circular(14),
//                                           bottomLeft: Radius.circular(message.isMe ? 14 : 2),
//                                           bottomRight: Radius.circular(message.isMe ? 2 : 14),
//                                         ),
//                                       ),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             message.text,
//                                             style: TextStyle(
//                                               color: message.isMe ? Colors.white : Colors.black87,
//                                               fontSize: 15,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 6),
//                                           Row(
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               Text(
//                                                 DateFormat('hh:mm a').format(message.time),
//                                                 style: TextStyle(
//                                                   color: (message.isMe ? Colors.white70 : Colors.black45),
//                                                   fontSize: 11,
//                                                 ),
//                                               ),
//                                               if (message.isMe) const SizedBox(width: 6),
//                                               if (message.isMe)
//                                                 Icon(
//                                                   message.status == MessageStatus.sent ? Icons.done : Icons.access_time,
//                                                   size: 14,
//                                                   color: message.isMe ? Colors.white70 : Colors.black45,
//                                                 ),
//                                             ],
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),

//                               if (message.isMe) const SizedBox(width: 44),

//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           _buildMessageComposer(),
//         ],
//       ),
//     );
//   }
// }

// class Message {
//   final String text;
//   final bool isMe;
//   final DateTime time;
//   final MessageStatus status;

//   Message({required this.text, required this.isMe, DateTime? time, this.status = MessageStatus.sent}) : time = time ?? DateTime.now();
// }

// enum MessageStatus { sending, sent, read }

// class TypingIndicator extends StatelessWidget {
//   const TypingIndicator({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(right: 8.0),
//           child: CircleAvatar(radius: 18, child: Text('B')),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: const [
//               Dot(),
//               SizedBox(width: 6),
//               Dot(delay: 120),
//               SizedBox(width: 6),
//               Dot(delay: 240),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class Dot extends StatefulWidget {
//   final int delay;
//   const Dot({Key? key, this.delay = 0}) : super(key: key);

//   @override
//   State<Dot> createState() => _DotState();
// }

// class _DotState extends State<Dot> with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;
//   late final Animation<double> _anim;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
//     _anim = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _ctrl,
//       builder: (_, __) {
//         final phase = ((_ctrl.lastElapsedDuration?.inMilliseconds ?? 0) + widget.delay) % 900;
//         final t = (phase / 900).clamp(0.0, 1.0);
//         final scale = 0.6 + 0.4 * (0.5 + 0.5 * (1 - (2 * (t - 0.5)).abs()));
//         return Opacity(
//           opacity: scale,
//           child: Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54)),
//         );
//       },
//     );
//   }
// }



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
  