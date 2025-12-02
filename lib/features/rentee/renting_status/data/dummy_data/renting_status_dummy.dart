// dummy data for renting status 
// Ordering, In Renting, History 

const List<Map<String, dynamic>> userOrdering = [
  {
    "id": "ODR_001",
    "product_name": "4K Action Camera Pro",
    "price_per_day": 15.00,
    "star_rating": "4.8",
    "returnDate": "21/8/2025 11:59pm",
    "orderDate": 1,
    "quantity": 1,
    "totalPrice": 100.0,
    "deliveryMethods": 'Self-Pickup',
    "imageUrl": "https://store.sony.com.my/cdn/shop/files/PS5PRO_PR_01_CMYK_1200x.jpg?v=1727246715"
  },

  {
    "id": "ODR_002",
    "product_name": "Velvet Matte Lipstick (Cherry Red)",
    "price_per_day": 5.00,
    "star_rating": "4.5",
    "returnDate": "05/9/2025 10:00am",
    "orderDate": 2,
    "quantity": 1,
    "totalPrice": 20.0,
    "deliveryMethods": 'Self-Pickup',
    "imageUrl": "https://store.sony.com.my/cdn/shop/files/PS5PRO_PR_01_CMYK_1200x.jpg?v=1727246715"
  },

  {
    "id": "ODR_003",
    "product_name": "Electric Scooter X90",
    "price_per_day": 45.00,
    "star_rating": "4.9",
    "returnDate": "15/9/2025 08:00pm",
    "orderDate": 3,
    "quantity": 1,
    "totalPrice": 315.0,
    "deliveryMethods": 'Self-Pickup',
    "imageUrl": "https://store.sony.com.my/cdn/shop/files/PS5PRO_PR_01_CMYK_1200x.jpg?v=1727246715"
  },

  {
    "id": "ODR_004",
    "product_name": "Portable Projector Mini P5",
    "price_per_day": 20.00,
    "star_rating": "4.2",
    "returnDate": "01/10/2025 05:00pm",
    "orderDate": 4,
    "quantity": 1,
    "totalPrice": 60.0,
    "deliveryMethods": 'Self-Pickup',
    "imageUrl": "https://store.sony.com.my/cdn/shop/files/PS5PRO_PR_01_CMYK_1200x.jpg?v=1727246715"
  },

  {
    "id": "ODR_005",
    "product_name": "Professional DSLR Lens (50mm)",
    "price_per_day": 30.00,
    "star_rating": "5.0",
    "returnDate": "10/10/2025 11:00am",
    "orderDate": 5,
    "quantity": 1,
    "totalPrice": 150.0,
    "deliveryMethods": 'Self-Pickup',
    "imageUrl": "https://store.sony.com.my/cdn/shop/files/PS5PRO_PR_01_CMYK_1200x.jpg?v=1727246715"
  },

  {
    "id": "ODR_006",
    "product_name": "Camping Tent (4-Person)",
    "price_per_day": 10.00,
    "star_rating": "4.0",
    "returnDate": "25/10/2025 03:00pm",
    "orderDate": 6,
    "quantity": 1,
    "totalPrice": 40.0,
    "deliveryMethods": 'Self-Pickup',
    "imageUrl": "https://store.sony.com.my/cdn/shop/files/PS5PRO_PR_01_CMYK_1200x.jpg?v=1727246715"
  },
];

