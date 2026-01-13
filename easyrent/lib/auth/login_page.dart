import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'forgot_password_page.dart';
import '../common/main_navigation_page.dart'; // Ensure this matches your file structure

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // --- EMAIL AUTH SUBMISSION ---
  Future<void> _submitAuthForm() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Please fill in email and password");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // --- LOG IN ---
        await _authService.loginWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        // --- SIGN UP ---
        if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
          throw FirebaseAuthException(
            code: 'missing-fields',
            message: 'Please fill in Name and Phone.',
          );
        }

        await _authService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: 'rentee',
        );
      }

      // --- NAVIGATION: Email Success ---
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationPage()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Authentication failed");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- GOOGLE AUTH HANDLER (FIXED) ---
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      // 1. Capture the result
      final userCredential = await _authService.signInWithGoogle();

      // 2. Check if successful (user didn't cancel)
      if (userCredential != null && mounted) {
        // 3. NAVIGATION: Google Success (Added this!)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationPage()),
          (route) => false,
        );
      }
    } catch (e) {
      _showError("Google Sign-In failed: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin ? "EasyRent Login" : "Create Account",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // --- SIGN UP EXTRA FIELDS ---
              if (!_isLogin) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // --- COMMON FIELDS ---
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                onChanged: (val) => setState(() {}),
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: _passwordController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                ),
              ),

              // --- FORGOT PASSWORD ---
              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text("Forgot Password?"),
                  ),
                ),

              const SizedBox(height: 24),

              // --- ACTION BUTTON ---
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitAuthForm,
                        child: Text(_isLogin ? "Login" : "Sign Up"),
                      ),
                    ),

              // --- TOGGLE MODE ---
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _emailController.clear();
                    _passwordController.clear();
                    _nameController.clear();
                    _phoneController.clear();
                  });
                },
                child: Text(
                  _isLogin ? "No account? Sign Up" : "Have an account? Login",
                ),
              ),

              const Divider(height: 40),

              // --- GOOGLE BUTTON ---
              OutlinedButton.icon(
                onPressed: _handleGoogleLogin,
                icon: const Icon(Icons.g_mobiledata, size: 30),
                label: const Text("Continue with Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
