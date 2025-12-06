import 'package:flutter/material.dart';

class ReportItemWidget extends StatefulWidget {
  // A callback function to handle the report submission logic.
  // It takes the report reason (String) and returns a Future<bool>
  // indicating if the submission was successful.
  final Future<bool> Function(String reason, Map<String, dynamic> item)
  onSubmitReport;

  // Optional: The ID or name of the item being reported, for context.
  final Map<String, dynamic> item;

  const ReportItemWidget({
    super.key,
    required this.onSubmitReport,
    required this.item,
  });

  @override
  State<ReportItemWidget> createState() => _ReportItemWidgetState();
}

class _ReportItemWidgetState extends State<ReportItemWidget> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  // --- Core Dialog Logic ---
  void _showReportDialog() {
    // Clear previous input before showing
    _reasonController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report ${widget.item['product_name']}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  'Please tell us why you are reporting this item:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _reasonController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText:
                        'e.g., Incorrect description, Broken link, Offensive content...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ValueListenableBuilder<TextEditingValue>(
              // Only enable the submit button if the reason is not empty
              valueListenable: _reasonController,
              builder: (context, value, child) {
                return ElevatedButton(
                  onPressed: value.text.trim().isEmpty ? null : _submitReport,
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                          : const Text('Submit Report'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --- Report Submission Handler ---
  void _submitReport() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) return;

    // Close the keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    // Set state to show loading indicator in the dialog
    if (mounted) {
      setState(() {
        _isSubmitting = true;
      });
    }

    try {
      // Execute the provided submission logic
      final success = await widget.onSubmitReport(reason, widget.item);

      // Close the dialog after submission attempt
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show a confirmation or error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Report successfully submitted. Thank you!'
                  : 'Failed to submit report. Please try again.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle any exceptions from the onSubmitReport function
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Reset the submitting state
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // ** MAIN **
  @override
  Widget build(BuildContext context) {
    // A simple button to trigger the reporting process.
    // You could replace this with an IconButton or a ListTile.
    return ElevatedButton(
      onPressed: _showReportDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.flag_outlined, size: 12),
          SizedBox(width: 6),
          Text(
            "Report",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