const List<Map<String, dynamic>> userInRenting = [
  // ... (RNT_001 and RNT_002 from previous context)
  {
    "id": "RNT_001",
    "product_name": "Professional DSLR Lens (50mm)",
    "price_per_day": 30.00,
    "star_rating": "5.0",
    "imageUrl": "https://hnsgsfp.imgix.net/9/images/detailed/25/Canon_EOS_1500D_Digital_Camera___EF-S_18-55mm_III_Lens_-_Black.png?fit=fill&bg=0FFF&w=1600&h=900&auto=format,compress",
    "totalPrice": 150.0,
    "startDate": "15/11/2025 10:00am",
    "dueDate": "20/12/2025 10:00am",
    "daysRemaining": 21,
    "currentStatus": "In Use",
    "deliveryMethods": 'Self-Pickup',
    "returnMethod": "Prepaid Courier Pickup",
    "dropoffLocation": "N/A (Pickup scheduled)",
  },
  {
    "id": "RNT_002",
    "product_name": "Electric Scooter X90",
    "price_per_day": 45.00,
    "star_rating": "4.9",
    "imageUrl": "https://hnsgsfp.imgix.net/9/images/detailed/25/Canon_EOS_1500D_Digital_Camera___EF-S_18-55mm_III_Lens_-_Black.png?fit=fill&bg=0FFF&w=1600&h=900&auto=format,compress",
    "deliveryMethods": 'Self-Pickup',

    "totalPrice": 315.0,
    "startDate": "01/11/2025 08:00pm",
    "dueDate": "15/11/2025 08:00pm",
    "daysRemaining": 0,
    "currentStatus": "Overdue (3 Days)",
    "returnMethod": "Self Drop-off",
    "dropoffLocation": "Kuala Lumpur Central Hub, Lot 10",
  },
  
  // --- Dummy Data Entry 3: Camping Tent (Short-term rental) ---
  {
    "id": "RNT_003",
    "product_name": "Camping Tent (4-Person)",
    "price_per_day": 10.00,
    "star_rating": "4.0",
    "imageUrl": "https://hnsgsfp.imgix.net/9/images/detailed/25/Canon_EOS_1500D_Digital_Camera___EF-S_18-55mm_III_Lens_-_Black.png?fit=fill&bg=0FFF&w=1600&h=900&auto=format,compress",
    "totalPrice": 40.0,
    "deliveryMethods": 'Self-Pickup',
    
    "startDate": "25/11/2025 09:00am",
    "dueDate": "29/11/2025 09:00am",
    "daysRemaining": 0, // Due today!
    "currentStatus": "Due Today",
    "returnMethod": "Self Drop-off",
    "dropoffLocation": "Petaling Jaya Collection Point",
  },
  
  // --- Dummy Data Entry 4: Gaming Console (Long-term rental, awaiting user action) ---
  {
    "id": "RNT_004",
    "product_name": "Next-Gen Gaming Console",
    "price_per_day": 25.00,
    "star_rating": "4.7",
    "imageUrl": "https://hnsgsfp.imgix.net/9/images/detailed/25/Canon_EOS_1500D_Digital_Camera___EF-S_18-55mm_III_Lens_-_Black.png?fit=fill&bg=0FFF&w=1600&h=900&auto=format,compress",
    "deliveryMethods": 'Self-Pickup',
    "totalPrice": 525.0,
    
    "startDate": "01/10/2025 03:00pm",
    "dueDate": "20/12/2025 03:00pm",
    "daysRemaining": 21,
    "currentStatus": "In Use",
    "returnMethod": "Self Drop-off",
    "dropoffLocation": "TBD (User needs to schedule drop-off)",
  },
  
  // --- Dummy Data Entry 5: Projector (Rental extension scenario) ---
  {
    "id": "RNT_005",
    "product_name": "Portable Projector Mini P5",
    "price_per_day": 20.00,
    "star_rating": "4.2",
    "imageUrl": "https://hnsgsfp.imgix.net/9/images/detailed/25/Canon_EOS_1500D_Digital_Camera___EF-S_18-55mm_III_Lens_-_Black.png?fit=fill&bg=0FFF&w=1600&h=900&auto=format,compress",
    "deliveryMethods": 'Self-Pickup',
    "totalPrice": 120.0,
    
    "startDate": "10/11/2025 05:00pm",
    "dueDate": "10/12/2025 05:00pm",
    "daysRemaining": 11,
    "currentStatus": "In Use (Extended)", // Status reflecting a change
    "returnMethod": "Prepaid Courier Pickup",
    "dropoffLocation": "N/A (Pickup scheduled for 10/12)",
  },
];

