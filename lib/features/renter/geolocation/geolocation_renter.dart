import 'package:easyrent/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class GeolocationRenter extends StatefulWidget {
  const GeolocationRenter({
    required this.latitude,
    required this.longitude,
    // required this.location,
    // required this.locationLat,
    // required this.locationLong,
    required this.onLocationSelected,
    super.key,
  });

  final void Function(String location, double lat, double long)
  onLocationSelected;
  final double latitude;
  final double longitude;
  // final String location;
  // final double locationLat;
  // final double locationLong;

  @override
  State<GeolocationRenter> createState() => _GeolocationRenterState();
}

class _GeolocationRenterState extends State<GeolocationRenter> {
  LatLng? selectedLatLng;
  String selectedLocation = "";

  LatLng? _currentLocation;
  bool _isLoading = true;

  static const LatLng _initialDefaultPosition = LatLng(
    1.558433,
    103.638367,
  ); // Kuala Lumpur, for example

  /// Suggested places shown when map opens
  final List<LatLng> suggestedPlaces = [
    LatLng(1.488889, 103.761111),
    LatLng(1.488889, 103.891111),
    LatLng(1.488889, 103.991111),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentUserLocation();
  }

  Future<void> _getCurrentUserLocation() async {
    // --- Standard Geolocator logic starts here ---
    // 1. Check permissions and service status (required by geolocator)
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions denied
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions permanently denied
      return;
    }
    // --- Standard Geolocator logic ends here ---

    // 2. Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 3. Update the state with the new position
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
  }

  /// Reverse geocoding
  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        setState(() {
          selectedLatLng = latLng;
          selectedLocation =
              "${place.name}, ${place.street}, ${place.locality}, "
              "${place.postalCode}, ${place.country}";
        });
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }
  }

  /// Build markers (blue = suggested, red = selected)
  Set<Marker> _buildMarkers() {

    final Set<Marker> markers =
        suggestedPlaces.map((latLng) {

          final isSelected = selectedLatLng == latLng;

          return Marker(
            markerId: MarkerId(
              'suggested_${latLng.toString()}',
            ), // Unique ID for suggested
            position: latLng,
            icon:
                isSelected
                    ? BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    )
                    : BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
            onTap: () => _getAddressFromLatLng(latLng),
          );
        }).toSet();
    print("------- is current location null? ${_currentLocation == null} the current Location is ${_currentLocation?.latitude} ${_currentLocation?.longitude}-------");
    // 2. Add the Current User Location Marker (if available)
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_user_location'), // Unique ID
          position: _currentLocation!, // Use the non-null value
          infoWindow: const InfoWindow(
            title: 'Your Location',
          ), // Optional title
          // Use a different color (e.g., green or a custom icon) to distinguish it
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          // We usually don't set an onTap for the user's current location marker
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Select Location"),
      ),
      body: Column(
        children: [
          /// MAP
          SizedBox(
            height: 620,
            width: double.infinity,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation ?? _initialDefaultPosition,
                zoom: 18,
              ),
              mapType: MapType.normal,
              zoomControlsEnabled: true,
              markers: _buildMarkers(),
              onTap: (latLng) => _getAddressFromLatLng(latLng),
            ),
          ),

          const SizedBox(height: 20),

          /// ADDRESS DISPLAY
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              selectedLocation.isEmpty
                  ? "Tap a marker or map to select a location"
                  : selectedLocation,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          const Spacer(),

          /// CONFIRM BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    selectedLocation.isNotEmpty && selectedLatLng != null
                        ? () {
                          widget.onLocationSelected(
                            selectedLocation,
                            selectedLatLng!.latitude,
                            selectedLatLng!.longitude,
                          );
                          Navigator.pop(context);
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedLocation.isNotEmpty
                          ? AppColors.primaryRed
                          : Colors.grey.shade400,
                  foregroundColor:
                      selectedLocation.isNotEmpty
                          ? Colors.white
                          : Colors.grey.shade700,
                ),
                child: const Text("Confirm"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
