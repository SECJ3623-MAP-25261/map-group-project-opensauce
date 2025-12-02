import '../../domain/entities/item_entity.dart';

final List<ItemEntity> dummyItems = [
  ItemEntity(
    id: "1",
    name: "TMA-2HD Wireless",
    price: '20.0',
    rentalInfo: "2 days | Total RM 40",
    imageUrl: "assets/headphone.jpg",
    // added
    description: "High quality wireless headphones.",
    location: "KDSE",
    rating: 4.5,
    additionalImages: ["assets/camera.jpg"], 
  ),
  ItemEntity(
    id: "2",
    name: "Canon EOS R5",
    price: '80.0',
    rentalInfo: "1 day | Total RM 80",
    imageUrl: "assets/camera.jpg",
    description: "Professional camera for rent.",
    location: "KDOJ",
    rating: 4.8,
    additionalImages: ["assets/headphone.jpg"],
  ),
];