import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashedButton extends StatelessWidget {
  final IconData? icon;
  final String? iconPath;
  final String label;
  final VoidCallback onTap;

  const DashedButton({
    super.key,
    this.icon,
    this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD0D5DD),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            if (iconPath != null)
              SvgPicture.asset(
                iconPath!,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF276572),
                  BlendMode.srcIn,
                ),
              )
            else if (icon != null)
              Icon(icon, color: const Color(0xFF276572)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF276572),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
