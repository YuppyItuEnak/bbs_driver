import 'package:flutter/material.dart';
import 'home_card_decoration.dart';

class AnnouncementSection extends StatelessWidget {
  const AnnouncementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pengumuman", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: homeCardDecoration(color: const Color(0xFF6AA8F7)),
          child: Column(
            children: const [
              Icon(Icons.warning, color: Colors.orange, size: 40),
              SizedBox(height: 12),
              Text(
                "Pemeliharaan Sistem Untuk Meningkatkan Kualitas Aplikasi Akan Dilakukan 19 Mei 2025",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
