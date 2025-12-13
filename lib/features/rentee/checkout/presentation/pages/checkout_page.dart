import 'package:easyrent/core/utils/loading.dart';
import 'package:easyrent/features/models/item.dart';
import 'package:easyrent/features/rentee/checkout/data/provider/checkout_provider.dart';
import 'package:easyrent/features/rentee/checkout/presentation/widgets/checkout_cart_widget.dart';
import 'package:easyrent/features/rentee/checkout/presentation/widgets/order_summary/bottom_summary_widget.dart';
import 'package:easyrent/features/rentee/presentation/widgets/rentee_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // For nicer fonts

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key, required this.items, required this.duration});
  final Item items;
  final int duration;
  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
  
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  
  @override
  Widget build(BuildContext context) {
    // If loading is true, show the loading widget
    return ref.watch(checkoutProvider).isLoading? const Center(child: CircularProgressIndicator()) : Scaffold(
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
      body: Stack(              
        children: [
          // ref.watch(checkoutProvider).items.isEmpty
          //     ? Center(
          //       // We can use a SizedBox inside Center to ensure it takes up the full available Expanded space
          //       child: SizedBox.expand(
          //         child: Center(
          //           child: Text(
          //             'Your cart is empty!',
          //             style: Theme.of(context).textTheme.titleLarge
          //                 ?.copyWith(color: Colors.grey[600]),
          //           ),
          //         ),
          //       ),
          //     )
          // : 
          // Container(
          //   padding: const EdgeInsets.all(8.0),
          //   child: CheckoutCartWidget(item: widget.items),
          // ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: CheckoutCartWidget(item: widget.items, duration: widget.duration),
              ),
            BottomSummaryWidget(duration: widget.duration,),
        ],
      ),
      // The bottom navigation bar from your design
      bottomNavigationBar: const RenteeBottomNavBar(),
    );
  }
}
