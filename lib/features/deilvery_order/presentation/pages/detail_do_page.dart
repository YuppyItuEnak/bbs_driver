import 'package:bbs_driver/features/do_checkin/presentation/pages/do_checkin_page.dart';
import 'package:flutter/material.dart';

class DetailDoPage extends StatefulWidget {
  final bool isConfirmed; // Parameter untuk menentukan status

  const DetailDoPage({super.key, this.isConfirmed = true});

  @override
  State<DetailDoPage> createState() => _DetailDoPageState();
}

class _DetailDoPageState extends State<DetailDoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail DO",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Section Header Info ---
                  _buildInfoRow("No. DO", "DO-05N-2304-0001"),
                  _buildInfoRow("Tanggal", "04/04/2023"),
                  _buildInfoRow("Customer", "PT. HUTAMA KARYA"),
                  _buildInfoRow("Alamat", "Jl. Candi Lontar II No. 48 B"),

                  const SizedBox(height: 30),

                  // --- Section Card Barang ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header Card
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "SO-05N-2304-0001",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "SUB-A1",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // List Item 1
                        _buildItemRow(
                          "Miliard Selang 8MM",
                          "120 ROLL",
                          "kodeitem001",
                          "50 KG",
                        ),
                        const Divider(height: 1),
                        // List Item 2
                        _buildItemRow(
                          "Miliard Selang 5MM",
                          "70 ROLL",
                          "kodeitem002",
                          "28 KG",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Section Bottom Button ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Aksi tombol
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoCheckinPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isConfirmed
                      ? const Color(0xFF4CAF50)
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  widget.isConfirmed ? "Check In" : "Kembali",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Baris Informasi Atas
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Item di dalam Card
  Widget _buildItemRow(String title, String qty, String code, String weight) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                code,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                qty,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                "Tonase : $weight",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
