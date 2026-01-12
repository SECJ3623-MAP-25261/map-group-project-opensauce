import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_page.dart';
import '../common/edit_profile_page.dart';
import '../common/main_navigation_page.dart';
import 'renter_settings_page.dart';
import 'renter_order_page.dart';
import '../common/notification_page.dart';

class RenterProfilePage extends StatelessWidget {
  const RenterProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const primaryColor = Color(0xFF800000);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Renter Profile"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white, // Ensure text/icons are white
        automaticallyImplyLeading: false,
        actions: [
          // --- NOTIFICATION ICON WITH BADGE ---
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: user?.uid)
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount = 0;
              if (snapshot.hasData) {
                unreadCount = snapshot.data!.docs.length;
              }

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationPage(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        // Added scroll just in case
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Profile Header
            CircleAvatar(
              radius: 50,
              backgroundColor: primaryColor,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.store, size: 50, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              user?.displayName ?? "Renter",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(user?.email ?? "", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            // Options List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // --- NEW: ORDERS TILE ---
                  _buildTile(Icons.assignment_outlined, "Incoming Orders", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RenterOrdersPage(),
                      ),
                    );
                  }),

                  const Divider(),

                  _buildTile(Icons.swap_horiz, "Switch to Rentee", () {
                    // Restart app at Rentee home
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MainNavigationPage(initialRenterMode: false),
                      ),
                      (route) => false,
                    );
                  }),

                  _buildTile(Icons.settings, "Rental Settings", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RenterSettingsPage(),
                      ),
                    );
                  }),

                  const Divider(),

                  _buildTile(Icons.edit, "Edit Personal Profile", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  }),

                  _buildTile(Icons.logout, "Logout", () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (route) => false,
                      );
                    }
                  }, color: Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String text,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 4,
      ), // Add slight spacing
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? const Color(0xFF800000)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color ?? const Color(0xFF800000)),
      ),
      title: Text(
        text,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
