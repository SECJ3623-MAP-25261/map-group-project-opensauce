import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/notifier/renter_notifier.dart';

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

        // Filter: Only show items that are currently "approved" (On Renting)
        // You can adjust this filter if you want to show other statuses too.
        final activeRentals = state.items.where((item) => item.status == 'approved').toList();

        if (activeRentals.isEmpty) {
          return const Center(
            child: Text("No active rentals found."),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeRentals.length,
          itemBuilder: (context, index) {
            final item = activeRentals[index];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Image (Network or Asset fallback)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item.imageUrl.startsWith('http')
                          ? Image.network(item.imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover)
                          : Container(
                              height: 120,
                              color: Colors.grey[200],
                              child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                            ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      item.name, // Using the getter from Item model
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "RM ${item.price} / day | ${item.rentalInfo}",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                    
                    const SizedBox(height: 15),

                    // Status row: badge + Stop Rent button
                    Row(
                      children: [
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700), // Gold for "On Renting"
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "On Renting...",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Stop Rent button
                        ElevatedButton(
                          onPressed: () => _showStopConfirmation(context, notifier, item.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Stop Rent"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================
  // CONFIRMATION DIALOG
  // ===========================
  void _showStopConfirmation(BuildContext context, RenterNotifier notifier, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Confirm to stop rent?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("This will mark the item as returned/completed."),
        actionsPadding: const EdgeInsets.only(bottom: 12, right: 12),
        actions: [
          // NO BUTTON
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),

          // YES BUTTON
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              notifier.stopRent(itemId); // Call Firebase
              
              // Optional: Show snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Rent stopped successfully")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Yes, Stop"),
          ),
        ],
      ),
    );
  }
}