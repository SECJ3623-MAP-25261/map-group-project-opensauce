import 'dart:typed_data'; // For web image handling
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  Uint8List? _imageBytes; // Store image data (works for Web & Mobile)
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _currentPhotoUrl = user.photoURL;

      // Fetch Phone Number from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        _phoneController.text = doc.data()?['phoneNumber'] ?? '';
      }
      setState(() {});
    }
  }

  // --- PICK IMAGE ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  // --- SAVE PROFILE ---
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Show loading spinner

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String? newPhotoUrl = _currentPhotoUrl;

      // --- STEP 1: UPLOAD LOCAL IMAGE TO FIREBASE STORAGE ---
      if (_imageBytes != null) {
        // 1. Create a reference to where the file will live
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_profiles') // Folder name
            .child('${user.uid}.jpg'); // File name (using UID keeps it unique)

        // 2. Upload the raw data (works for Web & Mobile)
        // This takes the image from your local variable and sends it to the cloud
        await storageRef.putData(_imageBytes!);

        // 3. Get the Download URL
        newPhotoUrl = await storageRef.getDownloadURL();
      }

      // --- STEP 2: UPDATE AUTH PROFILE ---
      // This updates the user's "global" Firebase profile
      await user.updateDisplayName(_nameController.text.trim());
      if (newPhotoUrl != null) {
        await user.updatePhotoURL(newPhotoUrl);
      }

      // --- STEP 3: UPDATE FIRESTORE DOCUMENT ---
      // This saves the URL string to your database field 'profileImage'
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'displayName': _nameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          // Only update the field if we actually have a new URL
          if (newPhotoUrl != null) 'profileImage': newPhotoUrl,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- IMAGE PICKER ---
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _imageBytes != null
                          ? MemoryImage(_imageBytes!) // Show picked image
                          : (_currentPhotoUrl != null
                                ? NetworkImage(_currentPhotoUrl!)
                                      as ImageProvider
                                : null),
                      child: (_imageBytes == null && _currentPhotoUrl == null)
                          ? const Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF800000),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- FIELDS ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) =>
                    val!.isEmpty ? "Name cannot be empty" : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 40),

              // --- SAVE BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
