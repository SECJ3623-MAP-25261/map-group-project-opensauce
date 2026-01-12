import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/rentee_service.dart';
import '../../widgets/scan/qr_scanner_overlay_shape.dart';
import '../../widgets/scan/scan_bottom_controls.dart';

class RenteeScanReturnPage extends StatefulWidget {
  final bool isActive;

  const RenteeScanReturnPage({super.key, required this.isActive});

  @override
  State<RenteeScanReturnPage> createState() => _RenteeScanReturnPageState();
}

class _RenteeScanReturnPageState extends State<RenteeScanReturnPage>
    with WidgetsBindingObserver {
  // Logic: Camera Controller
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
    autoStart: false,
  );

  final RenteeService _service = RenteeService();
  final ImagePicker _picker = ImagePicker();

  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isActive) _cameraController.start();
  }

  @override
  void didUpdateWidget(RenteeScanReturnPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Logic: Seamless switching
    if (widget.isActive != oldWidget.isActive) {
      widget.isActive ? _cameraController.start() : _cameraController.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isActive) return;
    if (state == AppLifecycleState.inactive) {
      _cameraController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _cameraController.start();
    }
  }

  void _toggleTorch() {
    _cameraController.toggleTorch();
    setState(() => _isTorchOn = !_isTorchOn);
  }

  // Logic: Handle Scanned Code
  void _processCode(String? code) async {
    if (_isProcessing || code == null) return;
    setState(() => _isProcessing = true);

    try {
      await _cameraController.stop();

      if (!mounted) return;
      _showLoading(true);

      await _service.verifyReturnHandshake(code);

      if (!mounted) return;
      _showLoading(false);
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      _showLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );

      _cameraController.start();
      setState(() => _isProcessing = false);
    }
  }

  // Logic: Pick Image
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final BarcodeCapture? capture = await _cameraController.analyzeImage(
        image.path,
      );
      if (capture != null && capture.barcodes.isNotEmpty) {
        _processCode(capture.barcodes.first.rawValue);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No QR code found in image.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // UI Helpers
  void _showLoading(bool show) {
    if (show) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Item returned successfully!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cameraController.start();
              setState(() => _isProcessing = false);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Layer 1: Camera
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              if (capture.barcodes.isNotEmpty) {
                _processCode(capture.barcodes.first.rawValue);
              }
            },
          ),

          // Layer 2: Overlay Shape (Visual Layer)
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: const Color(0xFF800000),
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),

          // Layer 3: Controls (Widget Layer)
          ScanBottomControls(
            isTorchOn: _isTorchOn,
            onToggleTorch: _toggleTorch,
            onPickImage: _pickImage,
          ),
        ],
      ),
    );
  }
}
