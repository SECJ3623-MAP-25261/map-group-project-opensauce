import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/notifier/listing_notifier.dart';
import '../../data/repositories/listing_repository_impl.dart';

import 'listing.dart';

class RenterListingWrapper extends StatelessWidget {
  const RenterListingWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ListingNotifier(
        ListingRepositoryImpl(), 
      )..loadMyItems(), // Optional: Load data immediately when app starts
      
      child: const RenterListingPage(),
    );
  }
}