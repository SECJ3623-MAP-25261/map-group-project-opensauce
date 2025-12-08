import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart'; 
import '../../../../models/item.dart'; 
import '../../services/notifier/listing_notifier.dart';

class RenterAddItem extends StatefulWidget {
  const RenterAddItem({super.key});

  @override
  State<RenterAddItem> createState() => _RenterAddItemState();
}

class _RenterAddItemState extends State<RenterAddItem> {
  // --- CONTROLLERS ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedCategory;
  final List<String> _categories = ['Electronic', 'Stationary', 'Clothing', 'Sports', 'Other'];

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  
  int _currentImageIndex = 0; 
  final PageController _pageController = PageController();
  
  bool _isSaving = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only upload up to 5 images.")),
      );
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
          _currentImageIndex = _selectedImages.length - 1;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(_currentImageIndex);
            }
          });
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<String> _uploadImage(File imageFile, String folderName) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('$folderName/$fileName.jpg');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      throw Exception("Image upload failed");
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
      _selectedImages.removeAt(_currentImageIndex);
      if (_currentImageIndex >= _selectedImages.length && _currentImageIndex > 0) {
        _currentImageIndex = _selectedImages.length - 1;
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

  void _movePage(int delta) {
    _pageController.animateToPage(
      _currentImageIndex + delta,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _saveItem() async {
    if (_nameController.text.isEmpty || 
        _priceController.text.isEmpty || 
        _depositController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload at least 1 image")),
      );
      return;
    }

    setState(() { _isSaving = true; });

    try {
      List<String> uploadedUrls = [];
      for (File img in _selectedImages) {
        String url = await _uploadImage(img, 'item_images');
        uploadedUrls.add(url);
      }

      String mainImageUrl = uploadedUrls[0];
      List<String> additionalImages = [];
      if (uploadedUrls.length > 1) {
        additionalImages = uploadedUrls.sublist(1);
      }

      final newItem = Item(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ownerId: "temp",
        ownerName: "temp",
        ownerImage: "temp",
        
        productName: _nameController.text,
        pricePerDay: double.tryParse(_priceController.text) ?? 0.0,
        deposit: double.tryParse(_depositController.text) ?? 0.0,
        
        description: _descriptionController.text,
        category: _selectedCategory ?? "Other",        
        imageUrl: mainImageUrl,
        imageUrls: additionalImages,
        location: _depositController.text,
        quantity: 1,
        rentingDuration: "Daily",
        deliveryMethods: "Pickup",
        averageRating: 0.0,
        reviews: [],
        currentRenterId: null,
      );

      if (!mounted) return;
      await Provider.of<ListingNotifier>(context, listen: false).addItem(newItem);

      if (mounted) Navigator.pop(context);

    } catch (e) {
      print("Error saving: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving item: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSaving = false; });
      }
    }
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
        title: const Text("Add Item", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
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
                      child: _selectedImages.isEmpty
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
                              itemCount: _selectedImages.length,
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return Image.file(
                                  _selectedImages[index],
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                    ),
                  ),
                  if (_currentImageIndex > 0)
                    Positioned(
                      left: 10,
                      child: GestureDetector(
                        onTap: () => _movePage(-1),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                          child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
                        ),
                      ),
                    ),
                  if (_currentImageIndex < _selectedImages.length - 1)
                    Positioned(
                      right: 10,
                      child: GestureDetector(
                        onTap: () => _movePage(1),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                          child: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black87),
                        ),
                      ),
                    ),
                  if (_selectedImages.isNotEmpty)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                        child: Text("${_currentImageIndex + 1} / ${_selectedImages.length}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: InkWell(
                      onTap: _showImagePickerOptions,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFF5C001F), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  if (_selectedImages.isNotEmpty)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: InkWell(
                        onTap: _confirmDelete, 
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
                          child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // FIELDS
            _buildLabel("Name"),
            _buildTextField(controller: _nameController, hint: "Insert here"),
            _buildLabel("Category"),
            _buildDropdown(),
            _buildLabel("Price"),
            _buildTextField(controller: _priceController, hint: "e.g: 10", suffix: "RM/day", inputType: TextInputType.number),
            _buildLabel("Deposit"),
            _buildTextField(controller: _depositController, hint: "e.g: 20", inputType: TextInputType.number),
            _buildLabel("Description"),
            _buildTextField(controller: _descriptionController, hint: "Insert here", maxLines: 5),
            _buildLabel("Location"),
            _buildTextField(controller: _locationController, hint: "Location"),
            const SizedBox(height: 30),
            // BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _saveItem,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF5C001F)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFF5C001F), strokeWidth: 2)) : const Text("SAVE", style: TextStyle(color: Color(0xFF5C001F), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
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

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0, top: 12.0), child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.black87)));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, String? suffix, int maxLines = 1, TextInputType? inputType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: inputType ?? TextInputType.text,
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