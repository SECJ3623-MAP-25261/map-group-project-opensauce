import '../../domain/entities/item_entity.dart';

final List<ItemEntity> dummyItems = [
  ItemEntity(
    id: "1",
    name: "TMA-2HD Wireless",
    price: '20.0',
    rentalInfo: "2 days | Total RM 40",
    imageUrl: "assets/headphone.jpg",
    // added
    deposit: '20.0',
    description: "High quality wireless headphones.",
    location: "KDSE",
    rating: 4.5,
    additionalImages: ["assets/headphone.jpg"], 
  ),
  ItemEntity(
    id: "2",
    name: "Canon EOS R5",
    price: '80.0',
    rentalInfo: "1 day | Total RM 80",
    imageUrl: "assets/camera.jpg",
    deposit: '30.0',
    description: "Professional camera for rent.",
    location: "KDOJ",
    rating: 4.8,
    additionalImages: ["assets/camera.jpg", "assets/camera1.jpg"],
  ),
];