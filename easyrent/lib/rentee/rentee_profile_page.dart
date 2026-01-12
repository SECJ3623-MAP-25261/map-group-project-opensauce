import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../common/edit_profile_page.dart';
import '../auth/login_page.dart';
import '../common/main_navigation_page.dart';
import 'rentee_orders_page.dart';
import '../common/notification_page.dart';

class RenteeProfilePage extends StatefulWidget {
  const RenteeProfilePage({super.key});

  @override
  State<RenteeProfilePage> createState() => _RenteeProfilePageState();
}

class _RenteeProfilePageState extends State<RenteeProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  // --- 1. LOGIC: BECOME A RENTER ---
  Future<void> _handleBecomeRenter() async {
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // A. Reload User (Crucial to get fresh emailVerified status)
      await user!.reload();
      user = FirebaseAuth.instance.currentUser;

      // B. STRICT CHECK: Is email verified?
      if (!user!.emailVerified) {
        // Stop loading so we can show the dialog
        setState(() => _isLoading = false);

        // Send Verification Email
        await user!.sendEmailVerification();

        if (mounted) {
          _showVerificationDialog();
        }
        return; // STOP HERE. Do not call Cloud Function.
      }

      // C. IF VERIFIED: Call the Cloud Function
      // This securely updates the database on the server
      final result = await FirebaseFunctions.instance
          .httpsCallable('enableRenterMode')
          .call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.data['message']),
            backgroundColor: Colors.green,
          ),
        );

        // D. Navigate to Renter Mode
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const MainNavigationPage(initialRenterMode: true),
          ),
          (route) => false,
        );
      }
    } on FirebaseFunctionsException catch (e) {
      // Handle Cloud Function errors (e.g., internal error)
      if (mounted) _showError("Server Error: ${e.message}");
    } catch (e) {
      // Handle other errors
      if (mounted) _showError("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Verification Required"),
        content: const Text(
          "To become a Renter, you must verify your email address.\n\n"
          "We have sent a verification link to your email inbox.\n"
          "Please click the link, then come back and press 'Become a Renter' again.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // --- 2. LOGIC: SWITCH TO RENTER (If already authorized) ---
  void _switchToRenter() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigationPage(initialRenterMode: true),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF800000);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          // --- NOTIFICATION BADGE ---
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationPage(),
                      ),
                    ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 30),
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 10),
                // Name & Email
                Text(
                  user?.displayName ?? "User",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Options List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildTile(Icons.assignment_outlined, "My Orders", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RenteeOrdersPage(),
                          ),
                        );
                      }),

                      const Divider(),

                      // Conditional: "Become a Renter" OR "Switch to Renter"
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>?;

                          // Check if they are already a renter in the DB
                          final bool isRenter = data?['isRenter'] ?? false;

                          if (isRenter) {
                            return _buildTile(
                              Icons.swap_horiz,
                              "Switch to Renter Mode",
                              _switchToRenter,
                            );
                          } else {
                            return _buildTile(
                              Icons.verified_user,
                              "Become a Renter",
                              _handleBecomeRenter, // Calls our new logic
                            );
                          }
                        },
                      ),

                      _buildTile(Icons.edit, "Edit Profile", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );
                      }),

                      const Divider(),

                      _buildTile(Icons.logout, "Logout", () async {
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
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
    );
  }

  // --- HELPER UI FUNCTION ---
  Widget _buildTile(
    IconData icon,
    String text,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
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
