import 'package:bbs_driver/features/deilvery_order/presentation/widgets/sort_bottom_sheet.dart';
import 'package:flutter/material.dart';

class RiwayatDoPage extends StatefulWidget {
  const RiwayatDoPage({super.key});

  @override
  State<RiwayatDoPage> createState() => _RiwayatDoPageState();
}

class _RiwayatDoPageState extends State<RiwayatDoPage> {
  String currentSort = 'Terbaru - Terlama';
  // Data dummy untuk list
  final List<Map<String, String>> riwayatData = [
    {
      "nama": "PT. HUTAMA KARYA",
      "alamat": "Jl. Candi Lontar II No. 48 B",
      "status": "Terkirim",
    },
    {
      "nama": "PT. BUDI JAYA",
      "alamat": "Jl. Melati no 60 Kalisari Gresik",
      "status": "",
    },
    {
      "nama": "PT. CAHAYA DUNIA",
      "alamat": "Jl. Tanah Merah no 79 Kediri",
      "status": "",
    },
    {
      "nama": "PT. ABADI SENTOSA",
      "alamat": "Jl. Rajawali VI no 114 Surabaya",
      "status": "",
    },
    {
      "nama": "PT. BUDI JAYA",
      "alamat": "Jl. Melati no 60 Kalisari Gresik",
      "status": "",
    },
    {
      "nama": "PT. CAHAYA DUNIA",
      "alamat": "Jl. Tanah Merah no 79 Kediri",
      "status": "",
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
        title: const Text(
          "Riwayat DO",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // Tombol Filter Kuning
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFC107),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                onPressed: () {
                  SortBottomSheet.show(context, currentSort, (newSort) {
                    setState(() {
                      currentSort = newSort;
                      // Panggil fungsi untuk mengurutkan data Anda di sini
                      // _sortData();
                    });
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FB),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Semua",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          // List Riwayat
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: riwayatData.length,
              itemBuilder: (context, index) {
                final item = riwayatData[index];
                return _buildRiwayatCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(Map<String, String> data) {
    bool isTerkirim = data["status"] == "Terkirim";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Ikon Dokumen
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 15),

          // Informasi Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["nama"]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data["alamat"]!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                if (isTerkirim) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F9EE),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                      ),
                    ),
                    child: const Text(
                      "Terkirim",
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
