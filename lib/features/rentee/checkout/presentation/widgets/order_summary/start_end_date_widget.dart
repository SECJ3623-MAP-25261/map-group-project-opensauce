import 'package:flutter/material.dart';

class StartEndDateWidget extends StatefulWidget {
  const StartEndDateWidget({super.key});

  @override
  State<StartEndDateWidget> createState() => _StartEndDateWidgetState();
}

class _StartEndDateWidgetState extends State<StartEndDateWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Start Renting Date",style: TextStyle(color: Colors.black),),
              Text("12/12/2025")
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("End Renting Date"),
              Text("14/12/2025 (2 Days)")
            ],
          )
        ],
      ),
    );
  }
}