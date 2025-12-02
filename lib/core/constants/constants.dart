import 'package:flutter/material.dart';

//TODO: Seperate the code into difference file if the code is too long
class AppColors {
  static const primary = Color(0xFFF8BE17); // Gold color
  static const primaryRed = Color(0xFF800000);
}

class AppString {
  // Define text
  static const appName = 'EasyRent';
}

class AppSize {
  // Define Padding, fontSize 
}

class AppAssets {
  // Define assets
  static const logo = '' ; 
}

class KTextStyle {
  static const TextStyle resetPasswordTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 30.0,
  );

  static const TextStyle resetPasswordDescription = TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 15.0,
  );

  static const TextStyle appBarTitle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold
  );
}

class Space{
  static const smallHorizontal = SizedBox(height: 5.0,);
  static const mediumHorizontal = SizedBox(height: 15.0,);
  static const largeHorizontal = SizedBox(height: 50.0,);
  static const smallVertical = SizedBox(width: 5.0,);
}



