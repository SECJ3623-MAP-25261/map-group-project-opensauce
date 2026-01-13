import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Add this
import '../services/listing_services.dart';
import '../services/offline_queue_service.dart'; // Add this

class AddListingPage extends StatefulWidget {
  final String? listingId;
  final Map<String, dynamic>? existingData;

  const AddListingPage({super.key, this.listingId, this.existingData});

  @override
  State<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  // Services
  final ListingService _listingService = ListingService();
  final OfflineQueueService _offlineService = OfflineQueueService();

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _addressController;

  String _selectedCategory = 'Electronics';
  final List<String> _categories = [
    'Electronics',
    'Tools',
    'Sports',
    'Camping',
    'Party',
    'Others',
  ];

  List<String> _existingImageUrls = [];
  List<File> _newImageFiles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize Controllers with existing data if editing
    _titleController = TextEditingController(
      text: widget.existingData?['title'] ?? '',
    );
    _descController = TextEditingController(
      text: widget.existingData?['description'] ?? '',
    );
    _priceController = TextEditingController(
      text: widget.existingData?['pricePerDay']?.toString() ?? '',
    );
    _addressController = TextEditingController(
      text: widget.existingData?['address'] ?? '',
    );

    if (widget.existingData != null) {
      _selectedCategory = widget.existingData!['category'] ?? 'Electronics';
      _existingImageUrls = List<String>.from(
        widget.existingData!['images'] ?? [],
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // --- IMAGE PICKING ---
  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImageFiles.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImageFiles.removeAt(index);
    });
  }

  void _removeExistingImage(String url) {
    setState(() {
      _existingImageUrls.remove(url);
    });
  }

  // --- SUBMIT FORM (OFFLINE + ONLINE LOGIC) ---
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if images are present
    if (_newImageFiles.isEmpty && _existingImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one image")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1. Check Connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      bool isOffline = connectivityResult == ConnectivityResult.none;
      // Note: If using connectivity_plus ^6.0, use: connectivityResult.contains(ConnectivityResult.none)

      // 2. OFFLINE LOGIC (Only for New Items)
      if (isOffline) {
        if (widget.listingId != null) {
          // We generally don't support editing existing items offline
          // to avoid complex sync conflicts, but you can enable it if you wish.
          throw Exception("Cannot edit items while offline.");
        }

        // Convert File objects to path Strings for Hive
        List<String> imagePaths = _newImageFiles
            .map((file) => file.path)
            .toList();

        await _offlineService.queueItem(
          title: _titleController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          description: _descController.text.trim(),
          category: _selectedCategory,
          localImagePaths: imagePaths,
          userId: user.uid,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No Internet. Saved to 'Pending Uploads'."),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // 3. ONLINE LOGIC (Standard Upload)

        // This function should be inside your ListingService
        // It handles uploading images to Storage & data to Firestore
        await _listingService.addOrUpdateListing(
          listingId: widget.listingId,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _selectedCategory,
          address: _addressController.text.trim(),
          existingImageUrls: _existingImageUrls,
          newImageFiles: _newImageFiles,
          userId: user.uid,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Listing published successfully!")),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.listingId == null ? "Add New Listing" : "Edit Listing",
        ),
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Item Title",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Enter a title" : null,
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price per Day (RM)",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Enter a price" : null,
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Enter a description" : null,
              ),
              const SizedBox(height: 16),

              // Images Section
              Text("Images", style: _headerStyle()),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Add Button
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    // Existing Images (From Cloud)
                    ..._existingImageUrls.map(
                      (url) => _buildThumbnail(url: url),
                    ),
                    // New Images (From Local)
                    ..._newImageFiles.asMap().entries.map((entry) {
                      return _buildThumbnail(
                        file: entry.value,
                        index: entry.key,
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800000),
                  ),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.listingId == null
                              ? "Publish Listing"
                              : "Update Listing",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Thumbnails
  Widget _buildThumbnail({String? url, File? file, int? index}) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: url != null
                  ? NetworkImage(url)
                  : FileImage(file!) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              if (url != null) _removeExistingImage(url);
              if (file != null) _removeNewImage(index!);
            },
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _headerStyle() => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF800000),
  );
}
