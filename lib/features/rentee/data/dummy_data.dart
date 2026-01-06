// Product List (Updated with more items)
final List<Map<String, dynamic>> dummyProducts = [
  {
    "id": "item1",
    "quantity":3,
    "product_name": "TMA-2 HD Wireless",
    "price": 10, //price per day
    "rating": 4.6,
    "reviewCount": 86,
    "image":
        "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=300&auto=format&fit=crop",
    "images": [
      "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=300&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1583394838336-acd977736f90?q=80&w=300&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1484704849700-f032a568e944?q=80&w=300&auto=format&fit=crop",
    ],
    "renter": {
      "name": "John Doe",
      "image": "https://i.pravatar.cc/150?img=12",
      "period": "2 months renting",
    },
    "description":
        "The speaker unit contains a diaphragm that is precision-grown from NAC Audio bio-cellulose, making it stiffer, lighter and stronger than regular PET speaker units.",
  },
  {
    "id": "item2",
    "quantity":3,
    "product_name": "XLite Mini Mouse",
    "price": 10,
    "rating": 4.8,
    "reviewCount": 120,
    "image":
        "https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?q=80&w=300&auto=format&fit=crop",
    "images": [
      "https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?q=80&w=300&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?q=80&w=300&auto=format&fit=crop",
    ],
    "renter": {
      "name": "Alice M.",
      "image": "https://i.pravatar.cc/150?img=9",
      "period": "1 year renting",
    },
    "description":
        "Ultralight ergonomic gaming mouse. Designed for speed and precision with a high-performance sensor. Perfect for competitive gaming.",
  },
  {
    "id": "item3",
    "quantity":3,
    "product_name": "Sony WH-1000XM4",
    "price": 10,
    "rating": 4.9,
    "reviewCount": 342,
    "image":
        "https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?q=80&w=300&auto=format&fit=crop",
    "images": [
      "https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?q=80&w=300&auto=format&fit=crop",
    ],
    "renter": {
      "name": "David K.",
      "image": "https://i.pravatar.cc/150?img=11",
      "period": "5 months renting",
    },
    "description":
        "Industry-leading noise canceling with Dual Noise Sensor technology. Next-level music with Edge-AI, co-developed with Sony Music Studios Tokyo.",
  },
  {
    "product_name": "Logitech G Pro X",
    "quantity":3,
    "price": 10,
    "rating": 4.7,
    "reviewCount": 55,
    "image":
        "https://images.unsplash.com/photo-1605773527852-c546a8584ea3?q=80&w=300&auto=format&fit=crop",
    "images": [
      "https://images.unsplash.com/photo-1605773527852-c546a8584ea3?q=80&w=300&auto=format&fit=crop",
    ],
    "renter": {
      "name": "Sarah J.",
      "image": "https://i.pravatar.cc/150?img=5",
      "period": "3 weeks renting",
    },
    "description":
        "Pro-grade performance with LIGHTSPEED wireless technology. Ultra-lightweight design for pure performance.",
  },
  {
    "product_name": "Canon EOS M50",
    "price": 10,
    "quantity":3,
    "rating": 4.8,
    "reviewCount": 210,
    "image":
        "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=300&auto=format&fit=crop",
    "images": [
      "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=300&auto=format&fit=crop",
    ],
    "renter": {
      "name": "Photography Hub",
      "image": "https://i.pravatar.cc/150?img=8",
      "period": "2 years renting",
    },
    "description":
        "Compact mirrorless camera with 24.1 Megapixel CMOS (APS-C) Sensor and Dual Pixel CMOS AF. Perfect for vlogging and content creation.",
  },
  {
    "product_name": "Secretlab Titan",
    "price": 10,
    "quantity":3,
    "rating": 4.9,
    "reviewCount": 180,
    "image":
        "https://images.unsplash.com/photo-1598550476439-6847785fcea6?q=80&w=300&auto=format&fit=crop",
    "images": [
      "https://images.unsplash.com/photo-1598550476439-6847785fcea6?q=80&w=300&auto=format&fit=crop",
    ],
    "renter": {
      "name": "Gaming Zone",
      "image": "https://i.pravatar.cc/150?img=3",
      "period": "6 months renting",
    },
    "description":
        "The gold standard of gaming chairs. Features integrated adjustable lumbar support and 4D armrests for maximum comfort.",
  },
];

// Reviews List
final List<Map<String, dynamic>> dummyReviews = [
  {
    "name": "Yelena Belova",
    "image": "https://i.pravatar.cc/150?img=5",
    "date": "2 Weeks ago",
    "rating": 4.5,
    "comment":
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.",
  },
  {
    "name": "John Smith",
    "image": "https://i.pravatar.cc/150?img=3",
    "date": "1 Month ago",
    "rating": 5.0,
    "comment":
        "Great product! Works perfectly and the sound quality is amazing for the price.",
  },
  {
    "name": "Sarah Connor",
    "image": "https://i.pravatar.cc/150?img=9",
    "date": "3 Days ago",
    "rating": 4.0,
    "comment":
        "Good quality but shipping took a bit longer than expected. Otherwise solid.",
  },
  {
    "name": "Michael Ross",
    "image": "https://i.pravatar.cc/150?img=11",
    "date": "5 Days ago",
    "rating": 5.0,
    "comment": "Amazing experience, will definitely rent again.",
  },
];
