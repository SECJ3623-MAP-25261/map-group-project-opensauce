// rentee_qr_dialog.dart (unchanged - use the previous version)
import 'package:easyrent/features/models/item.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RenteeQRDialog extends StatelessWidget {
  final Item item;
  final int orderDate;
  final double totalFee;
  final VoidCallback onSimulateScan;
  final bool showSimulateButton;
  final String currentStatus;

  const RenteeQRDialog({
    super.key,
    required this.item,
    required this.orderDate,
    required this.totalFee,
    required this.onSimulateScan,
    required this.currentStatus,
    this.showSimulateButton = false,
  });

  @override
  Widget build(BuildContext context) {
    // QR data changes based on status
    final String qrData =
        currentStatus.toLowerCase() == 'pending'
            ? "PICKUP:${item.id}" // For pickup verification
            : "RETURN:${item.id}"; // For return verification

    final String dialogTitle =
        currentStatus.toLowerCase() == 'pending'
            ? "Pickup Verification"
            : "Return Verification";

    final String dialogMessage =
        currentStatus.toLowerCase() == 'pending'
            ? "Show this QR code to the renter for pickup verification."
            : "Show this QR code to the renter to confirm item return.";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code, color: const Color(0xFFF8BE17), size: 40),
              const SizedBox(height: 10),
              Text(
                dialogTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                dialogMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),

              // QR CODE with explicit size
              Container(
                width: 220,
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),

              // ITEM DETAILS with proper constraints
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 80),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Color(0xFF800000),
                  ),
                  title: Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Price: RM ${item.pricePerDay} / day"),
                      Text("Quantity: ${item.quantity} pcs"),
                      Text("Rental Days: $orderDate days"),
                    ],
                  ),
                  isThreeLine: true,
                ),
              ),

              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 60),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.payments_outlined,
                    color: Color(0xFF800000),
                  ),
                  title: const Text("Total Fee"),
                  subtitle: Text(
                    "RM $totalFee",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),

              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 60),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.delivery_dining_outlined,
                    color: Color(0xFF800000),
                  ),
                  title: const Text("Delivery Method"),
                  subtitle: Text(
                    item.deliveryMethods,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ACTION BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),

                  // SIMULATE SCAN BUTTON
                  if (showSimulateButton) const SizedBox(width: 10),
                  if (showSimulateButton)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close QR dialog
                        onSimulateScan(); // Trigger simulate scan
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            currentStatus.toLowerCase() == 'pending'
                                ? const Color(0xFFF8BE17) // Gold for pickup
                                : Colors.green, // Green for return
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        currentStatus.toLowerCase() == 'pending'
                            ? "Simulate Pickup"
                            : "Simulate Return",
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
}
