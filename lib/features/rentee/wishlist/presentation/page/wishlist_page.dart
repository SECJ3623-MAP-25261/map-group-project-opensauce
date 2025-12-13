import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyrent/core/constants/constants.dart';
import 'package:easyrent/features/models/item.dart';
import 'package:easyrent/features/rentee/checkout/data/provider/checkout_provider.dart';
import 'package:easyrent/features/rentee/wishlist/data/provider/provider.dart';
import 'package:easyrent/features/rentee/wishlist/presentation/widgets/total_summary_widget.dart';
import 'package:easyrent/features/rentee/presentation/widgets/rentee_bottom_navbar.dart';
import 'package:easyrent/features/rentee/wishlist/presentation/widgets/wishlist_card.dart';
import 'package:easyrent/features/rentee/wishlist/services/database.dart';
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
    final dbService = WishlistDatabaseServices();
        // Total Summary Bar (Yellow Section)
        return Scaffold(
          // MAIN PART
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Wishlist',
              style: KTextStyle.appBarTitle,
            ),
            centerTitle: true,
          ),

          // The body is split into the scrollable list and the fixed summary at the bottom.
          body: Stack(
            children: [
              Positioned.fill(
                child: StreamBuilder(
                  //TODO: integrate user auth 
                  stream: dbService.getWishlistItems(AppString.userSampleId),
                  builder: (context, asyncSnapshot) {

                   if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (asyncSnapshot.hasError) {
                      return Center(child: Text('Error loading wishlist: ${asyncSnapshot.error}'));
                    }
                    if (!asyncSnapshot.hasData || asyncSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Your wishlist is empty!',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }
                    // Data is available: snapshot.data is a List<Map<String, dynamic>>
                    final List<Item> wishlistItems = asyncSnapshot.data!;

                    Future.microtask(() {
                      if(ref.watch(shoppingCartProvider).items.isEmpty){
                         ref.read(shoppingCartProvider.notifier).setItems(wishlistItems);
                      }
                    });

                      return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: wishlistItems.length,
                      itemBuilder: (context, index) {
                        // Pass the fetched map data to your WishlistCard
                        return WishlistCard(item: wishlistItems[index]);
                      },
                    );
                  }
                ),
              ),
              // 2. Fixed Total Summary
              TotalSummaryWidget(),
            ],
            // 1. Scrollable Cart Items
          ),
          // 3. Bottom Navigation Bar
        );
  }
}
