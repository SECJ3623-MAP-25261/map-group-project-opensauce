import 'package:easyrent/features/rentee/data/dummy.dart';
import 'package:easyrent/features/rentee/profile_page.dart';
import 'package:flutter/material.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  // Controllers for editable fields
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();

  void _finishProfile() {
    // Save data to dummy
    setState(() {
      user1.phone = _phoneController.text;
      user1.address = _addressController.text;
      user1.faculty = _facultyController.text;
    });

    // Navigate to profile page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RenteeprofilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Complete Your Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile picture
            Stack(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(user1.profileImage, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              user1.fname + user1.lname,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(user1.role, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            // Editable info rows
            EditableInfoRow(label: "Phone", controller: _phoneController),
            EditableInfoRow(label: "Address", controller: _addressController),
            EditableInfoRow(label: "Faculty", controller: _facultyController),

            const SizedBox(height: 30),
            // Finish button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _finishProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 6,
                  shadowColor: Colors.grey.withOpacity(0.5),
                ),
                child: const Text(
                  "Finish",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Editable InfoRow
class EditableInfoRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const EditableInfoRow({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
