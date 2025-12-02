import 'package:flutter/material.dart';

class ApprovalItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ApprovalItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imageUrl, height: 80, fit: BoxFit.cover),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),
            Text(subtitle),

            const SizedBox(height: 10),

            Row(
              children: [
                // APPROVE BUTTON — GOLD
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700), // Gold
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Approve"),
                  ),
                ),

                const SizedBox(width: 10),

                // NOT APPROVE BUTTON — GREY
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // Grey
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Not Approve"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
