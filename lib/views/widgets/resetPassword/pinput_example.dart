import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart'; // Import the package

class PinputExample extends StatelessWidget {
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 60,
    textStyle: TextStyle(fontSize: 22, color: Color.fromRGBO(30, 60, 87, 1)),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: 4, // Set the number of input fields
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyDecorationWith(
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ), // Highlight the focused box
      ),
      submittedPinTheme: defaultPinTheme.copyWith(
        decoration: defaultPinTheme.decoration?.copyWith(
          color: Colors.grey.shade100,
        ),
      ),
      // Optional: Add an onSubmit callback to handle the final code
      onCompleted: (pin) => print('Verification Code: $pin'),
      // Use the following to show the keyboard on load
      autofocus: true,
      showCursor: true,
    );
  }
}
