import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SumarryRowWidget extends StatefulWidget {
  const SumarryRowWidget({super.key, required this.amount, required this.title, this.valueColor});
  final String title;
  final String amount;
  final Color? valueColor;
  @override
  State<SumarryRowWidget> createState() => _SumarryRowWidgetState();
}

class _SumarryRowWidgetState extends State<SumarryRowWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            widget.amount,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: widget.valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}