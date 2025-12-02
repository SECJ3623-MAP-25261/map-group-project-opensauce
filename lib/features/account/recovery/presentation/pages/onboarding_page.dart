import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTM On-Campus Borrowing',
      debugShowCheckedModeBanner: false,
      home: const OnCampusBorrowingPage(),
    );
  }
}

class OnCampusBorrowingPage extends StatelessWidget {
  const OnCampusBorrowingPage({super.key});

  // 主色和辅助色，根据图片做近似还原
  static const Color backgroundBlue = Color(0xFFBFD6E1); // 基础蓝（会被背景图片覆盖）
  static const Color teal = Color(0xFF156A72); // 文本和按钮的 teal 色
  static const Color lightTeal = Color(0xFF2A8A90);

  @override
  Widget build(BuildContext context) {
    // 通过屏幕宽度/高度自适应字体尺寸
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    // 基于宽度的缩放因子（可微调）
    double scale(double s) => s * (w / 390.0);

    return Scaffold(
      body: Stack(
        children: [
          // 背景图片 + 半透明遮罩
          Positioned.fill(
            child: Lottie.asset('assets/lotties/Welcome.json', fit: BoxFit.cover),
          ),

          // 统一蓝色半透明遮罩（让前景文字更清晰）
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.12), // 轻微提亮
            ),
          ),
          // 深蓝 tint（加强效果，可调）
          Positioned.fill(
            child: Container(color: const Color(0xFF8FB7C6).withOpacity(0.25)),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: scale(18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部状态模拟 + UTM 标志（用 Row + Stack 实现小UTM和大UTM重叠）
                  SizedBox(height: scale(6)),
                  SizedBox(
                    height: scale(72),
                    child: Stack(
                      children: [
                        // 小灰色 UTM（左上）
                        Positioned(
                          left: 0,
                          top: scale(6),
                          child: Text(
                            'UTM',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: scale(22),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // 大白色 UTM（偏中偏上）
                        Positioned(
                          left: scale(46),
                          top: 0,
                          child: Text(
                            'UTM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: scale(56),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 中间上方宣传句（多行）
                  SizedBox(height: scale(6)),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: w * 0.9),
                    child: Text(
                      'Let the rental\nmake your life\nconvenient.',
                      style: TextStyle(
                        color: teal.withOpacity(0.95),
                        fontSize: scale(26),
                        height: 1.02,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // 用 Expanded 将大标题推到屏幕中间偏下位置
                  Expanded(
                    child: Center(
                      child: Text(
                        'On-Campus\nBorrowing',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: scale(48),
                          fontWeight: FontWeight.w800,
                          height: 0.98,
                        ),
                      ),
                    ),
                  ),

                  // 底部按钮区（放在 SafeArea 内）
                  Column(
                    children: [
                      // Create an account - Outline style
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: 跳转注册页
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: teal, width: 2),
                            padding: EdgeInsets.symmetric(vertical: scale(16)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.03),
                          ),
                          child: Text(
                            'Create an account',
                            style: TextStyle(
                              color: teal,
                              fontSize: scale(18),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: scale(14)),

                      // Existing user - Filled style
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: 跳转登录页
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: teal,
                            padding: EdgeInsets.symmetric(vertical: scale(16)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Existing user',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: scale(18),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: scale(18)),

                      // T&C 文本
                      Text(
                        'T&C Apply*',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: scale(12),
                        ),
                      ),

                      SizedBox(
                        height:
                            mq.padding.bottom > 0
                                ? mq.padding.bottom
                                : scale(10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import '../auth/login_page.dart';
// import 'package:flutter/material.dart';

// // onboarding page (Jia Long)
// class OnboardingPage extends StatefulWidget {
//   const OnboardingPage({super.key});

//   @override
//   State<OnboardingPage> createState() => _OnboardingPageState();
// }

// class _OnboardingPageState extends State<OnboardingPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(30.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Text("EasyRent",style: TextStyle(color: Colors.redAccent,fontSize: 50),),
//                 FilledButton(
//                   onPressed: () {
//                     Navigator.push(context,MaterialPageRoute(builder: (context) {
//                       return LoginPage();
//                     },) );
//                   },
//                   style: ButtonStyle(
//                     backgroundColor: WidgetStatePropertyAll(Colors.amber),
//                   ),
//                   child: Text("Get Started"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
