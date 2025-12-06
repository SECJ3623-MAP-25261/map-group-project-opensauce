import 'package:flutter/material.dart';


class AvailabilityItemCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onAvailable;
  final VoidCallback onHold;


  const AvailabilityItemCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onAvailable,
    required this.onHold,
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
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAvailable,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Available"),
                  ),
                ),


                const SizedBox(width: 10),


                Expanded(
                  child: ElevatedButton(
                    onPressed: onHold,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("On Hold"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
