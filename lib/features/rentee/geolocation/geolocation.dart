import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Geolocation extends StatelessWidget {
  const Geolocation({required this.latitude, required this.longitude, super.key});
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    // Initial camera position centered on the retrieved coordinates
    final CameraPosition initialPosition = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 14,
    );
    
    // Create a marker at the target location
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(latitude, longitude),
      ),
    };

    return SizedBox( // Constrain the map widget's size
      height: 360, 
      width: double.infinity,
      child: GoogleMap(
        initialCameraPosition: initialPosition,
        markers: markers,
        mapType: MapType.normal,
        zoomControlsEnabled: false,
        
      ),
    );
  }
}