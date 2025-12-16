import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/features/rentee/checkout/data/provider/checkout_provider.dart';
import 'package:easyrent/features/rentee/geolocation/geolocation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeliveryPlaceWidget extends ConsumerStatefulWidget {
  const DeliveryPlaceWidget({super.key});

  @override
  ConsumerState<DeliveryPlaceWidget> createState() => _DeliveryPlaceWidgetState();
}

class _DeliveryPlaceWidgetState extends ConsumerState<DeliveryPlaceWidget> {
  // Define a default/initial location for the Geolocation screen (e.g., Johor Bahru coordinates)
  // NOTE: Assuming this is a fallback for the initial "Location" button.
  final double defaultLat = 1.488889; 
  final double defaultLng = 103.761111;

  void _showInfoSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Choose a location for the meeting or delivery places",
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.blueGrey, // Slightly softer background
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToGeolocation(
      {required double latitude, required double longitude}) {
        print("longiture: ${longitude} latitude: ${latitude}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Geolocation(
            latitude: latitude,
            longitude: longitude,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the location from the provider
    final checkoutState = ref.watch(checkoutProvider);
    final isLocationSelected = checkoutState.location.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0), // Added Padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top for multi-line text
        children: [
          // --- Left Side: Title and Info Icon ---
          Row(
            mainAxisSize: MainAxisSize.min, // Keep the row compact
            children: [
              TextButton(onPressed: () {
                _navigateToGeolocation(
                  latitude: checkoutState.locationLat,
                  longitude: checkoutState.locationLong,
                );
              },
                child: Text("Choose a location:",  style: TextStyle(
                  fontSize: 16, // Slightly larger font
                  fontWeight: FontWeight.w600, // Make it semi-bold
                  color: Colors.black87,
                ),),
                // "Choose a location:",
              ),
              const SizedBox(width: 4), // Small spacing
              GestureDetector(
                onTap: _showInfoSnackBar,
                child: const Icon(
                  Icons.help_outline, // Changed to a more standard help icon
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          // --- Right Side: Location Status/Button ---
          Flexible(
            child: isLocationSelected
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Location Text Display
                      Text(
                        checkoutState.location,
                        textAlign: TextAlign.right,
                        softWrap: true,
                        maxLines: 2, // Limiting lines to keep it compact
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Change Location Button
                      SizedBox(
                        height: 32, // Controlled height for a cleaner look
                        child: TextButton(
                          onPressed: () => _navigateToGeolocation(
                            latitude: checkoutState.locationLat,
                            longitude: checkoutState.locationLong,
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryRed, // Use primary color for text button
                            padding: EdgeInsets.zero, // Remove default padding
                            minimumSize: Size.zero, // Remove minimum size constraints
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap area
                          ),
                          child: const Text(
                            "Change location",
                            style: TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.underline, // Add underline for link-like appearance
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : // 'Location' Button when no location is selected
                ElevatedButton.icon(
                    onPressed: () => _navigateToGeolocation(
                      latitude: defaultLat,
                      longitude: defaultLng,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // Use primary color
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Softer radius
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.location_on),
                    label: const Text(
                      "Select Location", // More descriptive text
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}