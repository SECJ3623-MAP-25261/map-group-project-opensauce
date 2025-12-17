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
    suggestedPlaces =
        widget.itemsLocation.map((location) {
          return LatLng(location.latitude, location.longitude);
        }).toList();
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
          location =
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
    return suggestedPlaces.map((latLng) {
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
  }

  // --- 3. NEW METHOD TO FETCH USER LOCATION ---
  Future<void> _getCurrentUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Services are disabled, use default position
      setState(() {
        _isLoadingLocation = false;
      });
      return;
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Permissions denied, use default position
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }
    }

    // Get the current position
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
    } catch (e) {
      debugPrint("Error fetching location: $e");
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng initialTarget = _currentLocation ?? _defaultInitialPosition;
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
                target: initialTarget,
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
                    location.isNotEmpty && selectedLatLng != null
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
                      location.isNotEmpty
                          ? AppColors.primaryRed
                          : Colors.grey.shade400,
                  foregroundColor:
                      location.isNotEmpty ? Colors.white : Colors.grey.shade700,
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
