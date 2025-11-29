import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/renter_item.dart';

class RenterEditItem extends StatefulWidget {
  final RentalItem item;

  const RenterEditItem({super.key, required this.item});

  @override
  State<RenterEditItem> createState() => _RenterEditItemState();
}

class _RenterEditItemState extends State<RenterEditItem> {
  // --- CONTROLLERS ---
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _depositController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  String? _selectedCategory;
  final List<String> _categories = ['Electronic', 'Stationary', 'Clothing', 'Sports', 'Other'];

  // --- IMAGE STATE ---
  final List<dynamic> _itemImages = []; 
  final ImagePicker _picker = ImagePicker();
  
  int _currentImageIndex = 0; 

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(text: widget.item.pricePerDay.toStringAsFixed(0));
    _depositController = TextEditingController(text: widget.item.deposit.toStringAsFixed(0));
    _descriptionController = TextEditingController(text: widget.item.description);
    _locationController = TextEditingController(text: widget.item.location);
    
    if (_categories.contains(widget.item.category)) {
      _selectedCategory = widget.item.category;
    }

    _itemImages.addAll(widget.item.imageUrls);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // --- IMAGE LOGIC ---
  Future<void> _pickImage(ImageSource source) async {
    if (_itemImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only upload up to 5 images.")),
      );
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          // Add as File
          _itemImages.add(File(pickedFile.path));
          _currentImageIndex = _itemImages.length - 1;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Image"),
        content: const Text("Are you sure you want to remove this image?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteImage();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteImage() {
    setState(() {
      _itemImages.removeAt(_currentImageIndex);
      
      if (_currentImageIndex >= _itemImages.length && _currentImageIndex > 0) {
        _currentImageIndex = _itemImages.length - 1;
      }
    });
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        // 4. CHANGED TITLE
        title: const Text("Edit Item", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // --- IMAGE CAROUSEL SECTION ---
            Center(
              child: Stack(
                children: [
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _itemImages.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined, size: 50, color: Colors.grey),
                                  SizedBox(height: 10),
                                  Text("No image uploaded", style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          : PageView.builder(
                              itemCount: _itemImages.length,
                              controller: PageController(initialPage: _currentImageIndex), 
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final image = _itemImages[index];
                                
                                if (image is File) {
                                  return Image.file(image, fit: BoxFit.cover);
                                } else if (image is String) {
                                  return Image.network(
                                    image, 
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                    ),
                  ),

                  if (_itemImages.isNotEmpty)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${_currentImageIndex + 1} / ${_itemImages.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: InkWell(
                      onTap: _showImagePickerOptions,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C001F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ),

                  if (_itemImages.isNotEmpty)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: InkWell(
                        onTap: _confirmDelete, 
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9), 
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                            ]
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                        ),
                      ),
                    ),

                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // --- FORM FIELDS ---
            _buildLabel("Name"),
            _buildTextField(controller: _nameController, hint: "Insert here"),
            _buildLabel("Category"),
            _buildDropdown(),
            _buildLabel("Price"),
            _buildTextField(controller: _priceController, hint: "e.g: 10", suffix: "RM/day"),
            _buildLabel("Deposit"),
            _buildTextField(controller: _depositController, hint: "e.g: 20"),
            _buildLabel("Description"),
            _buildTextField(controller: _descriptionController, hint: "Insert here", maxLines: 5),
            _buildLabel("Location"),
            _buildTextField(controller: _locationController, hint: "Location"),
            const SizedBox(height: 30),

            // --- BUTTONS ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Add Update Logic Here
                      print("Updating Item: ${_nameController.text}");
                      print("Images count: ${_itemImages.length}");
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF5C001F)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("UPDATE", style: TextStyle(color: Color(0xFF5C001F), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C001F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text("CANCEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
      child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.black87)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, String? suffix, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF5C001F))),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          hint: const Text("Select Category", style: TextStyle(color: Colors.grey)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: _categories.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
          onChanged: (newValue) => setState(() => _selectedCategory = newValue),
        ),
      ),
    );
  }
}