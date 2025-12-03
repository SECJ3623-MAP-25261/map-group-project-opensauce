import 'dart:async'; // 引入异步库用于延时
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // 仅用于部分颜色和辅助
import 'package:flutter/services.dart'; // 用于控制状态栏

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. 初始化时设置沉浸式状态栏（透明背景，适合启动页的深色背景）
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark, // iOS: 文字变白
    statusBarIconBrightness: Brightness.light, // Android: 图标变白
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
      ),
      home: SplashScreen(), // 入口指向启动页
    );
  }
}

// ==========================================
// 第一部分：Splash Screen (启动页 - 还原你的图片)
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    // 延迟 3 秒
    await Future.delayed(const Duration(seconds: 3));

    // 安全检查：页面是否还在
    if (!mounted) return;

    // 跳转到登录页，并销毁当前页 (pushReplacement)
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 确保在启动页显示时，状态栏是白字的
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final size = MediaQuery.of(context).size;

    return CupertinoPageScaffold(
      // 禁用 resizeToAvoidBottomInset 防止键盘顶起背景（虽然这页没输入框）
      resizeToAvoidBottomInset: false,
      child: Container(
        width: size.width,
        height: size.height,
        // 紫色渐变背景
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E72CA), // 顶部蓝
              Color(0xFF8A3FFC), // 底部紫
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'UTM',
              style: TextStyle(
                fontFamily: 'Didot', // iOS 经典衬线体
                fontFamilyFallback: const ['Times', 'serif'],
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 0),
            Text(
              'EASYRENT',
              style: TextStyle(
                fontFamily: 'Didot',
                fontFamilyFallback: const ['Times', 'serif'],
                fontSize: 56,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                letterSpacing: -1.5, // 紧凑设计
                height: 1.0,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 40),
            // 白色加载菊花
            const CupertinoActivityIndicator(color: Colors.white, radius: 10),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 第二部分：Login Page (登录页 - iOS 风格)
// ==========================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 页面初始化稍微延迟一点点再切回黑色状态栏，保证过渡自然
    Future.delayed(const Duration(milliseconds: 100), () {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    });
  }

  void _handleLogin() async {
    // 收起键盘
    FocusScope.of(context).unfocus();
    
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
       _showErrorDialog("请输入账号和密码");
       return;
    }

    setState(() { _isLoading = true; });

    // 模拟网络请求 1.5秒
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    
    setState(() { _isLoading = false; });

    // 登录成功弹窗
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("欢迎"),
        content: const Text("登录成功！进入首页..."),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("确定"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("提示"),
        content: Text(message),
        actions: [
           CupertinoDialogAction(child: const Text("好的"), onPressed: () => Navigator.pop(context))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 确保 build 时也是深色字体（防止热重载重置）
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("登录"),
        // 去掉返回按钮，因为这是主入口
        automaticallyImplyLeading: false, 
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              
              // 顶部图标
              const Center(
                child: Icon(
                  CupertinoIcons.person_crop_circle,
                  size: 80,
                  color: CupertinoColors.systemGrey3,
                ),
              ),
              
              const SizedBox(height: 50),

              // 邮箱输入框
              CupertinoTextField(
                controller: _emailController,
                placeholder: "用户名 / 邮箱",
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGroupedBackground, // iOS 典型的输入框浅灰底色
                  borderRadius: BorderRadius.circular(10),
                ),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(CupertinoIcons.mail, color: CupertinoColors.systemGrey),
                ),
              ),
              
              const SizedBox(height: 16),

              // 密码输入框
              CupertinoTextField(
                controller: _passwordController,
                placeholder: "密码",
                obscureText: true,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGroupedBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(CupertinoIcons.lock, color: CupertinoColors.systemGrey),
                ),
              ),

              const SizedBox(height: 32),

              // 登录按钮
              SizedBox(
                height: 50,
                child: _isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : CupertinoButton.filled(
                        borderRadius: BorderRadius.circular(10),
                        onPressed: _handleLogin,
                        child: const Text("登 录", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
              ),
              
              const Spacer(),
              
              // 底部文字
              Center(
                child: CupertinoButton(
                  child: const Text("注册新账号", style: TextStyle(color: CupertinoColors.activeBlue)),
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}