import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notification_service.dart';
import '../../presentation/notification_page.dart';

class NotificationIconBadge extends StatelessWidget {
  const NotificationIconBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationNotifier>(
      builder: (context, notifier, child) {
        // Safe access to list length
        int notificationCount = notifier.state.items.length;

        // Wrap the whole thing in the margin container matching your other buttons
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          // 🔥 The Stack is now the parent widget
          child: Stack(
            clipBehavior:
                Clip.none, // Allows the dot to slightly overlap the edge
            children: [
              // --- 1. The Base Layer: Yellow Container & Icon ---
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFC107), // Yellow background
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationPage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons
                        .notifications_none_outlined, // Use outlined for cleaner look
                    color: Color(0xFF5C001F), // Maroon icon
                    size: 24,
                  ),
                  tooltip: 'Notifications',
                  // Reduce padding so the container isn't too large
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),

              // --- 2. The Top Layer: Red Dot ---
              if (notificationCount > 0)
                Positioned(
                  // Position it exactly on the top-right corner edge
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      // Add a white border to make it pop off the yellow
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth:
                          18, // Ensures a perfect circle for single digits
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        notificationCount > 9 ? '9+' : '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
