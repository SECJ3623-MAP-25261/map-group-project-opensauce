import 'package:flutter/material.dart';
import '../../../renter_management/domain/entities/item_entity.dart';
import 'edit_item.dart';

class RenterItemDetail extends StatefulWidget {
  final ItemEntity item;

  const RenterItemDetail({super.key, required this.item});

  @override
  State<RenterItemDetail> createState() => _RenterItemDetailState();
}

class _RenterItemDetailState extends State<RenterItemDetail> {
  int _currentImageIndex = 0;

  // --- DELETE CONFIRMATION ---
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Are you sure you want to delete this listing permanently?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Call Notifier.deleteItem(widget.item.id) here later
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to Listing Page
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3. PARSE PRICE SAFELY (String -> Double)
    final double priceVal = double.tryParse(widget.item.price) ?? 0.0;

    // 4. PREPARE IMAGES (Handle case where additionalImages might be empty)
    // If additionalImages has items, use them. Otherwise, make a list with just the main image.
    final List<String> displayImages = widget.item.additionalImages.isNotEmpty
        ? widget.item.additionalImages
        : [widget.item.imageUrl];

    return Scaffold(
      backgroundColor: Colors.white,
      
      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Product",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),

      // BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // --- IMAGE CAROUSEL ---
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: PageView.builder(
                      itemCount: displayImages.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          displayImages[index],
                          fit: BoxFit.contain, // Fixed zoom issue
                          errorBuilder: (context, error, stackTrace) => 
                              const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                ),
                
                // Indicator
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${_currentImageIndex + 1} / ${displayImages.length}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // --- TITLE & PRICE SECTION ---
            Center(
              child: Column(
                children: [
                  Text(
                    widget.item.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "RM ${priceVal.toStringAsFixed(0)} per day", // Use parsed price
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  // Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.item.rating}", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(0 Reviews)", // Hardcoded for now
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 24),

            // --- DESCRIPTION SECTION ---
            const Text(
              "Description Product",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
            ),
            const SizedBox(height: 12),
            Text(
              widget.item.description,
              style: const TextStyle(fontSize: 14, color: Color(0xFF667085), height: 1.5),
            ),
            
            const SizedBox(height: 40),

            // --- ACTION BUTTONS ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // Pass the ItemEntity to Edit Page
                          builder: (context) => RenterEditItem(item: widget.item),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF5C001F)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "EDIT",
                      style: TextStyle(color: Color(0xFF5C001F), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirmDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C001F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "DELETE",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
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
}