import 'package:flutter/material.dart';

class RenterStatusPage extends StatefulWidget {
  const RenterStatusPage({super.key});

  @override
  State<RenterStatusPage> createState() => _RenterStatusPageState();
}

class _RenterStatusPageState extends State<RenterStatusPage> {
  String statusText = "On Renting..."; // Initial status

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("assets/headphone.jpg", height: 80),

                const SizedBox(height: 10),

                const Text(
                  "TMA-2HD Wireless",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                // Status row: badge + Stop Rent button
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusText == "On Renting..."
                            ? const Color(0xFFFFD700) // Gold
                            : Colors.grey,             // Grey when stopped
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Stop Rent button
                    ElevatedButton(
                      onPressed: () => _showPauseConfirmation(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                      child: const Text("Stop Rent"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  // ===========================
  // CONFIRMATION DIALOG
  // ===========================
  void _showPauseConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Confirm to stop rent?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 12, right: 12),
        actions: [
          // YES BUTTON
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                statusText = "Stop Rent..."; // Update status and color
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Yes"),
          ),

          const SizedBox(width: 10),

          // NO BUTTON
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: const Text("No"),
          ),
        ],
      ),
    );
  }
}
