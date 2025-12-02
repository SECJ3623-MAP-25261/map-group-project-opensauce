import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/features/rentee/wishlist/data/dummy_data/wishlist_dummy.dart';
import 'package:easyrent/features/rentee/application/notifiers.dart';
import 'package:easyrent/features/rentee/wishlist/data/provider/provider.dart';
import 'package:easyrent/features/rentee/wishlist/presentation/widgets/delivery_options.dart';
import 'package:easyrent/features/rentee/wishlist/presentation/widgets/total_summary_widget.dart';
import 'package:easyrent/features/rentee/presentation/widgets/rentee_bottom_navbar.dart';
import 'package:easyrent/features/rentee/wishlist/presentation/widgets/wishlist_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WishlistPage extends ConsumerStatefulWidget {
  const WishlistPage({super.key});

  @override
  ConsumerState<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends ConsumerState<WishlistPage> {
  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(shoppingCartProvider);
        // Total Summary Bar (Yellow Section)
        return Scaffold(
          // MAIN PART
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {},
            ),
            title: const Text(
              'Shopping Cart',
              style: KTextStyle.appBarTitle,
            ),
            centerTitle: true,
          ),

          // The body is split into the scrollable list and the fixed summary at the bottom.
          body: Stack(
            children: [
              Positioned.fill(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: cartState.items.length,
                  itemBuilder: (context, index) {
                    return WishlistCard(item: cartState.items[index]);
                  },
                ),
              ),
              // 2. Fixed Total Summary
              TotalSummaryWidget(),
            ],
            // 1. Scrollable Cart Items
          ),
          // 3. Bottom Navigation Bar
          bottomNavigationBar: RenteeBottomNavBar(),
        );
  }
}
