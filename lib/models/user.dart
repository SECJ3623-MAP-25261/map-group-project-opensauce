class User {
  String name;
  String email;
  String phone;
  String address;
  String profileImage;
  String faculty;

  String role; 


  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.profileImage,
    required this.faculty,
    this.role = 'rentee',
  });
}
