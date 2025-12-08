import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/models/item.dart';
import '../../../features/models/review.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _productsRef => _db.collection('product');
  CollectionReference get _usersRef => _db.collection('user');

  // --- FETCH PRODUCTS ---
  Stream<List<Item>> getProducts() {
    return _productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);
      }).toList();
    });
  }

  // Stream<List<Map<String, dynamic>>> getProducts() {
  //   // 1. Get the real-time stream of QuerySnapshots
  //   return _productsRef.snapshots().map((snapshot) {
  //     // 2. Map the list of documents into a list of Maps
  //     return snapshot.docs.map((doc) {
  //       // Get the document data as a Map<String, dynamic>
  //       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

  //       // 3. Add the unique Document ID to the Map before returning it
  //       data['id'] = doc.id;

  //       return data;
  //     }).toList();
  //   });
  // }

  // --- UPLOAD SAMPLE PRODUCTS ---
  Future<void> uploadSampleProducts() async {
    try {
      // Get first user from 'user' collection to use as owner
      final users = await _usersRef.limit(1).get();
      if (users.docs.isEmpty) {
        print('❌ No users found. Please add a user first.');
        return;
      }

      final userDoc = users.docs.first;
      final userRef = _usersRef.doc(userDoc.id);
      final userData = userDoc.data() as Map<String, dynamic>;

      final sampleProducts = [
        {
          'product_name': 'TMA-2 HD Wireless Headphones',
          'price_per_day': 15.0,
          'imageURL':
              'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1000&auto=format&fit=crop',
          'owner': userRef,
          'description':
              'High quality wireless headphones with deep bass and noise cancellation.',
          'quantity': 2,
          'renting_duration': 'Daily',
          'delivery_methods': 'Pick-up, Delivery',
          'rating': 4.5,
          'ownerName': '${userData['fname']} ${userData['lname']}',
          'ownerImage':
              userData['profile_image'] ?? 'https://i.pravatar.cc/150?img=1',
          'imageUrls': [
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
            'https://images.unsplash.com/photo-1583394838336-acd977736f90',
          ],
          'reviews': [
            {
              'reviewerName': 'Mike Johnson',
              'reviewerImage': 'https://i.pravatar.cc/150?img=8',
              'date': Timestamp.now(),
              'star': 4.5,
              'reviewText':
                  'Excellent sound quality! The noise cancellation is amazing.',
            },
            {
              'reviewerName': 'Sarah Williams',
              'reviewerImage': 'https://i.pravatar.cc/150?img=5',
              'date': Timestamp.now(),
              'star': 4.0,
              'reviewText':
                  'Good headphones but the battery could last longer.',
            },
            {
              'reviewerName': 'Alex Chen',
              'reviewerImage': 'https://i.pravatar.cc/150?img=11',
              'date': Timestamp.now(),
              'star': 5.0,
              'reviewText':
                  'Perfect for work from home! Blocks out all background noise.',
            },
          ],
        },
        {
          'product_name': 'Sony WH-1000XM4 Headphones',
          'price_per_day': 25.0,
          'imageURL':
              'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?q=80&w=1000&auto=format&fit=crop',
          'owner': userRef,
          'description':
              'Industry leading noise cancelling headphones with 30-hour battery life.',
          'quantity': 1,
          'renting_duration': 'Weekly',
          'delivery_methods': 'Delivery',
          'rating': 4.8,
          'ownerName': '${userData['fname']} ${userData['lname']}',
          'ownerImage':
              userData['profile_image'] ?? 'https://i.pravatar.cc/150?img=1',
          'imageUrls': [
            'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb',
          ],
          'reviews': [
            {
              'reviewerName': 'John Smith',
              'reviewerImage': 'https://i.pravatar.cc/150?img=3',
              'date': Timestamp.now(),
              'star': 5.0,
              'reviewText':
                  'Best headphones I\'ve ever used! Worth every penny.',
            },
            {
              'reviewerName': 'Emma Davis',
              'reviewerImage': 'https://i.pravatar.cc/150?img=12',
              'date': Timestamp.now(),
              'star': 4.5,
              'reviewText':
                  'Great sound quality and very comfortable for long sessions.',
            },
            {
              'reviewerName': 'Michael Brown',
              'reviewerImage': 'https://i.pravatar.cc/150?img=7',
              'date': Timestamp.now(),
              'star': 4.8,
              'reviewText': 'The noise cancellation is truly industry leading.',
            },
            {
              'reviewerName': 'Lisa Taylor',
              'reviewerImage': 'https://i.pravatar.cc/150?img=9',
              'date': Timestamp.now(),
              'star': 4.0,
              'reviewText': 'Good but a bit expensive for daily rental.',
            },
          ],
        },
        {
          'product_name': 'PlayStation 5 Console',
          'price_per_day': 40.0,
          'imageURL':
              'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?q=80&w=1000&auto=format&fit=crop',
          'owner': userRef,
          'description':
              'Latest PS5 console with 2 controllers and 3 games included.',
          'quantity': 1,
          'renting_duration': 'Weekly',
          'delivery_methods': 'Pick-up',
          'rating': 4.7,
          'ownerName': '${userData['fname']} ${userData['lname']}',
          'ownerImage':
              userData['profile_image'] ?? 'https://i.pravatar.cc/150?img=1',
          'imageUrls': [
            'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3',
          ],
          'reviews': [
            {
              'reviewerName': 'David Wilson',
              'reviewerImage': 'https://i.pravatar.cc/150?img=4',
              'date': Timestamp.now(),
              'star': 5.0,
              'reviewText':
                  'Perfect console! Games run smoothly and graphics are stunning.',
            },
            {
              'reviewerName': 'Jessica Miller',
              'reviewerImage': 'https://i.pravatar.cc/150?img=6',
              'date': Timestamp.now(),
              'star': 4.5,
              'reviewText': 'Great rental experience. Owner was very helpful.',
            },
            {
              'reviewerName': 'Kevin Garcia',
              'reviewerImage': 'https://i.pravatar.cc/150?img=10',
              'date': Timestamp.now(),
              'star': 4.0,
              'reviewText':
                  'Console works perfectly, but the included games were a bit old.',
            },
          ],
        },
      ];

      // Upload each product
      for (var product in sampleProducts) {
        await _productsRef.add(product);
        print('✅ Uploaded: ${product['product_name']}');
      }

      print('🎉 Sample products uploaded successfully!');
    } catch (e) {
      print('❌ Error uploading products: $e');
      rethrow;
    }
  }
}
