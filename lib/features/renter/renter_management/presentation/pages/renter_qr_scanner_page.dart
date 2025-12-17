import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class RenterQRScannerPage extends StatefulWidget {
  const RenterQRScannerPage({super.key});

  @override
  State<RenterQRScannerPage> createState() => _RenterQRScannerPageState();
}

class _RenterQRScannerPageState extends State<RenterQRScannerPage> {
  // Controller to handle camera and torch
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _isScanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleScanResult(String code) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.all(20),
        title: Column(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text("Scanned Successfully", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          "Code: $code\n\n(Logic to confirm return goes here)",
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              Navigator.pop(context); // Close Scanner Page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF8BE17), // Gold
              foregroundColor: Colors.black,
            ),
            child: const Text("Done"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scanSize = 280.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. THE CAMERA LAYER
          MobileScanner(
            controller: controller,
            scanWindow: Rect.fromCenter(
              center: MediaQuery.of(context).size.center(Offset.zero),
              width: scanSize,
              height: scanSize,
            ),
            onDetect: (capture) {
              if (_isScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() => _isScanned = true);
                  _handleScanResult(barcode.rawValue!);
                  break;
                }
              }
            },
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      "Camera Error: ${error.errorCode}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),

          // 2. THE VISUAL FRAME (Centered)
          Center(
            child: Container(
              width: scanSize,
              height: scanSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFF8BE17), // Gold Border
                  width: 3.0,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
          ),

          // 3. UI OVERLAYS (Close button, Text)
          SafeArea(
            child: Stack(
              children: [
                // CROSS BUTTON (Top Left)
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // TITLE (Top Center)
                const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Text(
                      "Scan Return QR",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ),
                ),

                // BOTTOM CONTROLS (Text & Flashlight)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Place QR code in the scan area",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                          ),
                        ),
                        
                        const SizedBox(height: 40),

                        if (!kIsWeb) 
                        ValueListenableBuilder(
                          valueListenable: controller,
                          builder: (context, state, child) {
                            final isTorchOn = state.torchState == TorchState.on;
                            
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () => controller.toggleTorch(),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                    child: Icon(
                                      isTorchOn ? Icons.flashlight_on : Icons.flashlight_off,
                                      color: isTorchOn ? const Color(0xFFF8BE17) : Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Flashlight",
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            );
                          },
                        ),

                        if (kIsWeb) ...[
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _handleScanResult("SIMULATED_RETURN_CODE_123"),
                            icon: const Icon(Icons.bug_report),
                            label: const Text("Simulate Scan (Debug)"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ]

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}