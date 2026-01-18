import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easyrent/models/cart_model.dart';
import 'package:easyrent/rentee/payment_page.dart';
import 'package:easyrent/services/rentee_service.dart';
import 'package:easyrent/widgets/cart_item_card.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyCartWidget extends StatefulWidget {
  const MyCartWidget({super.key});

  @override
  State<MyCartWidget> createState() => _MyCartWidgetState();
}

class _MyCartWidgetState extends State<MyCartWidget> {
  final RenteeService _service = RenteeService();
  final Set<String> _selectedCartIds = {};

  // Keep track of the actual Model objects for checkout
  final List<CartItemModel> _selectedItems = [];

  // Connectivity
  bool _isConnected = true;
  StreamSubscription<ConnectivityResult>? _subscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();

    // Listen to stream
    _subscription = Connectivity().onConnectivityChanged.listen((
      ConnectivityResult result,
    ) {
      _updateConnectionStatus(result);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (!mounted) return;
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  double get _currentTotal {
    return _selectedItems.fold(0, (sum, item) => sum + item.totalRentalPrice);
  }

  void _toggleSelection(CartItemModel item, bool selected) {
    setState(() {
      if (selected) {
        _selectedCartIds.add(item.cartDocId);
        _selectedItems.add(item);
      } else {
        _selectedCartIds.remove(item.cartDocId);
        _selectedItems.removeWhere((i) => i.cartDocId == item.cartDocId);
      }
    });
  }

  Future<void> _handleDateEdit(CartItemModel item) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: item.startDate, end: item.endDate),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          primaryColor: const Color(0xFF800000),
          colorScheme: const ColorScheme.light(primary: Color(0xFF800000)),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      await _service.updateCartDates(item.cartDocId, picked.start, picked.end);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Dates updated!")));
      }
    }
  }

  void _checkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // PASS LIST OF MODELS
        builder: (context) => PaymentPage(checkoutItems: _selectedItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please Login")));
    }

    return Scaffold(
    
      body: StreamBuilder<List<CartItemModel>>(
        stream: _service.getCartStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text("Your cart is empty"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return CartItemCard(
                item: item,
                isSelected: _selectedCartIds.contains(item.cartDocId),
                onSelected: (val) => _toggleSelection(item, val ?? false),
                onDelete: () {
                  _service.removeFromCart(item.cartDocId);
                  _toggleSelection(item, false);
                },
                onEditDates: () => _handleDateEdit(item),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 5, color: Colors.grey.withOpacity(0.2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Estimate:",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  "RM ${_currentTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF800000),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: (_selectedItems.isEmpty || !_isConnected)
                  ? null
                  : _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isConnected
                    ? const Color(0xFF800000)
                    : Colors.grey,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: Text(
                !_isConnected
                    ? "Offline"
                    : "Checkout (${_selectedItems.length})",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}