import 'package:easyrent/account/recovery/verification_page.dart';
import 'package:flutter/material.dart';

// reset password page (Lee Hom)
class EmailConfirmPage extends StatefulWidget {
  const EmailConfirmPage({super.key});

  @override
  State<EmailConfirmPage> createState() => _EmailConfirmPageState();
}

class _EmailConfirmPageState extends State<EmailConfirmPage> {
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
              // Wrap up
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reset Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      "Please enter the email that you register with. We will send you a 6-digit code",
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 15.0,
                      ),
                    ),
                  ],
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  labelText: "Email",
                ),
                obscureText: true,
                onEditingComplete: () {
                  setState(() {});
                },
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      // Color become gold after user finish enter their email, or else it will become gray
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return VerificationPage();
                            },
                          ),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          const Color(0xFFF8BE17),
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
                      // Navigator.pop()
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
