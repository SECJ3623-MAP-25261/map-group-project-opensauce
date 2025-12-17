import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  // Fields match the data provided
  final String id;
  final String fname;
  final String lname;
  final String email;
  final String? phone; // Nullable
  final String? address; // Nullable
  final String? profileImage; // Nullable (e.g., URL to the image)
  final String? faculty; // Nullable
  final String role; // e.g., 'rentee', 'renter', 'admin'
  // Constructor
  User({
    required this.id,
    required this.fname,
    required this.lname,
    required this.email,
    this.phone,
    this.address,
    this.profileImage,
    this.faculty,
    required this.role,
  });

  // // --- 2. Serialization (To Firebase/Map) ---
  // /// Converts the Dart object into a Map suitable for Firestore.
  Map<String, dynamic> toJson() {
    return {
      //     // 'id' is often the document ID, so it's often omitted here,
      //     // but included if you want it stored in the document body as well.
      'fname': fname,
      'lname': lname,
      'email': email,
      'phone': phone,
      'address': address,
      'profile_image': profileImage,
      'faculty': faculty,
      'role': role,
    };
  }

  // // --- 3. Deserialization (From Firebase/Map) ---
  // /// Creates a [User] object from a Firestore [DocumentSnapshot].
  factory User.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      //     // Handle the case where the document exists but is empty
      throw StateError('User data is missing from Firestore snapshot.');
    }

    return User(
      id: snapshot.id, // **CRITICAL**: Use the Document ID for the 'id' field
      fname: data['fname'] ?? '',
      lname: data['lname'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      address: data['address'],
      profileImage: data['profile_image'],
      faculty: data['faculty'],
      role: data['role'] ?? 'rentee', // Provide a default role if needed
    );
  }

  // // --- Optional: CopyWith Method ---
  // // Useful for easily creating a new instance with updated fields (e.g., updating profile)
  User copyWith({
    String? id,
    String? fname,
    String? lname,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
    String? faculty,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      fname: fname ?? this.fname,
      lname: lname ?? this.lname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      faculty: faculty ?? this.faculty,
      role: role ?? this.role,
    );
  }
}
