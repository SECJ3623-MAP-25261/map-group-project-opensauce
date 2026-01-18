import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for Analytics
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/listing_services.dart';
import '../services/offline_queue_service.dart';
import 'revenue_graph_popup.dart';

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
  final List<File> _newImageFiles = [];
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

  // ... (Keep existing _pickImages, _removeNewImage, _removeExistingImage methods) ...
  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImageFiles.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() => _newImageFiles.removeAt(index));
  }

  void _removeExistingImage(String url) {
    setState(() => _existingImageUrls.remove(url));
  }

  Future<void> _deleteListing() async {
    // 1. check internet
    final connectivityResult = await Connectivity().checkConnectivity();
    bool isOffline = connectivityResult == ConnectivityResult.none;
    // If using connectivity_plus ^6.0, use: connectivityResult.contains(ConnectivityResult.none)

    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Cannot delete while offline. Please connect to internet.",
          ),
        ),
      );
      return;
    }

    // 2. Show Confirmation Dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Listing?"),
        content: const Text(
          "This action cannot be undone. The item will be removed from the market immediately.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Delete
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return; // User cancelled

    // 3. Perform Deletion
    setState(() => _isLoading = true);
    try {
      await _listingService.deleteListing(widget.listingId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Listing deleted successfully")),
        );
        // Pop twice if needed (once for dialog - handled above, once for page)
        // Since we are not in the dialog anymore, just pop the page.
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

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
      final connectivityResult = await Connectivity().checkConnectivity();
      // Handle different connectivity_plus versions (some return List, some return single Enum)
      // Checks if 'none' is present in the result
      bool isOffline = connectivityResult == ConnectivityResult.none;
      // If you use connectivity_plus ^6.0.0, use: connectivityResult.contains(ConnectivityResult.none)

      if (isOffline) {
        // --- OFFLINE MODE (CREATE & UPDATE) ---
        List<String> imagePaths = _newImageFiles
            .map((file) => file.path)
            .toList();
            
        final Map<String, dynamic> itemData = {
          'title': _titleController.text.trim(),
          'pricePerDay': double.parse(_priceController.text.trim()), // Match DB field name
          'description': _descController.text.trim(),
          'category': _selectedCategory,
          'address': _addressController.text.trim(),
          // For updates, we pass existing images so they aren't lost
          'images': _existingImageUrls, 
        };

        if (widget.listingId != null) {
          // UPDATE
          await _offlineService.queueItem(
            action: 'update',
            docId: widget.listingId,
            data: itemData,
            userId: user.uid,
            localImagePaths: imagePaths,
          );
        } else {
          // CREATE
          // Normalize keys for create helper if needed, but our service uses 'data' map now
          // We passed 'pricePerDay' above which matches Firestore. 
          // Offline create helper expects a map to spread into Firestore.
          
          await _offlineService.queueItem(
            action: 'create',
            data: itemData,
            userId: user.uid,
            localImagePaths: imagePaths,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(
                widget.listingId == null 
                  ? "You are offline. Item saved to pending uploads." 
                  : "You are offline. Update saved to pending uploads.",
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
          Navigator.pop(context); // Close the page
        }
      } else {
        // --- ONLINE MODE ---
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
              // ---------------------------------------------------------
              // 1. ANALYTICS SECTION (ONLY SHOW IN EDIT MODE)
              // ---------------------------------------------------------
              if (widget.listingId != null)
                _buildAnalyticsCard(widget.listingId!),

              if (widget.listingId != null) const SizedBox(height: 20),
              // ---------------------------------------------------------

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

              // Category
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
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

              // Address (Added based on your previous file)
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Pickup Address",
                  border: OutlineInputBorder(),
                ),
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

              // Images
              Text("Images", style: _headerStyle()),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
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
                    ..._existingImageUrls.map(
                      (url) => _buildThumbnail(url: url),
                    ),
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

              // 2. NEW: DELETE BUTTON (Only in Edit Mode)
              if (widget.listingId != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _deleteListing,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      "Delete Listing",
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40), // Extra bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(String listingId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items')
          .doc(listingId)
          .snapshots(),
      builder: (context, itemSnapshot) {
        if (!itemSnapshot.hasData || !itemSnapshot.data!.exists) {
          return const SizedBox();
        }

        final itemData = itemSnapshot.data!.data() as Map<String, dynamic>;
        final int rentCount = (itemData['rentCount'] ?? 0).toInt();

        // Fetch Real Revenue
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('bookings')
              .where('itemId', isEqualTo: listingId)
              .where('status', isEqualTo: 'approved')
              .get(),
          builder: (context, bookingSnapshot) {
            double totalRevenue = 0.0;
            if (bookingSnapshot.hasData) {
              for (var doc in bookingSnapshot.data!.docs) {
                final bookingData = doc.data() as Map<String, dynamic>;
                totalRevenue += (bookingData['rentalPrice'] ?? 0).toDouble();
              }
            }

            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // --- HEADER ROW (Title + Graph Button) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.insights,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Performance",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      // --- THE NEW GRAPH BUTTON ---
                      IconButton(
                        icon: const Icon(
                          Icons.bar_chart_rounded,
                          color: Color(0xFF800000),
                        ),
                        tooltip: "View Graph",
                        onPressed: () {
                          // Show the popup
                          showDialog(
                            context: context,
                            builder: (c) =>
                                RevenueGraphPopup(itemId: listingId),
                          );
                        },
                      ),
                    ],
                  ),

                  const Divider(height: 20),

                  // --- STATS ROW ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        "Total Revenue",
                        "RM ${totalRevenue.toStringAsFixed(2)}",
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.green.shade200,
                      ),
                      _buildStatItem("Times Rented", "$rentCount"),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper for text layout
  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.green.shade700),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // --- EXISTING HELPERS ---
  TextStyle _headerStyle() => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF800000),
  );

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
}
