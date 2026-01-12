import 'package:flutter/material.dart';
// CORRECTED IMPORT: Points to the shared 'services' folder
import '../services/renter_service.dart';

class RenterSettingsPage extends StatefulWidget {
  const RenterSettingsPage({super.key});

  @override
  State<RenterSettingsPage> createState() => _RenterSettingsPageState();
}

class _RenterSettingsPageState extends State<RenterSettingsPage> {
  // 1. Instantiate the "RenterService" (Not RenterSettingsService)
  final RenterService _renterService = RenterService();

  final _addressController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // 2. Use the correct method name: 'loadRenterSettings'
  Future<void> _fetchData() async {
    try {
      final data = await _renterService.loadRenterSettings();
      if (mounted) {
        setState(() {
          _addressController.text = data['pickupAddress'] ?? '';
          _bankNameController.text = data['bankName'] ?? '';
          _accountNumberController.text = data['accountNumber'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 3. Use the correct method name: 'saveRenterSettings'
  Future<void> _saveData() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a pickup address")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _renterService.saveRenterSettings(
        pickupAddress: _addressController.text,
        bankName: _bankNameController.text,
        accountNumber: _accountNumberController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Settings Saved!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Renter Settings"),
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: PICKUP ---
                  _buildSectionHeader("Pickup Location"),

                  const SizedBox(height: 15),

                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: "Address",
                      hintText: "e.g. Block A, UTM Johor",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    maxLines: 1,
                  ),

                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 20),
                    child: Text(
                      "You will be able to pin this on a map later.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),

                  const Divider(),
                  const SizedBox(height: 15),

                  // --- SECTION 2: PAYOUT ---
                  _buildSectionHeader("Payout Details"),

                  const SizedBox(height: 8),
                  const Text(
                    "Where should we send your earnings?",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  // Gap to prevent text overlap
                  const SizedBox(height: 25),

                  TextField(
                    controller: _bankNameController,
                    decoration: const InputDecoration(
                      labelText: "Bank Name",
                      hintText: "e.g. Maybank",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _accountNumberController,
                    decoration: const InputDecoration(
                      labelText: "Account Number",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 40),

                  // --- SAVE BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF800000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Save Settings",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF800000),
      ),
    );
  }
}
