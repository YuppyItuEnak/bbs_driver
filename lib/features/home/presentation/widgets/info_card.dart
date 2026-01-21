import 'package:flutter/material.dart';
import 'home_card_decoration.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: homeCardDecoration(),
      child: Row(
        children: const [
          Icon(Icons.celebration, color: Colors.orange),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hari Raya Idul Fitri",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("2 Minggu Lagi", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
