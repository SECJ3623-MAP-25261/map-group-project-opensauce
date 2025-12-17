import 'package:easyrent/features/rentee/homePage/home_page.dart';
import 'package:easyrent/features/renter/listing_management/presentation/pages/renter_listing_wrapper.dart';
import 'package:flutter/material.dart';

class DummySelectRole extends StatelessWidget {
  const DummySelectRole({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dummy Role Selector")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const RenterListingWrapper(), // <-- FIXED
                  ),
                );
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
