import 'package:easyrent/features/rentee/checkout/services/database.dart';
import 'package:easyrent/features/rentee/homePage/home_page.dart';
import 'package:easyrent/features/renter/listing_management/presentation/pages/renter_listing_wrapper.dart';
import 'package:flutter/material.dart';

class DummySelectRole extends StatelessWidget {
  DummySelectRole({super.key});
  final CheckoutDatabaseServices dbService = CheckoutDatabaseServices();
  // Helper to show errors on screen
  Future handleFetch(BuildContext context) async {
    try {
      String data = await dbService.fetchProducts();
      print("-----------Success: $data");

      // Handle success UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data loaded successfully!")),
      );
    } catch (errorMessage) {
      // Handle the error we "threw" in database.dart
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage.toString())));
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dummy Role Selector")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RenterListingWrapper(),
                    ),
                  );
                }
              },
              child: const Text("Renter"),
            ),
            const SizedBox(height: 80),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Text("Rentee"),
            ),
          ],
        ),
      ),
    );
  }
}
