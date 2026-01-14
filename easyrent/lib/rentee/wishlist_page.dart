import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'item_details_page.dart'; // To navigate back to item if clicked

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  // Stores the IDs of items selected for removal
  final Set<String> _selectedItemIds = {};
  bool _isDeleting = false;

  void _toggleSelection(String docId, bool selected) {
    setState(() {
      if (selected) {
        _selectedItemIds.add(docId);
      } else {
        _selectedItemIds.remove(docId);
      }
    });
  }

  Future<void> _deleteSelected() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedItemIds.isEmpty) return;

    setState(() => _isDeleting = true);

    final batch = FirebaseFirestore.instance.batch();

    for (String docId in _selectedItemIds) {
      DocumentReference ref = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(docId); // docId in wishlist is usually the itemId itself
      batch.delete(ref);
    }

    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${_selectedItemIds.length} items removed")),
      );
      setState(() {
        _selectedItemIds.clear();
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please Login")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wishlist"),
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
        actions: [
          if (_selectedItemIds.isNotEmpty)
            IconButton(
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.delete),
              onPressed: _isDeleting ? null : _deleteSelected,
              tooltip: "Remove Selected",
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('wishlist')
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Your wishlist is empty",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String itemId = docs[index].id;
              final bool isSelected = _selectedItemIds.contains(itemId);

              return Card(
                child: ListTile(
                  leading: Checkbox(
                    activeColor: const Color(0xFF800000),
                    value: isSelected,
                    onChanged: (val) => _toggleSelection(itemId, val ?? false),
                  ),
                  title: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: data['image'] != ""
                            ? Image.network(
                                data['image'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[200],
                                child: const Icon(Icons.inventory_2),
                              ),
                      ),
                      const SizedBox(width: 10),
                      // Title & Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? "Unknown",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "RM ${data['price']}/day",
                              style: const TextStyle(
                                color: Color(0xFF800000),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    // Navigate to details if they tap the card body
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetailsPage(
                          // reconstruct basic map for details page
                          itemData: {
                            'title': data['title'],
                            'pricePerDay': data['price'],
                            'images': [data['image']],
                            'description':
                                data['description'] ??
                                'Check details for more info...',
                            'userId':
                                data['ownerId'] ??
                                '', // needed for owner section
                          },
                          docId: itemId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
