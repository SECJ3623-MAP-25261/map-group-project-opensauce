import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity_service.dart'; // Import your existing service

class ConnectivityWrapper extends ConsumerWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the provider you already created
    final connectivityStatus = ref.watch(connectivityProvider);

    return connectivityStatus.when(
      data: (isConnected) {
        return Stack(
          children: [
            child, // Render the actual app (MainScreen)
            // If offline, show a banner or overlay
            if (!isConnected)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.all(8),
                  child: const Text(
                    "You are offline",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        );
      },
      // While loading initial status, just show the app or a loader
      loading: () => child,
      error: (_, __) => child,
    );
  }
}
