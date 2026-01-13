import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cart_model.dart';
import '../services/rentee_service.dart';

class PaymentPage extends StatefulWidget {
  // CORRECTED: Accepts List of Models
  final List<CartItemModel> checkoutItems;

  const PaymentPage({super.key, required this.checkoutItems});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final RenteeService _service = RenteeService();
  String _paymentMethod = 'Cash';
  bool _isLoading = false;
  final double _depositPerItem = 50.00;
  final Map<String, String?> _selectedLocations = {};

  @override
  void initState() {
    super.initState();
    for (var item in widget.checkoutItems) {
      if (item.pickupLocations.isNotEmpty) {
        _selectedLocations[item.cartDocId] = item.pickupLocations[0].toString();
      } else {
        _selectedLocations[item.cartDocId] = "Contact Owner";
      }
    }
  }

  double get totalRentalFee =>
      widget.checkoutItems.fold(0, (sum, item) => sum + item.totalRentalPrice);
  double get totalDeposit => _depositPerItem * widget.checkoutItems.length;
  double get grandTotal => totalRentalFee + totalDeposit;

  void _showDepositInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.green),
            SizedBox(width: 10),
            Text("Security Deposit"),
          ],
        ),
        content: const Text("RM 50 per item. Refundable upon return."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Understood"),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);

    try {
      await _service.processCheckout(
        items: widget.checkoutItems,
        paymentMethod: _paymentMethod,
        selectedLocations: _selectedLocations,
        depositPerItem: _depositPerItem,
      );

      if (mounted) {
        String successMsg = _paymentMethod == 'Cash'
            ? "Booking Confirmed! Prepare Cash."
            : "Booking Confirmed! Transfer funds.";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMsg)));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review & Pay"),
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...widget.checkoutItems.map((item) {
              String dateString =
                  "${DateFormat('dd MMM').format(item.startDate)} - ${DateFormat('dd MMM').format(item.endDate)}";
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.image.isNotEmpty
                              ? Image.network(
                                  item.image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.inventory_2),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "RM ${item.pricePerDay.toStringAsFixed(2)} x ${item.days} Days = RM ${item.totalRentalPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Color(0xFF800000),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Dates:",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          dateString,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pickup At:",
                          style: TextStyle(color: Colors.grey),
                        ),
                        DropdownButton<String>(
                          value: _selectedLocations[item.cartDocId],
                          isDense: true,
                          underline: const SizedBox(),
                          items:
                              (item.pickupLocations.isNotEmpty
                                      ? item.pickupLocations
                                      : ["Contact Owner"])
                                  .map<DropdownMenuItem<String>>((loc) {
                                    return DropdownMenuItem(
                                      value: loc.toString(),
                                      child: Text(
                                        loc.toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                          onChanged: (val) => setState(
                            () => _selectedLocations[item.cartDocId] = val,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Rental Fee"),
                      Text("RM ${totalRentalFee.toStringAsFixed(2)}"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Security Deposit",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: _showDepositInfo,
                            child: const Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "RM ${totalDeposit.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Grand Total",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "RM ${grandTotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF800000),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Payment Method",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            RadioListTile(
              title: const Text("Cash on Pickup"),
              value: "Cash",
              groupValue: _paymentMethod,
              onChanged: (val) =>
                  setState(() => _paymentMethod = val.toString()),
            ),
            RadioListTile(
              title: const Text("Bank Transfer"),
              value: "Bank",
              groupValue: _paymentMethod,
              onChanged: (val) =>
                  setState(() => _paymentMethod = val.toString()),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800000),
                ),
                onPressed: _isLoading ? null : _confirmBooking,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Confirm Booking",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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
}
