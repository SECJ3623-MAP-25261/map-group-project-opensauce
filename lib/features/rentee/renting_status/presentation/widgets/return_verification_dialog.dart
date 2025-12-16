import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReturnVerificationDialog extends StatelessWidget {
  final String orderId;
  final String itemName;
  final String itemCode;

  const ReturnVerificationDialog({
    super.key,
    required this.orderId,
    required this.itemName,
    required this.itemCode,
  });

  @override
  Widget build(BuildContext context) {
    // Clean the order ID to ensure consistency
    final cleanOrderId = orderId.trim();
    final formattedDisplay = _formatOrderIdForDisplay(cleanOrderId);
    final shortOrderId = _safeSubstring(cleanOrderId, 0, 8);
    final shortCode = _safeSubstring(cleanOrderId.toUpperCase(), 0, 12);
    final qrText = "ORDER-$cleanOrderId";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Return Verification',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Instruction
              Text(
                'Show this code to the rentee\nto complete the order.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),

              // Code Display (QR-like visual)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
                child: Column(
                  children: [
                    // QR-like visual
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Column(
                        children: [
                          _buildQRCodeVisual(qrText),
                          const SizedBox(height: 16),
                          Text(
                            'ORDER VERIFICATION CODE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Scan-ready text code
                    _buildScanReadyCode(qrText, formattedDisplay),
                    const SizedBox(height: 16),

                    // Item details
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_bag,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Item: $itemName',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.code,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Code: $shortCode',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.confirmation_number,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Order ID: $shortOrderId',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Scanner Instructions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 20, color: Colors.blue[700]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Point scanner at the QR code or text above',
                        style: TextStyle(fontSize: 13, color: Colors.blue[800]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Problem with Order link
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening problem reporting...'),
                    ),
                  );
                },
                child: Text(
                  'Problem with Order?',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Copy to clipboard - copy the exact format scanner expects
                        Clipboard.setData(ClipboardData(text: qrText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code copied to clipboard'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Copy Code',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRCodeVisual(String qrText) {
    return Column(
      children: [
        // QR-like pattern
        Container(
          width: 100,
          height: 100,
          color: Colors.white,
          child: CustomPaint(painter: _QRCodePainter(qrText)),
        ),
        const SizedBox(height: 8),
        // Display the scannable text
        Text(
          qrText,
          style: const TextStyle(
            fontSize: 10,
            fontFamily: 'Monospace',
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildScanReadyCode(String qrText, String formattedDisplay) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Scan this text if QR fails:',
            style: TextStyle(fontSize: 10, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            formattedDisplay,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
              fontFamily: 'Monospace',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            "SCAN: $qrText",
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400],
              fontFamily: 'Monospace',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatOrderIdForDisplay(String id) {
    if (id.isEmpty) return id;

    // Clean the ID - keep only alphanumeric characters
    final cleanId = id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();

    if (cleanId.length <= 8) {
      // If 8 or fewer characters, show as-is
      return cleanId;
    }

    try {
      // Show first 8 characters in 4-4 format
      return '${cleanId.substring(0, 4)}-${cleanId.substring(4, 8)}';
    } catch (e) {
      return cleanId;
    }
  }

  // Safe substring method to prevent RangeError
  String _safeSubstring(String text, int start, int end) {
    if (text.isEmpty || start < 0) return '';
    if (start >= text.length) return text;
    if (end > text.length) return text.substring(start);
    if (start >= end) return '';
    return text.substring(start, end);
  }
}

// Simple QR code painter for visual representation
class _QRCodePainter extends CustomPainter {
  final String data;

  _QRCodePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

    final hash = data.hashCode.abs();
    final cellSize = size.width / 8;

    // Draw QR-like pattern
    for (int y = 0; y < 8; y++) {
      for (int x = 0; x < 8; x++) {
        bool shouldFill = (hash >> (x + y * 8)) & 1 == 1;
        if (shouldFill) {
          canvas.drawRect(
            Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }

    // Draw position markers (like real QR codes)
    _drawPositionMarker(canvas, 0, 0, cellSize);
    _drawPositionMarker(canvas, 6, 0, cellSize);
    _drawPositionMarker(canvas, 0, 6, cellSize);
  }

  void _drawPositionMarker(Canvas canvas, int x, int y, double cellSize) {
    final outerPaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

    final innerPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    // Outer square
    canvas.drawRect(
      Rect.fromLTWH(x * cellSize, y * cellSize, 7 * cellSize, 7 * cellSize),
      outerPaint,
    );

    // Middle white square
    canvas.drawRect(
      Rect.fromLTWH(
        (x + 1) * cellSize,
        (y + 1) * cellSize,
        5 * cellSize,
        5 * cellSize,
      ),
      innerPaint,
    );

    // Inner black square
    canvas.drawRect(
      Rect.fromLTWH(
        (x + 2) * cellSize,
        (y + 2) * cellSize,
        3 * cellSize,
        3 * cellSize,
      ),
      outerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
