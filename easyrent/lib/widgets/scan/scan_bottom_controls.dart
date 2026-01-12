import 'package:flutter/material.dart';

class ScanBottomControls extends StatelessWidget {
  final bool isTorchOn;
  final VoidCallback onToggleTorch;
  final VoidCallback onPickImage;

  const ScanBottomControls({
    super.key,
    required this.isTorchOn,
    required this.onToggleTorch,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Align QR Code within frame",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: isTorchOn ? Icons.flashlight_on : Icons.flashlight_off,
                label: "Flash",
                onTap: onToggleTorch,
              ),
              const SizedBox(width: 60),
              _buildActionButton(
                icon: Icons.image_outlined,
                label: "Gallery",
                onTap: onPickImage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
