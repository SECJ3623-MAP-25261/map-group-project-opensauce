import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Uses LatLng
import 'package:geocoding/geocoding.dart';

class MapScreenPage extends StatefulWidget {
  const MapScreenPage({
    required this.itemsLocation,
    required this.onConfirm,
    super.key,
  });

  final List<dynamic> itemsLocation;
  final Function(String address, double lat, double lng) onConfirm;

  @override
  State<MapScreenPage> createState() => _MapScreenPageState();
}

class _MapScreenPageState extends State<MapScreenPage> {
  GoogleMapController? _mapController;
  
  // These MUST be LatLng for Google Maps compatibility
  LatLng? selectedLatLng;
  LatLng? _currentLocation;
  
  String location = "";
  bool _isLoadingLocation = true;
  
  static const LatLng _defaultInitialPosition = LatLng(1.558433, 103.638367);
  late List<LatLng> suggestedPlaces;

  @override
  void initState() {
    super.initState();
    // Convert your custom objects to Google Maps LatLng immediately
    suggestedPlaces = widget.itemsLocation.map((loc) {
      return LatLng(loc.latitude, loc.longitude);
    }).toList();

    _getCurrentUserLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // Changed parameter to LatLng
  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          selectedLatLng = latLng;
          location = "${place.name}, ${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
        });
      }
    } catch (e) {
      setState(() {
        selectedLatLng = latLng;
        location = "Lat: ${latLng.latitude.toStringAsFixed(4)}, Long: ${latLng.longitude.toStringAsFixed(4)}";
      });
    }
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = suggestedPlaces.map((latLng) {
      final isSelected = selectedLatLng == latLng;
      return Marker(
        markerId: MarkerId(latLng.toString()),
        position: latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure,
        ),
        onTap: () => _getAddressFromLatLng(latLng),
      );
    }).toSet();

    if (selectedLatLng != null && !suggestedPlaces.contains(selectedLatLng)) {
      markers.add(
        Marker(
          markerId: const MarkerId('selected_tap_location'),
          position: selectedLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    return markers;
  }

  Future<void> _getCurrentUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng newLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = newLatLng;
        _isLoadingLocation = false;
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newLatLng, 18));
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine target using LatLng
    LatLng initialTarget = _currentLocation ?? 
        (suggestedPlaces.isNotEmpty ? suggestedPlaces.first : _defaultInitialPosition);

    return Scaffold(
      appBar: AppBar(title: const Text("Select Location")),
      body: Column(
        children: [
          SizedBox(
            height: 500,
            width: double.infinity,
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(target: initialTarget, zoom: 15),
              markers: _buildMarkers(),
              onTap: (latLng) => _getAddressFromLatLng(latLng),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(location.isEmpty ? "Tap map to select" : location),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: (selectedLatLng != null)
                    ? () {
                        widget.onConfirm(location, selectedLatLng!.latitude, selectedLatLng!.longitude);
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text("Confirm"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}