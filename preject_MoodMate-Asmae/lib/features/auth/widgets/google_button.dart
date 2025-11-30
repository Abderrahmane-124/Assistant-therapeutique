import 'package:flutter/material.dart';
import '../../../ui/styles/app_colors.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: AppColors.googleBorder),
      ),
      onPressed: () {},
      icon: const Icon(Icons.public, color: Colors.black),
      label: const Text(
        "Continuer avec Google",
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
