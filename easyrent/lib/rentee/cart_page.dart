import 'dart:async'; // Needed
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import
import '../services/rentee_service.dart';
import '../models/cart_model.dart';
import '../widgets/cart_item_card.dart';
import 'payment_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final RenteeService _service = RenteeService();
  final Set<String> _selectedCartIds = {};
  final List<CartItemModel> _selectedItems = [];

  // --- NEW: Offline State ---
  bool _isOffline = false;
  StreamSubscription? _internetSubscription;

  @override
  void initState() {
    super.initState();
    _checkInitialInternet();
    _internetSubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      _updateConnectionStatus(result);
    });
  }

  @override
  void dispose() {
    _internetSubscription?.cancel();
    super.dispose();
  }

  void _updateConnectionStatus(dynamic result) {
    bool offline = false;
    if (result is List) {
      offline = result.contains(ConnectivityResult.none);
    } else {
      offline = result == ConnectivityResult.none;
    }
    if (mounted) setState(() => _isOffline = offline);
  }

  Future<void> _checkInitialInternet() async {
    var result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
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

  // (Keep your existing _handleDateEdit, _handleDelete methods here...)
  Future<void> _handleDateEdit(CartItemModel item) async {
    // ... existing logic ...
  }

  void _handleDelete(String cartId) {
    _service.removeFromCart(cartId);
    // Also remove from selection if deleted
    if (_selectedCartIds.contains(cartId)) {
      setState(() {
        _selectedCartIds.remove(cartId);
        _selectedItems.removeWhere((i) => i.cartDocId == cartId);
      });
    }
  }

  void _checkout() {
    if (_isOffline) return; // Safety check

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(checkoutItems: _selectedItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return const Scaffold(body: Center(child: Text("Please Login")));

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<CartItemModel>>(
        stream: _service.streamCartItems(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Your cart is empty"));
          }

          final cartItems = snapshot.data!;
          return ListView.builder(
            itemCount: cartItems.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = cartItems[index];
              final isSelected = _selectedCartIds.contains(item.cartDocId);

              // Use your existing CartItemCard
              return CartItemCard(
                item: item,
                isSelected: isSelected,
                onSelected: (val) => _toggleSelection(item, val!),
                onDelete: () => _handleDelete(item.cartDocId),
                onEditDate: () => _handleDateEdit(item),
              );
            },
          );
        },
      ),

      // --- BOTTOM CHECKOUT BAR ---
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

            // --- UPDATED CHECKOUT BUTTON ---
            ElevatedButton(
              // Disable if: No items selected OR Offline
              onPressed: (_selectedItems.isEmpty || _isOffline)
                  ? null
                  : _checkout,

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800000),
                disabledBackgroundColor: Colors.grey, // Explicit grey
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: Text(
                _isOffline ? "Offline" : "Checkout (${_selectedItems.length})",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
