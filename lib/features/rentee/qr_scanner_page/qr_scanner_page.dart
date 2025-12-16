import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easyrent/core/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _isScanning = true;
  bool _isLoading = false;
  String _scanResult = '';
  String _verificationStatus = '';
  Timer? _scanTimer;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _startSimulatedScan();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }

  void _startSimulatedScan() {
    _scanTimer = Timer(const Duration(seconds: 2), () {
      if (_isScanning) {
        // Simulate scanning a QR code with order ID
        _onQRCodeScanned('9almQnkq');
      }
    });
  }

  Future<void> _onQRCodeScanned(String result) async {
    print('QR Scanned: "$result"'); // Debug
    setState(() {
      _isScanning = false;
      _scanResult = result;
      _isLoading = true;
      _verificationStatus = 'Processing...';
    });

    try {
      // Extract order ID from QR result
      String orderId = _extractOrderId(result);
      print('Extracted Order ID: "$orderId"'); // Debug

      if (orderId.isEmpty) {
        throw Exception('Invalid QR code format');
      }

      // Update order status in database
      bool success = await _updateOrderStatus(orderId);

      setState(() {
        _isLoading = false;
        if (success) {
          _verificationStatus = 'Verified';
          _showVerificationResult(orderId, true);
        } else {
          _verificationStatus = 'Failed';
          _showVerificationResult(orderId, false);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _verificationStatus = 'Error';
      });
      _showErrorDialog(e.toString());
    }
  }

  String _extractOrderId(String qrData) {
    print('Raw QR Data for extraction: "$qrData"'); // Debug

    // Remove any whitespace
    qrData = qrData.trim();

    // Handle multiple formats that could come from ReturnVerificationDialog
    // 1. Format: "ORDER-{orderId}"
    if (qrData.toUpperCase().contains('ORDER-')) {
      // Extract everything after "ORDER-"
      int index = qrData.toUpperCase().indexOf('ORDER-');
      String afterPrefix = qrData.substring(
        index + 6,
      ); // "ORDER-" is 6 characters

      // Take only alphanumeric characters (remove any extra text)
      RegExp alphanumeric = RegExp(r'[a-zA-Z0-9]+');
      Match? match = alphanumeric.firstMatch(afterPrefix);

      if (match != null) {
        return match.group(0)!;
      }
    }

    // 2. Format: "ABCD-EFGH" (formatted display from dialog)
    if (qrData.contains('-') && qrData.length <= 9) {
      return qrData.replaceAll('-', '').toLowerCase();
    }

    // 3. Format: Just the raw order ID (e.g., "2ftHjTli")
    // Remove any non-alphanumeric characters
    String cleanId = qrData.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    return cleanId.toLowerCase();
  }

  Future<bool> _updateOrderStatus(String orderId) async {
    try {
      // Reference to the order document
      final orderRef = _firestore.collection('orders').doc(orderId);

      // First, check if order exists and is in 'renting' status
      final orderDoc = await orderRef.get();

      if (!orderDoc.exists) {
        throw Exception('Order not found: $orderId');
      }

      final orderData = orderDoc.data();
      final currentStatus = orderData?['status'];

      if (currentStatus != 'renting') {
        throw Exception(
          'Order is not in renting status. Current status: $currentStatus',
        );
      }

      // Update status to 'history' and add return timestamp
      await orderRef.update({
        'status': 'history',
        'returnVerifiedAt': FieldValue.serverTimestamp(),
        'returnVerifiedBy': 'renter', // You can replace with actual user ID
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Also update the item status if it's stored separately
      if (orderData?['items'] != null && orderData?['items']['id'] != null) {
        final itemId = orderData!['items']['id'];
        await _firestore.collection('product').doc(itemId).update({
          'status': 'available',
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  void _showVerificationResult(String orderId, bool success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title:
                success
                    ? const Text('Verification Successful')
                    : const Text('Verification Failed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: ${_truncateString(orderId, maxLength: 12)}'),
                const SizedBox(height: 8),
                Text(
                  success
                      ? 'Item return has been verified successfully.\nOrder status updated to "history".'
                      : 'Failed to verify return. Please try again.',
                ),
                const SizedBox(height: 16),
                _buildVerificationDetails(success, orderId),
              ],
            ),
            actions: [
              if (!success)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    _resetScanner();
                  },
                  child: const Text('TRY AGAIN'),
                ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  if (success) {
                    Navigator.pop(context); // Go back to previous page
                  }
                },
                child: Text(success ? 'DONE' : 'CANCEL'),
              ),
            ],
          ),
    );
  }

  Widget _buildVerificationDetails(bool success, String orderId) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: success ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: success ? Colors.green[100]! : Colors.red[100]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                success ? 'Return Verified' : 'Verification Failed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: success ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            success
                ? '• Status: Updated to "history"'
                : '• Status: Update failed',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            '• Order: ${_truncateString(orderId, maxLength: 8)}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            '• Time: ${_truncateString(DateTime.now().toString(), maxLength: 16)}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Scan Error'),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetScanner();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _scanResult = '';
      _isLoading = false;
      _verificationStatus = '';
    });
    _startSimulatedScan();
  }

  Future<void> _manualVerifyOrder(String orderId) async {
    setState(() {
      _isLoading = true;
      _verificationStatus = 'Processing...';
    });

    try {
      bool success = await _updateOrderStatus(orderId);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        _showVerificationResult(orderId, true);
      } else {
        _showVerificationResult(orderId, false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  void _showManualEntryDialog() {
    TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Enter Order ID'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Order ID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.confirmation_number),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter the Order ID displayed\non the rentee\'s verification screen.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (codeController.text.isNotEmpty) {
                    Navigator.pop(context);
                    _manualVerifyOrder(codeController.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                ),
                child: const Text(
                  'VERIFY RETURN',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Verify Item Return', style: KTextStyle.appBarTitle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Instructions
            Text(
              'Scan Return Code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan the QR code from rentee\'s device\nto verify item return',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),

            // Status indicator
            if (_verificationStatus.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(_verificationStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _verificationStatus.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(_verificationStatus),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (_verificationStatus.isNotEmpty) const SizedBox(height: 20),

            // Scanner UI
            Expanded(child: Center(child: _buildScannerUI())),

            // Manual Entry Option
            const SizedBox(height: 40),
            TextButton.icon(
              onPressed: _isLoading ? null : _showManualEntryDialog,
              icon: const Icon(Icons.keyboard),
              label: const Text('Enter Order ID manually'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'processing...':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      case 'error':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildScannerUI() {
    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Updating order status...',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        ],
      );
    }

    if (!_isScanning && _scanResult.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _verificationStatus == 'Verified'
                ? Icons.check_circle
                : Icons.error,
            size: 80,
            color:
                _verificationStatus == 'Verified' ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 20),
          Text(
            _verificationStatus,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:
                  _verificationStatus == 'Verified' ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Order: ${_truncateString(_scanResult, maxLength: 8)}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      );
    }

    // Scanner View
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryRed, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Scanner corners
          _buildScannerCorner(top: 0, left: 0),
          _buildScannerCorner(top: 0, right: 0),
          _buildScannerCorner(bottom: 0, left: 0),
          _buildScannerCorner(bottom: 0, right: 0),

          // Scanning animation
          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            top: _isScanning ? 0 : 300,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primaryRed,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Center guide
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  _isScanning
                      ? const Icon(
                        Icons.qr_code_scanner,
                        size: 60,
                        color: Colors.white,
                      )
                      : null,
            ),
          ),

          // Instruction text
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Text(
              _isScanning ? 'Align QR code within frame' : 'Scan complete',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.primaryRed, width: 4),
            left: BorderSide(color: AppColors.primaryRed, width: 4),
            right:
                top != null || bottom != null
                    ? BorderSide(color: AppColors.primaryRed, width: 4)
                    : BorderSide.none,
            bottom:
                left != null || right != null
                    ? BorderSide(color: AppColors.primaryRed, width: 4)
                    : BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Helper method to safely truncate strings
  String _truncateString(String text, {int maxLength = 8}) {
    if (text.isEmpty) return text;
    if (maxLength <= 0) return '';

    try {
      if (text.length <= maxLength) return text;
      return '${text.substring(0, maxLength)}...';
    } catch (e) {
      print('Error in _truncateString: $e');
      // Fallback: return first 8 characters or less
      int safeLength = text.length < maxLength ? text.length : maxLength;
      return text.substring(0, safeLength);
    }
  }
}
