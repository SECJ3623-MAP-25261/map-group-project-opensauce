import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/notifier/renter_notifier.dart';
import '../widgets/status_item_card.dart';

class RenterStatusPage extends StatelessWidget {
  const RenterStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RenterNotifier>(
      builder: (context, notifier, _) {
        final state = notifier.state;

        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter for "approved" items
        final activeRentals = state.rentalitems
            .where((rentalitem) => rentalitem.status == 'approved')
            .toList();

        if (activeRentals.isEmpty) {
          return const Center(child: Text("No active rentals found."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeRentals.length,
          itemBuilder: (context, index) {
            final rentalitem = activeRentals[index];

            return StatusItemCard(
              title: rentalitem.name,
              statusText: "On Renting...",
              imageUrl: rentalitem.imageUrl,

              // 1. STOP RENT ACTION
              onStopRent: () {
                _showStopConfirmation(context, notifier, rentalitem.id);
              },

              // 2. SHOW QR ACTION (Gold Button)
              onShowQR: () {
                _showQRCodeDialog(context, rentalitem);
              },
            );
          },
        );
      },
    );
  }

  // --- QR CODE POPUP DIALOG ---
  void _showQRCodeDialog(BuildContext context, dynamic rentalitem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pickup Verification", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Let the rentee scan this to confirm pickup."),
            const SizedBox(height: 20),

            // GENERATE QR CODE
            SizedBox(
              height: 200,
              width: 200,
              child: QrImageView(
                data: "PICKUP:${rentalitem.id}", // Payload: "PICKUP:ITEM_ID"
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // ITEM DETAILS
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: Text(rentalitem.name),
              subtitle: Text("Rental Price: ${rentalitem.price}"),
            ),
            const ListTile(
              leading: Icon(Icons.location_on_outlined),
              title: Text("Pickup Location"),
              subtitle: Text("Library UTM (Default)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF8BE17), // Gold color
              foregroundColor: Colors.black,
            ),
            child: const Text("Done"),
          )
        ],
      ),
    );
  }

  // --- STOP RENT CONFIRMATION ---
  void _showStopConfirmation(
      BuildContext context, RenterNotifier notifier, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm to stop rent?",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("This will mark the item as returned/completed."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.stopRent(itemId);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Yes, Stop"),
          ),
        ],
      ),
    );
  }
}