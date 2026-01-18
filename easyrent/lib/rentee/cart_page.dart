import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/rentee_service.dart';
import '../models/cart_model.dart';
import '../widgets/cart_item_card.dart'; // Ensure this exists
import 'payment_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with SingleTickerProviderStateMixin {
  final RenteeService _service = RenteeService();
  final Set<String> _selectedCartIds = {};
  late TabController _tabController;
  // Keep track of the actual Model objects for checkout
  final List<CartItemModel> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorWeight: 2,
          tabs: const [
            Tab(text: "Cart"),
            Tab(text: "Ordering"),
            Tab(text: "In Renting"),
            Tab(text: "History"),
          ]
        ),
      ),
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
              onPressed: _selectedItems.isEmpty ? null : _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800000),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: Text(
                "Checkout (${_selectedItems.length})",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
