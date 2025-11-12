import 'package:easyrent/account/recovery/reset_password_page.dart';
import 'package:easyrent/views/widgets/resetPassword/pinput_example.dart';
import 'package:easyrent/views/widgets/resetPassword/reset_password_title.dart';
import 'package:flutter/material.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController _verificationController = TextEditingController();
  String _enteredCode = '';
  bool _isComplete = false;

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
              title: "Verification",
              description:
                  "We have sent the 4-digit verification code to abcd@gmail.com",
            ),
            PinputExample(
              codeController: _verificationController,
              onCodeCompleted: (code) {
                setState(() {
                  print("Verfication Code is ${code}");
                  _enteredCode=code;
                  _isComplete = true;
                });
              },
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                // Color become gold after user finish enter their email, or else it will become gray
                onPressed: () {
                  _isComplete == true && _enteredCode.length == 4 ?
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ResetPasswordPage();
                      },
                    ),
                  ) : null;
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    _isComplete == true && _enteredCode.length == 4 ? const Color(0xFFF8BE17) : Colors.grey,
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
