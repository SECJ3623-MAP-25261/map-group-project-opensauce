import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
class MapScreenRenterPage extends StatefulWidget {
  const MapScreenRenterPage({
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
  State<MapScreenRenterPage> createState() => _MapScreenRenterPageState();
}

class _MapScreenRenterPageState extends State<MapScreenRenterPage> {
  // ... (Your existing variables and methods: _mapController, initState, dispose, _getCurrentUserLocation) ...

  GoogleMapController? _mapController;
  LatLng? selectedLatLng;
  String selectedLocation = "";
  LatLng? _currentLocation;
  bool _isLoading = true;
  static const LatLng _initialDefaultPosition = LatLng(1.558433, 103.638367);
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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // (Include your _getCurrentUserLocation function here)

  Future<void> _getCurrentUserLocation() async {
    // --- Standard Geolocator logic starts here ---
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }
    // --- Standard Geolocator logic ends here ---

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final newLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentLocation = newLatLng;
      _isLoading = false;
    });

    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(newLatLng, 18));
    }
  }

  /// Reverse geocoding
  // Future<void> _getAddressFromLatLng(LatLng latLng) async {
  //   String newLocation = "";

  //   // Animate camera to the tapped location for better UX
  //   if (_mapController != null) {
  //     _mapController!.animateCamera(CameraUpdate.newLatLng(latLng));
  //   }

  //   try {
  //     final placemarks = await placemarkFromCoordinates(
  //       latLng.latitude,
  //       latLng.longitude,
  //     );

  //     if (placemarks.isNotEmpty) {
  //       final place = placemarks.first;

  //       // newLocation =
  //       //     "${place.name}, ${place.street}, ${place.locality}, "
  //       //     "${place.postalCode}, ${place.country}";
  //       newLocation =
  //       "${place.name}, ${place.locality}, ${place.country}\n"
  //       "Lat: ${latLng.latitude.toStringAsFixed(6)}, "
  //       "Lng: ${latLng.longitude.toStringAsFixed(6)}";
  //     } else {
  //       // FIX 1: If no placemark found, set a descriptive message
  //       newLocation =
  //           "Location selected: Lat: ${latLng.latitude.toStringAsFixed(4)}, Long: ${latLng.longitude.toStringAsFixed(4)} (Address not found)";
  //     }
  //   } catch (e) {
  //     // FIX 2: If an error occurs (e.g., network), set an error message
  //     debugPrint("Geocoding error: $e");
  //     newLocation = "Error retrieving address. Please try again.";
  //   }

  //   setState(() {
  //     selectedLatLng = latLng; // Update LatLng regardless of address success
  //     selectedLocation = newLocation;
  //   });
  // }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
  // Move camera
  _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));

  // TODO: Replace with your actual API Key from Google Cloud Console
  final String googleApiKey = ''; // API KEY HERE
  
  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$googleApiKey'
  );

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        // results[0] is the most specific address (Building/Street level)
        final String formattedAddress = data['results'][0]['formatted_address'];
        
        setState(() {
          selectedLatLng = latLng;
          selectedLocation = formattedAddress;
        });
      } else {
        setState(() {
          selectedLatLng = latLng;
          selectedLocation = "Address not found (${data['status']})";
        });
      }
    }
  } catch (e) {
    debugPrint("Error: $e");
    setState(() {
      selectedLocation = "Error connecting to Geocoding service.";
    });
  }
}

  /// Build markers (Green = current, Red = selected)
  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};

    // 1. Add the Current User Location Marker (Green)
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_user_location'),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          onTap: () => _getAddressFromLatLng(_currentLocation!),
        ),
      );
    }

    // 2. Add the Selected Location Marker (Red)
    // This logic ensures that if the user taps the map, a red marker appears
    if (selectedLatLng != null && selectedLatLng != _currentLocation) {
      markers.add(
        Marker(
          markerId: const MarkerId('selected_tap_location'),
          position: selectedLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () => _getAddressFromLatLng(selectedLatLng!),
        ),
      );
    }

    // 3. Logic: If the user selects their current location, we change its color to Red
    // to show it is the active selection.
    if (selectedLatLng == _currentLocation && _currentLocation != null) {
      // We update the existing current location marker to red
      markers.removeWhere((m) => m.markerId.value == 'current_user_location');
      markers.add(
        Marker(
          markerId: const MarkerId('current_user_location'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () => _getAddressFromLatLng(_currentLocation!),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    // ... (rest of the build method) ...
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
              // The controller is initialized here
              onMapCreated: (controller) {
                _mapController = controller;
                // Optional: If _currentLocation is ready, move camera immediately after map is created
                if (_currentLocation != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(_currentLocation!, 18),
                  );
                }
              },
              // The initial position is now only for the very first render
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
          // ... (rest of the widgets) ...
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
                    selectedLocation.isNotEmpty &&
                        selectedLatLng != null &&
                        !selectedLocation.contains("Error")
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
                      selectedLocation.isNotEmpty &&
                          !selectedLocation.contains("Error")
                      ? Colors.red
                      : Colors.grey.shade400,
                  foregroundColor:
                      selectedLocation.isNotEmpty &&
                          !selectedLocation.contains("Error")
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
