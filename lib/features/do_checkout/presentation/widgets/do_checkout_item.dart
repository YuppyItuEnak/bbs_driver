import 'package:flutter/material.dart';

class DoCheckoutItem extends StatelessWidget {
  final bool isCondensed;

  const DoCheckoutItem({
    super.key,
    this.isCondensed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Card (Nomor SO)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Text(
                  "SO-05N-2304-0001",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                const Text(
                  "|  SUB-A1",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
              ],
            ),
          ),
          
          // List Produk
          _productRow(
            "Miliard Selang 8MM",
            "kodeitem001",
            "120 ROLL",
            "Tonase : 50 KG",
          ),
          const Divider(height: 1, indent: 15, endIndent: 15),
          _productRow(
            "Miliard Selang 5MM",
            "kodeitem002",
            "70 ROLL",
            "Tonase : 28 KG",
          ),
        ],
      ),
    );
  }

  Widget _productRow(String name, String code, String qty, String tonase) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                code,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(qty, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                tonase,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}