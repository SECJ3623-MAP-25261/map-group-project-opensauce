import 'package:easyrent/views/pages/rentee/my_profile_page.dart';
import 'package:easyrent/views/widgets/rentee/rentee_bottom_navbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// rentee profile page (Zhen Yang)
class RenteeprofilePage extends StatefulWidget {
  const RenteeprofilePage({super.key});

  @override
  State<RenteeprofilePage> createState() => _RenteeprofilePageState();
}

class _RenteeprofilePageState extends State<RenteeprofilePage> {
  int _selectedIndex = 4; // profile

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Navigate to other pages here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // --- BODY ---
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --- PROFILE IMAGE ---
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Zhen Yang",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Rentee • UTM Student",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // --- SWITCH BUTTON ---
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("Switch")));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF8BE17),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    "Switch to Renter",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              // --- MENU SECTIONS ---
              ProfileMenuWidget(
                title: "My Profile",
                icon: Icons.person,
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyProfilePage(),
                    ),
                  );
                },
              ),
              ProfileMenuWidget(title: "Settings", icon: Icons.settings),

              const Divider(),
              const SizedBox(height: 10),
              ProfileMenuWidget(title: "Information", icon: Icons.info),
              ProfileMenuWidget(
                title: "Logout",
                icon: Icons.logout,
                textColor: Colors.red,
                onPress: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("LOGOUT"),
                          content: const Text(
                            "Are you sure you want to logout?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("No"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Logged out")),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              child: const Text("Yes"),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: RenteeBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// --- SIMPLE REUSABLE MENU WIDGET ---
class ProfileMenuWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onPress;
  final Color? textColor;
  final bool endIcon;

  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    this.onPress,
    this.textColor,
    this.endIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Icon(icon, color: Color(0xFF5C001F)),
      title: Text(title, style: TextStyle(color: textColor ?? Colors.black)),
      trailing: endIcon ? const Icon(Icons.arrow_forward_ios, size: 18) : null,
    );
  }
}
