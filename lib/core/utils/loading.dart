import 'package:easyrent/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: Center(
        child: SpinKitChasingDots(
          color: AppColors.primary,
          size: 50.0,
        ),
      ),
    );
  }
}