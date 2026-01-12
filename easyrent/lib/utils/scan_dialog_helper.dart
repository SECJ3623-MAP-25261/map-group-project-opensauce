import 'package:flutter/material.dart';

class ScanDialogHelper {
  static void showError(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Scan Failed", style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onRetry();
            },
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  static void showSuccess(BuildContext context, VoidCallback onOk) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
        title: const Text("Pickup Verified!"),
        content: const Text(
          "The order has started. Status changed to Ongoing.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close Dialog
              onOk(); // Execute navigation or logic
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
