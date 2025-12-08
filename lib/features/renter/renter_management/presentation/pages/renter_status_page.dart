import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notifier/renter_notifier.dart';
import '../widgets/status_item_card.dart'; // Import the widget

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
        final activeRentals = state.rentalitems.where((rentalitem) => rentalitem.status == 'approved').toList();

        if (activeRentals.isEmpty) {
          return const Center(child: Text("No active rentals found."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeRentals.length,
          itemBuilder: (context, index) {
            final rentalitem = activeRentals[index];

            // USE THE WIDGET HERE instead of manual Card
            return StatusItemCard(
              title: rentalitem.name,
              // Format: "RM 50 / day | 3 Days"
              statusText: "On Renting...", 
              imageUrl: rentalitem.imageUrl,
              
              onStopRent: () {
                 // We call the dialog function defined at the bottom of this class
                _showStopConfirmation(context, notifier, rentalitem.id);
              },
            );
          },
        );
      },
    );
  }

  // ... (Keep the _showStopConfirmation method at the bottom of the file)
   void _showStopConfirmation(BuildContext context, RenterNotifier notifier, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm to stop rent?", style: TextStyle(fontWeight: FontWeight.bold)),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Yes, Stop"),
          ),
        ],
      ),
    );
  }
}