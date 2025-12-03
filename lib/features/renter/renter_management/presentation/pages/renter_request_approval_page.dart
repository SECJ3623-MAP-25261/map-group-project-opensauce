import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/notifier/renter_notifier.dart';
import '../widgets/approval_item_card.dart';

class RenterRequestApprovalPage extends StatelessWidget {
  const RenterRequestApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RenterNotifier>(
      builder: (context, notifier, _) {
        final state = notifier.state;

        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.items.isEmpty) {
          return const Center(child: Text("No items to approve."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.items.length,
          itemBuilder: (context, index) {
            final item = state.items[index];

            return ApprovalItemCard(
              title: item.name,
              subtitle: "${item.price} | ${item.rentalInfo}",
              imageUrl: item.imageUrl,
              status: item.status, // <-- NEW
              
              onApprove: () {
                notifier.approveItem(item.id);
                _showApproveDialog(context);
              },

              onReject: () {
                notifier.rejectItem(item.id);
                _showNotApproveDialog(context);
              },
            );
          },
        );
      },
    );
  }

  // ===========================
  // APPROVED POP-UP DIALOG
  // ===========================
  void _showApproveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Request Approved",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("You have approved this renter request."),
          actionsPadding: const EdgeInsets.only(bottom: 12, right: 12),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700), // Gold
                foregroundColor: Colors.white,
              ),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // ===========================
  // REJECTED POP-UP DIALOG
  // ===========================
  void _showNotApproveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Request Not Approved",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("You have rejected this renter request."),
          actionsPadding: const EdgeInsets.only(bottom: 12, right: 12),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700), // Gold
                foregroundColor: Colors.white,
              ),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
