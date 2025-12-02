import 'package:easyrent/features/rentee/checkout/data/checkout_dummy_data.dart';
import 'package:easyrent/features/rentee/checkout/data/provider/checkout_provider.dart';
import 'package:easyrent/features/rentee/checkout/presentation/widgets/checkout_cart_widget.dart';
import 'package:easyrent/features/rentee/checkout/presentation/widgets/order_summary/bottom_summary_widget.dart';
import 'package:easyrent/features/rentee/presentation/widgets/rentee_bottom_navbar.dart';
import 'package:easyrent/features/rentee/wishlist/data/dummy_data/wishlist_dummy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // For nicer fonts

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {

  // Calculate totals
  double get _rentingFee {
    return userWishlist.fold(0.0, (sum, item) => sum + (item['price_per_day'] * item['quantity']));
  }

  // double get _itemDeposit {
  //   // Mock deposit calculation - typically a percentage or fixed amount per item
  //   return userWishlist.fold(0.0, (sum, item) => sum + (item['price_per_day'] * item['quantity'] * 0.5)); // 50% deposit
  // }

  // void _onRemoveItem(String itemId) {
  //   setState(() {
  //     userWishlist.removeWhere((item) => item['id'] == itemId);
  //   });
  // }

  // void _onQuantityChanged(String itemId, int newQuantity) {
  //   setState(() {
  //     final index = userWishlist.indexWhere((item) => item['id'] == itemId);
  //     if (index != -1) {
  //       userWishlist[index]['quantity'] = newQuantity;
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Shopping Cart',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[50], // Light background for the page
      body: Column(
        children: [
          Expanded(
            child: ref.watch(checkoutProvider).items.isEmpty
                ? Center(
                    child: Text(
                      'Your cart is empty!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: ref.watch(checkoutProvider).items.length,
                    itemBuilder: (context, index) {
                      return CheckoutCartWidget(
                        item: ref.watch(checkoutProvider).items[index],
                        // onRemove: () => _onRemoveItem(item['id']),
                        // onQuantityChanged: (newQuantity) => _onQuantityChanged(item['id'], newQuantity),
                      );
                    },
                  ),
          ),
          // --- Bottom Summary and Checkout Button ---
          BottomSummaryWidget(),
        ],
      ),
      // The bottom navigation bar from your design
      bottomNavigationBar: const RenteeBottomNavBar(),
    );
  }

  // Widget _buildDeliveryOption() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           'Delivery Options',
  //           style: GoogleFonts.poppins(
  //             fontSize: 16,
  //             color: Colors.grey[700],
  //           ),
  //         ),
  //         DropdownButtonHideUnderline(
  //           child: DropdownButton<String>(
  //             value: _selectedDeliveryOption,
  //             icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
  //             style: GoogleFonts.poppins(
  //               fontSize: 15,
  //               color: Colors.deepPurple,
  //               fontWeight: FontWeight.w500,
  //             ),
  //             borderRadius: BorderRadius.circular(12),
  //             items: _deliveryOptions.map((String option) {
  //               return DropdownMenuItem<String>(
  //                 value: option,
  //                 child: Text(option),
  //               );
  //             }).toList(),
  //             onChanged: (String? newValue) {
  //               setState(() {
  //                 _selectedDeliveryOption = newValue;
  //               });
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildTotalSection() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
  //     decoration: BoxDecoration(
  //       color: Colors.purple.withOpacity(0.05), // A subtle background for total
  //       borderRadius: BorderRadius.circular(10.0),
  //       border: Border.all(color: Colors.purple.withOpacity(0.2)),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           'Total',
  //           style: GoogleFonts.poppins(
  //             fontSize: 22,
  //             fontWeight: FontWeight.w700,
  //             color: Colors.black87,
  //           ),
  //         ),
  //         Text(
  //           'RM ${_totalAmount.toStringAsFixed(2)}',
  //           style: GoogleFonts.poppins(
  //             fontSize: 26,
  //             fontWeight: FontWeight.w900,
  //             color: Colors.deepPurple,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // // A simple bottom navigation bar like in your design
  // Widget _buildBottomNavBar() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, -3),
  //         ),
  //       ],
  //     ),
  //     child: BottomNavigationBar(
  //       backgroundColor: Colors.transparent,
  //       elevation: 0,
  //       type: BottomNavigationBarType.fixed,
  //       selectedItemColor: Colors.deepPurple,
  //       unselectedItemColor: Colors.grey,
  //       selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
  //       unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
  //       currentIndex: 0, // Assuming 'Explore' is the first tab
  //       onTap: (index) {
  //         // Handle navigation
  //       },
  //       items: const [
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.explore_outlined),
  //           label: 'EXPLORE',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.favorite_border),
  //           label: 'WISHLIST',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.qr_code_scanner),
  //           label: 'SCAN',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.message_outlined),
  //           label: 'MESSAGES',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.person_outline),
  //           label: 'ACCOUNT',
  //         ),
  //       ],
  //     ),
  //   );
  // }
}