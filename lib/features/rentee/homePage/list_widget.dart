import 'package:flutter/material.dart';
import '../productDetails/product_details_page.dart';
import '../productList/product_list_page.dart';
import '../data/dummy_data.dart';

class ProductSectionWidget extends StatefulWidget {
  final String title;
  final bool isYellowBackground;
  final bool isRecentlyViewed;

  const ProductSectionWidget({
    super.key,
    required this.title,
    this.isYellowBackground = false,
    this.isRecentlyViewed = false,
  });

  @override
  State<ProductSectionWidget> createState() => _ProductSectionWidgetState();
}

class _ProductSectionWidgetState extends State<ProductSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          widget.isYellowBackground
              ? const Color(0xFFFFC107)
              : Colors.transparent,
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProductListPage(title: widget.title),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 270,
            child: ListView.separated(
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: dummyProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 15),
              itemBuilder: (context, index) {
                return ProductCard(product: dummyProducts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Center(
                    child: SizedBox(
                      height: 130,
                      width: 130,
                      child: Image.network(
                        product['image'],
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                product['product_name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                product['price'].toString(),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 5),
                  Text(
                    product['rating'].toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
