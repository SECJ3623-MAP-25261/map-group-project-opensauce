import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // <--- IMPORT SCANNER

class RenterQRScannerPage extends StatefulWidget {
  const RenterQRScannerPage({super.key});

  @override
  State<RenterQRScannerPage> createState() => _RenterQRScannerPageState();
}

class _RenterQRScannerPageState extends State<RenterQRScannerPage> {
  bool _isScanned = false; // Prevent multiple scans

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Return Code")),
      body: MobileScanner(
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
      ),
    );
  }

  void _handleScanResult(String code) {
    // Here you would process the code (e.g., "RETURN:ITEM_001")
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Text("Success!\nScanned Code: $code\n\nItem return confirmed."),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close scanner
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}