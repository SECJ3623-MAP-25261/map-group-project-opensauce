import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Import this
import 'package:intl/intl.dart';
import '../models/cart_model.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final bool isSelected;
  final Function(bool?) onSelected;
  final VoidCallback onDelete;
  final VoidCallback onEditDates;

  const CartItemCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onSelected,
    required this.onDelete,
    required this.onEditDates,
  });

  @override
  Widget build(BuildContext context) {
    String dateString =
        "${DateFormat('dd MMM').format(item.startDate)} - ${DateFormat('dd MMM').format(item.endDate)}";

    // 1. WRAP IN SLIDABLE
    return Slidable(
      key: Key(item.cartDocId),

      // The "Drawer" that appears when you swipe LEFT
      endActionPane: ActionPane(
        motion: const ScrollMotion(), // The animation style
        extentRatio: 0.25, // How much space the button takes (25% of width)
        children: [
          SlidableAction(
            onPressed: (context) => onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12), // Match card roundness
            // spacing: 2,
          ),
        ],
      ),

      // 2. YOUR EXISTING CARD UI (Clean, no trash icon visible initially)
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: isSelected,
                activeColor: const Color(0xFF800000),
                onChanged: onSelected,
              ),

              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: item.image.isNotEmpty
                      ? Image.network(item.image, fit: BoxFit.cover)
                      : const Icon(Icons.inventory_2, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
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
                    Row(children: [
                      Text(
                        "RM ${item.pricePerDay}/day",
                        style: const TextStyle(
                          color: Color(0xFF800000),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Text(
                      //   "${item.rentCount} rents"
                      // )
                    ],),
                    const SizedBox(height: 6),

                    // Date Edit Row
                    InkWell(
                      onTap: onEditDates,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                "$dateString (${item.days} Days)",
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.edit,
                              size: 14,
                              color: Color(0xFF800000),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
