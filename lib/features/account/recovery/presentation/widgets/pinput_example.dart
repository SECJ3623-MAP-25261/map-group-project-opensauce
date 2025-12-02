import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PinputExample extends StatelessWidget {
  final TextEditingController _codeController;
  final void Function(String)? onCodeCompleted;

  PinputExample({super.key, required TextEditingController codeController,this.onCodeCompleted})
      : _codeController = codeController;
  
  // Default PinTheme
  final defaultPinTheme = PinTheme(
    width: 70,
    height: 66,
    textStyle: TextStyle(fontSize: 22, color: Color.fromRGBO(30, 60, 87, 1)),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align label to start
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 21),
          child: Text(
            "Verification Code",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Pinput(
            controller: _codeController,
            length: 4,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyWith(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue, width: 2),
              ),
            ),
            submittedPinTheme: defaultPinTheme.copyWith(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            onChanged: (pin) {
              onCodeCompleted!(pin);
            },
            onCompleted: (pin) {
              if(onCodeCompleted != null) {
                print("Complete code ");
                onCodeCompleted!(pin);
              }
            },
            autofocus: true,
            showCursor: true,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                "Resend Code",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
