import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/rentee_service.dart';
import '../rentee/item_details_page.dart';

class RenteeItemCard extends StatelessWidget {
  final ItemModel item;
  final RenteeService _service = RenteeService();

  RenteeItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // --- THE FIX ---
        // 1. Force the keyboard to close / cursor to stop blinking
        FocusManager.instance.primaryFocus?.unfocus();

        // 2. Wait a tiny bit for the "unfocus" event to finish processing
        // This prevents the focus from "sticking" when you come back.
        await Future.delayed(const Duration(milliseconds: 100));

        // 3. Navigate (Check if context is still valid after delay)
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ItemDetailsPage(docId: item.id, itemData: item.toMap()),
            ),
          );
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE & HEART ICON ---
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      color: Colors.grey[200],
                      image: item.firstImage != null
                          ? DecorationImage(
                              image: NetworkImage(item.firstImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: item.firstImage == null
                        ? const Icon(Icons.image, size: 50, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StreamBuilder<bool>(
                      stream: _service.isItemWishlisted(item.id),
                      builder: (context, snapshot) {
                        final isWishlisted = snapshot.data ?? false;
                        return GestureDetector(
                          onTap: () => _service.toggleWishlist(item),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isWishlisted ? Colors.red : Colors.grey,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // --- TEXT INFO ---
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "RM ${item.pricePerDay}/day",
                    style: const TextStyle(
                      color: Color(0xFF800000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
