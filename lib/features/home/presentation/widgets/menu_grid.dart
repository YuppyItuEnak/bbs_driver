// import 'package:bbs_sales_app/features/quotation/presentation/pages/quotation_list_page.dart';
import 'package:bbs_driver/features/quotation/presentation/pages/quotation_list_page.dart';
import 'package:flutter/material.dart';

class MenuGrid extends StatelessWidget {
  const MenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = [
      _menuItem(context, Icons.track_changes, "Sales Target", Colors.orange),
      _menuItem(context, Icons.list_alt, "Katalog", Colors.green),
      _menuItem(context, Icons.receipt_long, "Tagihan", Colors.blue),
      _menuItem(context, Icons.show_chart, "Performance", Colors.red),
      _menuItem(context, Icons.people, "Customer", Colors.purple),
      _menuItem(context, Icons.description, "Quotation", Colors.teal),
      _menuItem(context, Icons.headset_mic, "Complain", Colors.pink),
      _menuItem(context, Icons.attach_money, "Reimburse", Colors.brown),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menus.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (_, i) => menus[i],
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        if (title == 'Quotation') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuotationListPage()),
          );
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
