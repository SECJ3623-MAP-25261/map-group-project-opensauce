import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/features/models/item.dart';
import 'package:easyrent/features/rentee/checkout/data/provider/checkout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class Geolocation extends ConsumerStatefulWidget {
  const Geolocation({required this.itemsLocation, super.key});

  final List<locationObject> itemsLocation;

  @override
  ConsumerState<Geolocation> createState() => _GeolocationState();
}

class _GeolocationState extends ConsumerState<Geolocation> {
  // 1. Declare the map controller
  GoogleMapController? _mapController;
  
  LatLng? selectedLatLng;
  String location = "";
  LatLng? _currentLocation;
  bool _isLoadingLocation = true; 
  static const LatLng _defaultInitialPosition = LatLng(1.558433,
    103.638367,);

  /// Suggested places shown when map opens
  late final List<LatLng> suggestedPlaces;

  @override
  void initState() {
    super.initState();
    // Initialize suggested places from the widget argument
    suggestedPlaces = widget.itemsLocation.map((location) {
      return LatLng(location.latitude, location.longitude);
    }).toList();
    
    // 3. Fetch user location to set the map's initial center
    _getCurrentUserLocation();
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// Reverse geocoding
  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    String newLocation = "";
    
    // FIX 4: Animate camera to the tapped location
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(latLng),
      );
    }
    
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        newLocation =
            "${place.name}, ${place.street}, ${place.locality}, "
            "${place.postalCode}, ${place.country}";
            print("----------- the new location is from _getAddressFromLatLng $newLocation ------------");
      } else {
        // Handle case where address cannot be resolved
        newLocation = "Location selected: Lat: ${latLng.latitude.toStringAsFixed(4)}, Long: ${latLng.longitude.toStringAsFixed(4)} (Address not found)";
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
      newLocation = "Error retrieving address. Please try again.";
    }
    
    // Always call setState to update the selected marker color and the text box
    setState(() {
      selectedLatLng = latLng;
      location = newLocation;
      print("----------- the new location is $location ------------");
    });
  }

  /// Build markers (blue = suggested, red = selected)
  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = suggestedPlaces.map((latLng) {
      final isSelected = selectedLatLng == latLng;

      return Marker(
        markerId: MarkerId(latLng.toString()),
        position: latLng,
        icon:
            isSelected
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
                : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
        onTap: () => _getAddressFromLatLng(latLng),
      );
    }).toSet();
    
    // Add a temporary marker for map taps if it's not a suggested location
    if (selectedLatLng != null && !suggestedPlaces.contains(selectedLatLng)) {
      markers.add(
        Marker(
          markerId: const MarkerId('selected_tap_location'),
          position: selectedLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () => _getAddressFromLatLng(selectedLatLng!),
        ),
      );
    }
    
    return markers;
  }

  // --- 3. METHOD TO FETCH USER LOCATION ---
  Future<void> _getCurrentUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoadingLocation = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = newLatLng;
        _isLoadingLocation = false;
      });
      
      // FIX 5: Move camera to current location if the map controller is ready
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(newLatLng, 18),
        );
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the target: prioritize current location, then the first suggested place, then default
    LatLng initialTarget;
    if (_currentLocation != null) {
      initialTarget = _currentLocation!;
    } else if (suggestedPlaces.isNotEmpty) {
      initialTarget = suggestedPlaces.first;
    } else {
      initialTarget = _defaultInitialPosition;
    }

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
              // 2. Capture the controller when the map is created
              onMapCreated: (controller) {
                _mapController = controller;
                // If location was fetched before map creation, move camera now
                if (_currentLocation != null) {
                   controller.animateCamera(
                     CameraUpdate.newLatLngZoom(_currentLocation!, 18),
                   );
                }
              },
              initialCameraPosition: CameraPosition(
                target: initialTarget,
                zoom: 18,
              ),
              mapType: MapType.normal,
              zoomControlsEnabled: true,
              markers: _buildMarkers(),
              // This is the user tap handler
              onTap: (latLng) => _getAddressFromLatLng(latLng), 
            ),
          ),

          const SizedBox(height: 20),

          /// ADDRESS DISPLAY
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              location.isEmpty
                  ? "Tap a marker or map to select a location"
                  : location,
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
                    location.isNotEmpty && selectedLatLng != null && !location.contains("Error")
                        ? () {
                            ref
                                .read(checkoutProvider.notifier)
                                .setLocation(location);
                            ref
                                .read(checkoutProvider.notifier)
                                .setLatLng(
                                  selectedLatLng!.latitude,
                                  selectedLatLng!.longitude,
                                );
                            Navigator.pop(context);
                          }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      location.isNotEmpty && !location.contains("Error")
                          ? AppColors.primaryRed // Assuming AppColors is defined
                          : Colors.grey.shade400,
                  foregroundColor:
                      location.isNotEmpty && !location.contains("Error") ? Colors.white : Colors.grey.shade700,
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