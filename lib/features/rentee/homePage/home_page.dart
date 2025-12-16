import 'package:easyrent/features/rentee/renting_status/presentation/pages/renting_status_page.dart';
import 'package:flutter/material.dart';
import 'list_widget.dart';
import '../searchPage/search_page.dart';
import '../services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 10),
            SearchBarWidget(),
            SizedBox(height: 20),
            CategoriesWidget(),
            SizedBox(height: 20),
            BannerWidget(),
            SizedBox(height: 20),
            ProductSectionWidget(
              title: "Top Rated Product",
              isYellowBackground: true,
            ),
            SizedBox(height: 10),
            ProductSectionWidget(
              title: "Featured items",
              isYellowBackground: false,
            ),
            SizedBox(height: 10),
            ProductSectionWidget(
              title: "Recently viewed",
              isYellowBackground: false,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(60);
  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isUploading = false;

  Future<void> _uploadSampleProducts() async {
    setState(() {
      _isUploading = true;
    });

    try {
      await DatabaseService().uploadSampleProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sample products uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 20,
      title: Image.asset(
        "assets/images/Overlay.png",
        height: 25,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        errorBuilder:
            (context, error, stackTrace) => const Text(
              "EasyRent",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
      actions: [
        // Upload Button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: const BoxDecoration(
            color: Color(0xFFFFC107),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _isUploading ? null : _uploadSampleProducts,
            icon:
                _isUploading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFF5C001F),
                        strokeWidth: 2,
                      ),
                    )
                    : const Icon(Icons.cloud_upload, color: Color(0xFF5C001F)),
            tooltip: 'Upload Sample Products',
          ),
        ),
        // Shopping Cart Button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: const BoxDecoration(
            color: Color(0xFFFFC107),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RentingStatusPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF5C001F),
            ),
            tooltip: 'Renting Status',
          ),
        ),
        // Notifications Button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: const BoxDecoration(
            color: Color(0xFFFFC107),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              // Notification action
            },
            icon: const Icon(
              Icons.notifications_none,
              color: Color(0xFF5C001F),
            ),
            tooltip: 'Notifications',
          ),
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});
  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchPage()),
          );
        },
        child: Hero(
          tag: 'searchBar',
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 45,
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
              child: const TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoriesWidget extends StatefulWidget {
  const CategoriesWidget({super.key});

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.computer, 'label': 'Electronics'},
    {'icon': Icons.checkroom, 'label': 'Clothing'},
    {'icon': Icons.menu_book, 'label': 'Books'},
    {'icon': Icons.chair, 'label': 'Furniture'},
    {'icon': Icons.sports_tennis, 'label': 'Sports'},
    {'icon': Icons.directions_car, 'label': 'Vehicles'},
    {'icon': Icons.build, 'label': 'Tools'},
    {'icon': Icons.music_note, 'label': 'Music'},
    {'icon': Icons.gamepad, 'label': 'Gaming'},
    {'icon': Icons.camera_alt, 'label': 'Cameras'},
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            child: Container(
              width: 65,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? const Color(0xFF5C001F)
                        : const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 24,
                    color: isSelected ? Colors.white : const Color(0xFF5C001F),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});
  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              "assets/images/image 1462.png",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: Text("Banner Image Not Found")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
