import 'package:bbs_driver/features/deilvery_order/presentation/pages/detail_do_page.dart';
import 'package:flutter/material.dart';

class DoBelumConfirmPage extends StatefulWidget {
  const DoBelumConfirmPage({super.key});

  @override
  State<DoBelumConfirmPage> createState() => _DoBelumConfirmPageState();
}

class _DoBelumConfirmPageState extends State<DoBelumConfirmPage> {
  // Data simulasi untuk list DO
  final List<Map<String, dynamic>> _doList = [
    {
      "id": "DO-05N-2304-0001",
      "customer": "PT. HUTAMA KARYA",
      "address": "Jl. Candi Lontar II no 48 B",
      "date": "04/04/2023",
      "isSelected": false,
    },
    {
      "id": "DO-05N-2304-0002",
      "customer": "PT. BUDI JAYA",
      "address": "Jl. Melati no 60 Kalisari Gresik",
      "date": "05/04/2023",
      "isSelected": false,
    },
    {
      "id": "DO-05N-2304-0003",
      "customer": "PT. CAHAYA DUNIA",
      "address": "Jl. Tanah Merah no 79 Kediri",
      "date": "06/04/2023",
      "isSelected": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFB703)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "List DO Masuk",
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // Header List (Semua & Select All)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Semua",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      for (var item in _doList) {
                        item['isSelected'] = true;
                      }
                    });
                  },
                  child: const Text(
                    "Select All",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // List Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _doList.length,
              itemBuilder: (context, index) {
                return _buildDoCard(_doList[index]);
              },
            ),
          ),

          // Tombol Konfirmasi
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Aksi konfirmasi
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const DetailDoPage(isConfirmed: false),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB703),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Konfirmasi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox Custom (Tetap seperti kode Anda agar bisa di-select)
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 10),
            child: InkWell(
              onTap: () {
                setState(() {
                  item['isSelected'] = !item['isSelected'];
                });
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: item['isSelected']
                        ? const Color(0xFF0084FF)
                        : Colors.grey.shade300,
                  ),
                  color: item['isSelected']
                      ? const Color(0xFF0084FF)
                      : Colors.transparent,
                ),
                child: item['isSelected']
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ),

          // Card Content dikemas dalam GestureDetector untuk navigasi
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetailDoPage(
                      isConfirmed:
                          false, // Set false untuk status belum confirm
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['id'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          item['date'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['customer'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['address'],
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
