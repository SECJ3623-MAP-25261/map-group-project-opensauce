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

        final activeRentals = state.rentalitems.where((item) {
          return item.status == 'approved' || item.status == 'on_renting';
        }).toList();

        if (activeRentals.isEmpty) {
          return const Center(child: Text("No active rentals."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeRentals.length,
          itemBuilder: (context, index) {
            final rentalitem = activeRentals[index];
            
            bool isWaitingPickup = (rentalitem.status == 'approved');

            return StatusItemCard(
              title: rentalitem.name,
              statusText: isWaitingPickup ? "Ready for Pickup" : "On Renting...",
              imageUrl: rentalitem.imageUrl,

              onStopRent: () {
                if (!isWaitingPickup) {
                  _showStopConfirmation(context, notifier, rentalitem.id);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Scan QR code to start renting first!")),
                  );
                }
              },

              // SHOW QR ACTION (Only show if waiting for pickup)
              onShowQR: isWaitingPickup 
                  ? () => _showQRCodeDialog(context, rentalitem, notifier)
                  : null, 
            );
          },
        );
      },
    );
  }

  // --- QR CODE POPUP DIALOG ---
  void _showQRCodeDialog(BuildContext context, dynamic rentalitem, RenterNotifier notifier) {
    final String itemID = rentalitem.id;
    final String qrData = "PICKUP:$itemID";
    final String displayLocation = (rentalitem.deliveryMethods.isNotEmpty) 
        ? rentalitem.deliveryMethods 
        : "Library UTM (Default)";

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
                data: qrData, 
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // DYNAMIC ITEM DETAILS FROM FIREBASE
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF800000)),
              title: Text(rentalitem.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Price: RM ${rentalitem.price}/Days \nDuration: ${rentalitem.rentingDuration}"),
              isThreeLine: true,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on_outlined, color: Color(0xFF800000)),
              title: const Text("Pickup Location"),
              subtitle: Text(rentalitem.pickupLocation),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          
          // SIMULATE SCAN BUTTON (Only for Demo)
          ElevatedButton(
            onPressed: () {
              notifier.startRental(rentalitem.id); // Update Firebase to 'on_renting'
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pickup Confirmed! Status: On Renting")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF8BE17),
              foregroundColor: Colors.black,
            ),
            child: const Text("Simulate Scan"),
          ),
        ],
      ),
    );
  }

  void _showStopConfirmation(BuildContext context, RenterNotifier notifier, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm to stop rent?"),
        content: const Text("This will mark the item as returned."),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Yes, Stop"),
          ),
        ],
      ),
    );
  }
}