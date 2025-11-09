import 'package:flutter/material.dart';

// reset password page (Lee Hom)
class ResetpasswordPage extends StatefulWidget {
  const ResetpasswordPage({super.key});

  @override
  State<ResetpasswordPage> createState() => _ResetpasswordPageState();
}

class _ResetpasswordPageState extends State<ResetpasswordPage> {
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
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Reset Password",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30.0),),
                    SizedBox(height: 20.0,),
                    Text(
                      "Please enter the email that you register with. We will send you a 6-digit code",
                      style: TextStyle(fontWeight: FontWeight.w200),
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
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          const Color(0xFFF8BE17),
                        ),
                        // fixedSize: WidgetStatePropertyAll(Size(double.infinity, 10)),
                        textStyle: WidgetStatePropertyAll(
                          TextStyle(fontSize: 20.0),
                        ),
                        padding: WidgetStatePropertyAll(
                          const EdgeInsets.symmetric(
                            vertical: 15.0,
                          ),
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
                  SizedBox(height: 20.0,),
                  TextButton(onPressed: () {
                    // Navigator.pop()
                  }, child: const Text("Back to Login Page",style: TextStyle(fontSize: 15.0,color: Colors.black54,decoration: TextDecoration.underline),))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
