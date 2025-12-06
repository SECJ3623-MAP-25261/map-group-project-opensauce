import 'package:easyrent/features/rentee/geolocation/geolocation.dart';
import 'package:flutter/material.dart';

class DeliveryPlaceWidget extends StatefulWidget {
  const DeliveryPlaceWidget({super.key});

  @override
  State<DeliveryPlaceWidget> createState() => _DeliveryPlaceWidgetState();
}

class _DeliveryPlaceWidgetState extends State<DeliveryPlaceWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                "Choose a location:",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline), // Changed to outline for better visual cue
                onPressed: () {
                  // Use ScaffoldMessenger to show a SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        "Choose a location for the meeting or delivery places",
                        style: TextStyle(color: Colors.white),
                      ),
                      duration: const Duration(seconds: 3), // How long the message is visible
                      backgroundColor: Colors.black87,
                      behavior: SnackBarBehavior.floating, // Makes it look cleaner
                    ),
                  );
                },
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Geolocation(
                      latitude: 1.488889,
                      longitude: 103.761111,
                    );
                  },
                ),
              );
            },
            child: Text("Location"),
          ),
        ],
      ),
    );
  }
}
