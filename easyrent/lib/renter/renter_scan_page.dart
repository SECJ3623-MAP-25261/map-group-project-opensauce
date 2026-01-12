import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

// --- LAYERS ---
import '../../services/renter_service.dart';
import '../../widgets/scan/qr_scanner_overlay_shape.dart';
import '../../widgets/scan/scan_bottom_controls.dart';
import '../../widgets/scan/camera_loading_widget.dart'; // New
import '../../utils/scan_dialog_helper.dart'; // New

class RenterScanPickupPage extends StatefulWidget {
  final bool isActive;

  const RenterScanPickupPage({super.key, required this.isActive});

  @override
  State<RenterScanPickupPage> createState() => _RenterScanPickupPageState();
}

class _RenterScanPickupPageState extends State<RenterScanPickupPage>
    with WidgetsBindingObserver {
  // --- CONTROLLERS ---
  final MobileScannerController _cameraController = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
    autoStart: false,
    torchEnabled: false,
  );

  final RenterService _service = RenterService();
  final ImagePicker _picker = ImagePicker();

  // --- STATE ---
  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _isCameraInitialized = false;

  // --- LIFECYCLE LOGIC ---
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isActive) _startCamera();
  }

  @override
  void didUpdateWidget(RenterScanPickupPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Warm Start Logic
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startCamera();
      } else {
        _cameraController.stop();
      }
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
    if (!_cameraController.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cameraController.stop();
    } else if (state == AppLifecycleState.resumed && widget.isActive) {
      _startCamera();
    }
  }

  Future<void> _startCamera() async {
    if (!_cameraController.value.isRunning) {
      try {
        await _cameraController.start();
        if (mounted) setState(() => _isCameraInitialized = true);
      } catch (e) {
        debugPrint("Camera Error: $e");
      }
    }
  }

  // --- BUSINESS LOGIC ---
  Future<void> _processCode(String? code) async {
    if (_isProcessing || code == null) return;
    setState(() => _isProcessing = true);

    try {
      await _service.verifyPickupHandshake(code);
      if (!mounted) return;
      ScanDialogHelper.showSuccess(context, () {
        // On OK, we stay on the page or handle specific navigation logic
        // Since it's a tab view, simply closing the dialog is enough
      });
    } catch (e) {
      if (!mounted) return;
      ScanDialogHelper.showError(
        context,
        e.toString().replaceAll("Exception: ", ""),
        () {
          setState(() => _isProcessing = false);
        },
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isProcessing = true);
      final capture = await _cameraController.analyzeImage(image.path);

      if (capture != null && capture.barcodes.isNotEmpty) {
        _processCode(capture.barcodes.first.rawValue);
      } else {
        if (!mounted) return;
        ScanDialogHelper.showError(context, "No QR code found", () {
          setState(() => _isProcessing = false);
        });
      }
    } catch (e) {
      ScanDialogHelper.showError(context, "Failed to pick image", () {
        setState(() => _isProcessing = false);
      });
    }
  }

  void _toggleTorch() {
    _cameraController.toggleTorch();
    setState(() => _isTorchOn = !_isTorchOn);
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    // 1. Inactive State (Save Resources)
    if (!widget.isActive) return const Scaffold(backgroundColor: Colors.black);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Layer 1: Camera Feed
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              if (capture.barcodes.isNotEmpty) {
                _processCode(capture.barcodes.first.rawValue);
              }
            },
          ),

          // Layer 2: Loading State (Warm-up)
          if (!_isCameraInitialized) const CameraLoadingWidget(),

          // Layer 3: Scanner Overlay (Only when ready)
          if (_isCameraInitialized)
            Container(
              decoration: const ShapeDecoration(
                shape: QrScannerOverlayShape(
                  borderColor: Color(0xFF800000),
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 300,
                ),
              ),
            ),

          // Layer 4: Controls
          if (_isCameraInitialized)
            ScanBottomControls(
              isTorchOn: _isTorchOn,
              onToggleTorch: _toggleTorch,
              onPickImage: _pickImageFromGallery,
            ),

          // Layer 5: Processing Overlay (During API Call)
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
