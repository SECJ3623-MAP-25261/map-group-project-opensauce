import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/notifier/renter_notifier.dart';
import '../widgets/availability_item_card.dart';

class RenterAvailabilityPage extends StatelessWidget {
  const RenterAvailabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RenterNotifier>(
      builder: (context, notifier, _) {
        final state = notifier.state;

        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // FILTER: Show items that are part of your inventory (Available or On Hold)
        // We exclude 'pending', 'approved', 'completed' etc.
        final inventoryItems = state.items.where((item) {
          return item.status == 'available' || item.status == 'on_hold';
        }).toList();

        if (inventoryItems.isEmpty) {
          return const Center(
            child: Text("No items in inventory.\n(Add items with status 'available' in Firebase)"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: inventoryItems.length,
          itemBuilder: (context, index) {
            final item = inventoryItems[index];

            return AvailabilityItemCard(
              title: item.name,
              imageUrl: item.imageUrl,
              // You might want to visually show the current status too
              // For now, we rely on the buttons to change it.
              
              onAvailable: () {
                notifier.setAvailability(item.id, "available");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Item marked as Available")),
                );
              },
              
              onHold: () {
                notifier.setAvailability(item.id, "on_hold");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Item marked as On Hold")),
                );
              },
            );
          },
        );
      },
    );
  }
}