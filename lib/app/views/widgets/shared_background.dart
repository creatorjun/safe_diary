// lib/app/views/widgets/shared_background.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SharedBackground extends StatelessWidget {
  final Widget child;

  const SharedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String backgroundImage = Get.isDarkMode
        ? "assets/home_dark_back.png"
        : "assets/home_light_back.png";

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}