import 'package:flutter/material.dart';

class ResetPasswordTitle extends StatelessWidget {
  const ResetPasswordTitle({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
          ),
          SizedBox(height: 20.0),
          Text(
           description,
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15.0),
          ),
        ],
      ),
    );
  }
}
