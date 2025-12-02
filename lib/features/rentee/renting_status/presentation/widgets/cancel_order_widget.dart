import 'package:flutter/material.dart';

void showCancelConfirmationModal({
  required BuildContext context,
  required Map<String,dynamic> item,
  required Future<void> Function(Map<String,dynamic> item) onConfirm,
}) {
  showDialog(
    context: context,
    barrierDismissible: true, // Allow dismissal by tapping outside
    builder: (BuildContext dialogContext) {
      return CancelOrderWidget(
        item: item,
        onConfirm: onConfirm,
      );
    },
  );
}

// Internal StatefulWidget to manage the loading state of the confirm button
class CancelOrderWidget extends StatefulWidget {
  final Map<String,dynamic> item;
  final Future<void> Function(Map<String,dynamic> item) onConfirm;

  const CancelOrderWidget({
    super.key,
    required this.item,
    required this.onConfirm,
  });

  @override
  State<CancelOrderWidget> createState() =>
      _CancelOrderWidgetState();
}

class _CancelOrderWidgetState extends State<CancelOrderWidget> {
  bool _isProcessing = false;

  void _handleConfirm() async {
    // 1. Set state to show loading
    if (mounted) {
      setState(() {
        _isProcessing = true;
      });
    }

    // 2. Execute the user-provided confirmation logic
    try {
      await widget.onConfirm(widget.item);

      // 3. Close the modal upon successful completion (or if handled otherwise 
      //    in the onConfirm function).
      if (mounted) {
        Navigator.of(context).pop();
        // Optional: Show a success message via Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order cancelled successfully.',style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 4. Handle error: show error message and reset button state
      if (mounted) {
        // You might want to keep the dialog open to let the user try again
        // Or close it and show a full-screen error/snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel order: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessing = false; // Reset loading state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
          SizedBox(width: 10),
          Text('Cancel Order?'),
        ],
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              'Are you sure you want to cancel order ${widget.item['id']}?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone, and your order will be removed from processing.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        // --- Cancel Button ---
        TextButton(
          onPressed: _isProcessing
              ? null // Disable if processing
              : () => Navigator.of(context).pop(),
          child: const Text(
            'Keep Order',
            style: TextStyle(color: Colors.blueGrey),
          ),
        ),

        // --- Confirm/Cancel Button ---
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          onPressed: _isProcessing ? null : _handleConfirm,
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : const Text('Confirm Cancellation'),
        ),
      ],
    );
  }
}