import 'package:flutter/material.dart';

class StatusItemCard extends StatelessWidget {
  final String title;
  final String statusText;
  final String imageUrl;
  final VoidCallback onStopRent;
  final VoidCallback onShowQR;

  const StatusItemCard({
    super.key,
    required this.title,
    required this.statusText,
    required this.imageUrl,
    required this.onStopRent,
    required this.onShowQR,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  : Image.asset(
                      imageUrl,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
            ),

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

                // SHOW QR BUTTON (GOLD)
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