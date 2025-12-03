import 'package:flutter/material.dart';

class ApprovalItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String status;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ApprovalItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.status,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.transparent;
    String statusText = "";
    Color statusColor = Colors.black;

    if (status == "approved") {
      borderColor = Colors.green;
      statusText = "Approved";
      statusColor = Colors.green;
    } else if (status == "rejected") {
      borderColor = Colors.red;
      statusText = "Rejected";
      statusColor = Colors.red;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
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

            // STATUS LABEL
            if (status != "pending")
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // BUTTONS — SHOW ONLY IF PENDING
            if (status == "pending")
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Approve"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onReject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
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
