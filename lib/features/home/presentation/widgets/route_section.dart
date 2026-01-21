import 'package:flutter/material.dart';
import 'home_card_decoration.dart';

class RouteSection extends StatelessWidget {
  const RouteSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Lihat Rute Hari Ini",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Lihat Riwayat", style: TextStyle(color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 140,
          decoration: homeCardDecoration(),
          alignment: Alignment.center,
          child: const Text("Buka Maps"),
        ),
      ],
    );
  }
}
