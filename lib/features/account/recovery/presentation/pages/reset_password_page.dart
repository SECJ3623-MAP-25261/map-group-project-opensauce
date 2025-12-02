import 'package:easyrent/features/account/auth/login_page.dart';
import 'package:easyrent/features/account/recovery/presentation/widgets/reset_password_title.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordNewController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  String newPassword = '';
  String confirmPassword = '';
  @override
  void initState() {
    super.initState();
    _passwordNewController.addListener(() {
      newPassword = _passwordNewController.text;
    });
    _passwordConfirmController.addListener(() {
      confirmPassword = _passwordConfirmController.text;
    });
  }

  // Show the visibility of the password
  bool _obscureTextNew = true;
  bool _obscureTextConfirm = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ResetPasswordTitle(
              title: "Reset Password",
              description: "Please reset your password",
            ),
            Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _passwordNewController,
                      decoration: InputDecoration(
                        hintText: "New Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureTextNew =
                                  !_obscureTextNew; // toggle visibility of the text
                            });
                          },
                          icon: Icon(
                            _obscureTextNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        labelText: "New Password",
                      ),
                      obscureText: _obscureTextNew,
                      onEditingComplete: () {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        "Your password must be more than 6-digits",
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.0),
                TextField(
                  controller: _passwordConfirmController,
                  decoration: InputDecoration(
                    hintText: "Confirm New Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureTextConfirm =
                              !_obscureTextConfirm; // toggle visibility of the text
                        });
                      },
                      icon: Icon(
                        _obscureTextConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                    labelText: "Confirm New Password",
                  ),
                  obscureText: _obscureTextConfirm,
                  onEditingComplete: () {
                    setState(() {});
                  },
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                // Color become gold after user finish enter their email, or else it will become gray
                onPressed: () {
                  newPassword.isNotEmpty &&
                          confirmPassword.isNotEmpty &&
                          newPassword == confirmPassword
                      ? Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false, // removes all previous routes
                      )
                      : null;
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    newPassword.isNotEmpty &&
                            confirmPassword.isNotEmpty &&
                            newPassword == confirmPassword
                        ? const Color(0xFFF8BE17)
                        : Colors.grey,
                  ),
                  // fixedSize: WidgetStatePropertyAll(Size(double.infinity, 10)),
                  textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 20.0)),
                  padding: WidgetStatePropertyAll(
                    const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
