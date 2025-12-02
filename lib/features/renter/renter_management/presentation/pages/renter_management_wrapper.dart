import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/notifier/renter_notifier.dart';
import '../../data/repositories/renter_repository_impl.dart';
import '../../data/datasources/renter_remote_api.dart';
import 'renter_management_page.dart';

class RenterManagementWrapper extends StatelessWidget {
  const RenterManagementWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RenterNotifier(
        RenterRepositoryImpl(
          RenterRemoteApi(),
        ),
      )..loadItems(),
      child: const RenterManagementPage(),
    );
  }
}
