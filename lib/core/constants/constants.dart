import 'package:flutter/material.dart';

//TODO: Seperate the code into difference file if the code is too long

class AppColors {
  static const primary = Color(0xFFF8BE17); // Gold color
  static const primaryRed = Color(0xFF800000);
}

class AppString {
  static const userSampleId= "UAPrpMnRHvfu47xvzh7L";
  // Define text
  static const appName = 'EasyRent';
  // static const baseUrl = 'http://10.203.106.199:5001/opensource-88def/us-central1';
  // static const String baseUrl = 'http://127.0.0.1:3000';
  // static const String baseUrl = 'http://10.45.57.244';
  // static const String baseUrl = 'https://api-obf4enbu7a-uc.a.run.app';
  static const String baseUrl = 'http://10.203.106.199:5001/opensource-88def/us-central1';
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


