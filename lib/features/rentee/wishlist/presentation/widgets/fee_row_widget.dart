import 'package:flutter/material.dart';

class FeeRowWidget extends StatefulWidget {
  const FeeRowWidget({super.key,required this.title, required this.amount});
  final String title ;
  final double amount ;
  @override
  State<FeeRowWidget> createState() => _FeeRowWidgetState();
}

class _FeeRowWidgetState extends State<FeeRowWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
          Text(
            'RM ${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}