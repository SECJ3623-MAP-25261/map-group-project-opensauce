import 'package:flutter/material.dart';
import '../../../features/models/item.dart';
import '../../../features/rentee/services/database_service.dart';
import '../productDetails/product_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  final List<String> _searchHistory = [
    'Headphones',
    'Camera',
    'Laptop',
    'Console',
    'Chair',
  ];
  final List<String> _recommendations = [
    'Gaming Console',
    'Drone',
    'Smart Watch',
    'Camera',
    'Books',
  ];
  List<Item> _allItems = [];
  List<Item> _filteredItems = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllItems();
  }

  Future<void> _loadAllItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all items from Firestore
      final snapshot = await _dbService.getProducts().first;
      setState(() {
        _allItems = snapshot;
        _filteredItems = snapshot;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading items: $e');
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;

      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems =
            _allItems.where((item) {
              return item.productName.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  item.description.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  item.deliveryMethods.toLowerCase().contains(
                    query.toLowerCase(),
                  );
            }).toList();
      }

      // Add to search history if not already present and query is not empty
      if (query.isNotEmpty && !_searchHistory.contains(query)) {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      }
    });
  }

  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _performSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Hero(
                      tag: 'searchBar',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 15),
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    hintText: "Search products...",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: _performSearch,
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: _clearSearch,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Results/Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Results Count
                    if (_searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          '${_filteredItems.length} results for "$_searchQuery"',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    // Search Results Grid
                    if (_searchQuery.isNotEmpty) _buildSearchResults(),

                    // When no search query, show history and recommendations
                    if (_searchQuery.isEmpty) ...[
                      // Search History
                      _buildSectionHeader(
                        title: 'Search History',
                        trailing: IconButton(
                          onPressed: _clearSearchHistory,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTags(_searchHistory),
                      const SizedBox(height: 30),

                      // Recommendations
                      _buildSectionHeader(
                        title: 'Recommendations',
                        trailing: null,
                      ),
                      const SizedBox(height: 10),
                      _buildTags(_recommendations),
                      const SizedBox(height: 30),

                      // Discover Section
                      _buildSectionHeader(
                        title: 'Discover',
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                      const SizedBox(height: 15),
                      _buildDiscoverGrid(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildTags(List<String> tags) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: tags.map((tag) => _buildChip(tag)).toList(),
    );
  }

  Widget _buildChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _performSearch(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 50),
          child: CircularProgressIndicator(color: Color(0xFF5C001F)),
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 15),
            Text(
              'No results found for "$_searchQuery"',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              'Try different keywords',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildProductCard(item);
      },
    );
  }

  Widget _buildDiscoverGrid() {
    // Show first 6 items for discover section
    final discoverItems =
        _allItems.length > 6 ? _allItems.sublist(0, 6) : _allItems;

    if (discoverItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Text(
            'No products available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: discoverItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        final item = discoverItems[index];
        return _buildProductCard(item);
      },
    );
  }

  Widget _buildProductCard(Item item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                        color: const Color(0xFF5C001F),
                      ),
                    );
                  },
                  errorBuilder:
                      (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                ),
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Price
                  Text(
                    "RM ${item.pricePerDay.toStringAsFixed(0)}/day",
                    style: const TextStyle(
                      color: Color(0xFF5C001F),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFFFC107),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${item.averageRating}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
