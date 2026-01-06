import 'package:flutter/material.dart';

class StatusItemCard extends StatelessWidget {
  final String title;
  final String statusText;
  final String imageUrl;
  final VoidCallback onStopRent;
  final VoidCallback? onShowQR;

  const StatusItemCard({
    super.key,
    required this.title,
    required this.statusText,
    required this.imageUrl,
    required this.onStopRent,
    this.onShowQR,
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
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.startsWith('http')
                  ? Image.network(imageUrl, height: 80, width: 80, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(height: 80, width: 80, color: Colors.grey[300], child: const Icon(Icons.broken_image)))
                  : Image.asset(imageUrl, height: 80, width: 80, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(height: 80, width: 80, color: Colors.grey[300], child: const Icon(Icons.image))),
            ),
            
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Row(
              children: [
                // STATUS BADGE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusText == "On Renting..." ? const Color(0xFFFFD700) : Colors.grey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),

                const Spacer(),

                // SHOW QR BUTTON (Only show if onShowQR is NOT null)
                if (onShowQR != null) ...[
                  ElevatedButton(
                    onPressed: onShowQR,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8BE17), // Gold
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text("Show QR"),
                  ),
                  const SizedBox(width: 8),
                ],

                // STOP RENT BUTTON
                ElevatedButton(
                  onPressed: onStopRent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
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