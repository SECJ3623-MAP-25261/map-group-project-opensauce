import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import the files created above
import '../datasources/notification_remote_api.dart';
import '../repositories/notification_repository.dart'; // Impl is inside this file or import separate
import '../services/notification_service.dart';

// 1. Wrapper to inject the Provider (Like RenterManagementWrapper)
class NotificationPageWrapper extends StatelessWidget {
  const NotificationPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => NotificationNotifier(
            NotificationRepositoryImpl(NotificationRemoteApiImpl()),
          )..loadNotifications(), // Fetch data immediately on load
      child: const NotificationPage(),
    );
  }
}

// 2. The Actual Page
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const BackButton(color: Colors.black),
        actions: [
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              Provider.of<NotificationNotifier>(
                context,
                listen: false,
              ).loadNotifications();
            },
          ),
        ],
      ),
      body: Consumer<NotificationNotifier>(
        builder: (context, notifier, _) {
          final state = notifier.state;

          // --- Loading State ---
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Empty State ---
          if (state.items.isEmpty) {
            return const Center(child: Text("No approved items found."));
          }

          // --- Data State ---
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (c, e, s) => const Icon(Icons.image, size: 50),
                    ),
                  ),
                  title: const Text(
                    "Item Approved!",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "The item '${item.name}' is approved and ready.",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
