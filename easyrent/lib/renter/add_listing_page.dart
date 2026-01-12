import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/listing_services.dart'; // Ensure this matches your file name

class AddListingPage extends StatefulWidget {
  final String? listingId;
  final Map<String, dynamic>? existingData;

  const AddListingPage({super.key, this.listingId, this.existingData});

  @override
  State<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  // 1. INSTANTIATE SERVICE
  final ListingService _listingService = ListingService();

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
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // LOGIC: Setup form
  Future<void> _initializeData() async {
    final data = widget.existingData;
    _titleController = TextEditingController(text: data?['title'] ?? '');
    _descController = TextEditingController(text: data?['description'] ?? '');
    _priceController = TextEditingController(
      text: data?['pricePerDay']?.toString() ?? '',
    );
    _addressController = TextEditingController(text: data?['address'] ?? '');

    if (data != null) {
      setState(() {
        _selectedCategory = data['category'] ?? 'Electronics';
        _existingImageUrls = List<String>.from(data['images'] ?? []);
        _isAvailable = data['isAvailable'] ?? true;
      });
    } else {
      // Use Service to get address for NEW items
      final defaultAddr = await _listingService.getRenterDefaultAddress();
      if (mounted && defaultAddr != null) {
        setState(() => _addressController.text = defaultAddr);
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_existingImageUrls.isEmpty && _newImageFiles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Add at least one image")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // A. Upload Images (Service handles the heavy lifting)
      final newUrls = await _listingService.uploadImages(_newImageFiles);

      final finalImages = [..._existingImageUrls, ...newUrls];

      // B. Save/Update Data via Service
      if (widget.listingId == null) {
        await _listingService.addListing(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _selectedCategory,
          address: _addressController.text.trim(),
          images: finalImages,
        );
      } else {
        await _listingService.updateListing(
          docId: widget.listingId!,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _selectedCategory,
          address: _addressController.text.trim(),
          images: finalImages,
          isAvailable: _isAvailable,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Success!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _listingService.deleteListing(widget.listingId!);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isLoading = false);
    }
  }

  // --- UI INTERACTION FUNCTIONS ---
  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(
        () => _newImageFiles.addAll(pickedFiles.map((x) => File(x.path))),
      );
    }
  }

  void _removeNewImage(int index) =>
      setState(() => _newImageFiles.removeAt(index));
  void _removeExistingImage(String url) =>
      setState(() => _existingImageUrls.remove(url));

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.listingId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Listing" : "List New Item"),
        backgroundColor: const Color(0xFF800000),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteItem,
              tooltip: "Delete Item",
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. PHOTOS SECTION ---
                    Text("Photos", style: _headerStyle()),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          InkWell(
                            onTap: _pickImages,
                            child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
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
                          ..._newImageFiles.asMap().entries.map(
                            (entry) => _buildThumbnail(
                              file: entry.value,
                              index: entry.key,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- 2. AVAILABILITY SWITCH (EDIT MODE ONLY) ---
                    if (isEditing) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: SwitchListTile(
                          title: const Text(
                            "Available for Rent",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            _isAvailable
                                ? "Item is visible in search"
                                : "Item is hidden",
                          ),
                          value: _isAvailable,
                          activeColor: const Color(0xFF800000),
                          onChanged: (val) =>
                              setState(() => _isAvailable = val),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // --- 3. FORM FIELDS ---
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: "Item Name"),
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField(
                      value: _selectedCategory,
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val.toString()),
                      decoration: const InputDecoration(labelText: "Category"),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: "Price (RM)",
                        prefixText: "RM ",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: "Pickup Address",
                      ),
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),

                    const SizedBox(height: 30),

                    // --- 4. SUBMIT BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF800000),
                        ),
                        child: Text(
                          isEditing ? "Save Changes" : "Publish Listing",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- HELPER UI WIDGETS ---
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
