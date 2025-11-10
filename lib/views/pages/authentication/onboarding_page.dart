import 'package:easyrent/views/pages/authentication/auth/login_page.dart';
import 'package:flutter/material.dart';

// onboarding page (Jia Long)
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("EasyRent",style: TextStyle(color: Colors.redAccent,fontSize: 50),),
                FilledButton(
                  onPressed: () {
                    Navigator.push(context,MaterialPageRoute(builder: (context) {
                      return LoginPage();
                    },) );
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.amber),
                  ),
                  child: Text("Get Started"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
