import 'package:easyrent/features/account/auth/login_page.dart';
import 'package:easyrent/features/account/registration/renter_registration.dart';
import '../../data/dummy_data/dummy.dart';
import '../../../presentation/widgets/rentee_bottom_navbar.dart';
import 'my_profile_page.dart';
import 'package:flutter/material.dart';

// rentee profile page (Zhen Yang)
class RenteeprofilePage extends StatefulWidget {
  const RenteeprofilePage({super.key});

  @override
  State<RenteeprofilePage> createState() => _RenteeprofilePageState();
}

class _RenteeprofilePageState extends State<RenteeprofilePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // BODY
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // PROFILE IMAGE
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        user1.profileImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                user1.fname + user1.lname,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(user1.role, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              // SWITCH BUTTON
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RenteeprofilePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF8BE17),
                    shape: const StadiumBorder(),
                    elevation: 6,
                    shadowColor: Colors.grey.withOpacity(0.5),
                  ),
                  child: const Text(
                    "Switch to Renter",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // BECOME A RENTER BUTTON
              SizedBox(
                width: 250, // bigger than switch button
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RenterRegistrationPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C001F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    shadowColor: Colors.grey.withOpacity(0.5),
                  ),
                  child: const Text(
                    "Become a Renter",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              const Divider(),

              // MENU SECTIONS
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const LoginPage(),
                                  ),
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

      bottomNavigationBar: RenteeBottomNavBar(),
    );
  }
}

// REUSABLE MENU WIDGET
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

//log out route
