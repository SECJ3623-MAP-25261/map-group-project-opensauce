import 'package:easyrent/features/rentee/data/dummy.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controllers for each field
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _facultyController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user info
    _nameController = TextEditingController(text: user1.fname);
    _nameController = TextEditingController(text: user1.lname);
    _emailController = TextEditingController(text: user1.email);
    _phoneController = TextEditingController(text: user1.phone);
    _addressController = TextEditingController(text: user1.address);
    _facultyController = TextEditingController(text: user1.faculty);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _facultyController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Update dummy user data
    setState(() {
      user1.fname = _nameController.text;
      user1.lname = _nameController.text;
      user1.email = _emailController.text;
      user1.phone = _phoneController.text;
      user1.address = _addressController.text;
      user1.faculty = _facultyController.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully!")),
    );

    Navigator.pop(context); // Return to profile page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                elevation: 4,
              ),
              child: const Text(
                "Done",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Editable InfoRows
            EditableInfoRow(label: "Name", controller: _nameController),
            EditableInfoRow(label: "Email", controller: _emailController),
            EditableInfoRow(label: "Phone", controller: _phoneController),
            EditableInfoRow(label: "Address", controller: _addressController),
            EditableInfoRow(label: "Faculty", controller: _facultyController),
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
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18, 
            color: Colors.black,
          ),
        ),
        subtitle: TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true, // smaller vertical padding
          ),
        ),
      ),
    );
  }
}
