import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/ui/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Center(
        child: Hero(
          tag: 'logo',
          child: SvgPicture.asset(
            'assets/images/logo.svg',
            width: 100,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.square_rounded,
              color: Colors.orange,
              size: 100,
            ),
          ),
        ),
      ),
    );
  }
}