const List<Map<String, dynamic>> userOrderHistory = [
  // ... (HST_001 and HST_002 from previous context)
  {
    "id": "HST_001",
    "product_name": "Blue Shirt",
    "price_per_day": 15.00,
    "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT460OGIyQmwNfs80F55cOV8VwmQm1yAVGgVA&s",
    "finalTotalPrice": 105.00, // Includes a small late fee
    
    "startDate": "10/08/2025 10:00am",
    "returnDate": "17/08/2025 11:00am",
    "rentalDurationDays": 7,
    "finalStatus": "Completed with Late Fee",
    "paymentMethod": "Credit Card",

    "hasReviewed": true,
    "userRating": 4.0,
    "reviewText": "Great camera, slightly confusing return process.",
  },
  {
    "id": "HST_002",
    "product_name": "Camping Tent (4-Person)",
    "price_per_day": 10.00,
    "imageUrl": "https://m.media-amazon.com/images/I/81pSTzxLxlL._AC_UF894,1000_QL80_.jpg",
    "finalTotalPrice": 40.00,
    
    "startDate": "20/07/2025 09:00am",
    "returnDate": "24/07/2025 09:00am",
    "rentalDurationDays": 4,
    "finalStatus": "Completed",
    "paymentMethod": "E-Wallet",

    "hasReviewed": false, // User needs to review this item
    "userRating": null,
    "reviewText": null,
  },
  
  // --- Dummy Data Entry 3: Successfully Completed Rental ---
  {
    "id": "HST_003",
    "product_name": "Portable Projector Mini P5",
    "price_per_day": 20.00,
    "imageUrl": "https://m.media-amazon.com/images/I/61pKMIi0AfL._AC_SL1500_.jpg",
    "finalTotalPrice": 60.00, // Total price = 3 days * 20.00
    
    "startDate": "01/09/2025 05:00pm",
    "returnDate": "04/09/2025 04:00pm",
    "rentalDurationDays": 3,
    "finalStatus": "Completed",
    "paymentMethod": "Bank Transfer",

    "hasReviewed": false, // Prompt to review
    "userRating": null,
    "reviewText": null,
  },
  
  // --- Dummy Data Entry 4: Cancelled Order (No rental occurred) ---
  {
    "id": "HST_004",
    "product_name": "Electric Scooter X90",
    "price_per_day": 45.00,
    "imageUrl": "https://m.media-amazon.com/images/I/61pKMIi0AfL._AC_SL1500_.jpg",
    "finalTotalPrice": 0.00, // Full refund processed
    
    // Dates reflect when the transaction was originally set up/cancelled
    "startDate": "20/11/2025 08:00pm",
    "returnDate": "21/11/2025 10:00am", // Date of cancellation
    "rentalDurationDays": 0,
    "finalStatus": "Cancelled (Before Pickup)",
    "paymentMethod": "E-Wallet (Refunded)",

    "hasReviewed": false, // No review needed for cancelled item
    "userRating": null,
    "reviewText": null,
  },
  
  // --- Dummy Data Entry 5: Reviewed Item, Long Rental ---
  {
    "id": "HST_005",
    "product_name": "Professional DSLR Lens (50mm)",
    "price_per_day": 30.00,
    "imageUrl": "https://m.media-amazon.com/images/I/61pKMIi0AfL._AC_SL1500_.jpg",
    "finalTotalPrice": 300.00,
    
    "startDate": "01/10/2025 10:00am",
    "returnDate": "11/10/2025 10:00am",
    "rentalDurationDays": 10,
    "finalStatus": "Completed",
    "paymentMethod": "Credit Card",

    "hasReviewed": true,
    "userRating": 5.0,
    "reviewText": "Flawless lens, highly recommend!",
  },
];