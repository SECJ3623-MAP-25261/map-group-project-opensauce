import 'package:easyrent/account/auth/login_page.dart';
import 'package:easyrent/account/recovery/verification_page.dart';
import 'package:easyrent/views/widgets/resetPassword/reset_password_title.dart';
import 'package:flutter/material.dart';

// reset password page (Lee Hom)
class EmailConfirmPage extends StatefulWidget {
  const EmailConfirmPage({super.key});

  @override
  State<EmailConfirmPage> createState() => _EmailConfirmPageState();
}

class _EmailConfirmPageState extends State<EmailConfirmPage> {
  final TextEditingController _emailController = TextEditingController();
  bool completeEmail = false;

  @override
  void dispose() {
    // Dispose controllers to free resources
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Listen for text changes
    _emailController.addListener(() {
      final text = _emailController.text;
      final isValid = _isValidEmail(text);
      if (isValid == true) {
        setState(() {
          completeEmail = true;
        });
      }
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: SizedBox(
          height: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Wrap up Reset Password Please enter the email that you register with. We will send you a 6-digit code
              SizedBox(
                width: double.infinity,
                child: ResetPasswordTitle(title: "Reset Password", description: "Please enter the email that you register with. We will send you a 6-digit code"),
              ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  labelText: "Email",
                ),
                obscureText: false,
                onChanged: (value) {
                  setState(() {
                    if (_isValidEmail(_emailController.text)) {
                      completeEmail = true;
                    } else {
                      completeEmail = false;
                    }
                  });
                },
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      // Color become gold after user finish enter their email, or else it will become gray
                      
                      onPressed: () {
                          completeEmail == true ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return VerificationPage();
                              },
                            ),
                          ) : null ;
                     
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          completeEmail == true
                              ? const Color(0xFFF8BE17)
                              : Colors.grey,
                        ),

                        // fixedSize: WidgetStatePropertyAll(Size(double.infinity, 10)),
                        textStyle: WidgetStatePropertyAll(
                          TextStyle(fontSize: 20.0),
                        ),
                        padding: WidgetStatePropertyAll(
                          const EdgeInsets.symmetric(vertical: 15.0),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      child: const Text("Confirm"),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return LoginPage();
                          },
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Back to Login Page",
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black54,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
