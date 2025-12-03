class RentalItem {
  final String id;
  final String name;             // Changed from 'title' to match your UI label
  final List<String> imageUrls;  // Changed to List because of "1/5"
  final String category;         // For the dropdown
  final double pricePerDay;      // "Price"
  final double deposit;          // New field from Edit Page
  final String description;      // New field from Edit Page
  final String location;         // New field from Edit Page
  final double rating;           // Kept from the first screen (stars)

  RentalItem({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.category,
    required this.pricePerDay,
    required this.deposit,
    required this.description,
    required this.location,
    required this.rating,
  });
}