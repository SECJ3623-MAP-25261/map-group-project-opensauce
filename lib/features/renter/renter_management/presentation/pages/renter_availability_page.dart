import 'package:flutter/material.dart';
import '../widgets/availability_item_card.dart';

class RenterAvailabilityPage extends StatelessWidget {
  const RenterAvailabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AvailabilityItemCard(
          title: "TMA-2HD Wireless",
          imageUrl: "assets/headphone.jpg",
          onAvailable: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Available"),
                content: const Text("The item is now available."),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          },
          onHold: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("On Hold"),
                content: const Text("The item is now on hold."),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
