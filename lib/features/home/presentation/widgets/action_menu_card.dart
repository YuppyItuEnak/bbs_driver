import 'package:flutter/material.dart';

class ActionMenuCard extends StatelessWidget {
  final String label;
  final String? sublabel;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const ActionMenuCard({
    super.key,
    required this.label,
    this.sublabel,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: iconColor),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: iconColor.withOpacity(0.8),
            ),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 6),
            Text(
              sublabel!,
              style: TextStyle(
                fontSize: 12,
                color: iconColor.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
