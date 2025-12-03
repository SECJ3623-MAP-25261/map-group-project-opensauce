import 'package:flutter/material.dart';

class StatusItemCard extends StatelessWidget {
  final String title;
  final String statusText;
  final String imageUrl;
  final VoidCallback onStopRent;

  const StatusItemCard({
    super.key,
    required this.title,
    required this.statusText,
    required this.imageUrl,
    required this.onStopRent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imageUrl, height: 80),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusText == "On Renting..." ? Colors.amber : Colors.grey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed: onStopRent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Stop Rent"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
