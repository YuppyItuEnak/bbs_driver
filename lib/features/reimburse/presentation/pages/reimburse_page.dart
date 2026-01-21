import 'package:bbs_driver/features/reimburse/presentation/pages/ajukan_reimburse_page.dart';
import 'package:bbs_driver/features/reimburse/presentation/widget/reimburse_card_item.dart';
import 'package:flutter/material.dart';

class ReimbursePage extends StatefulWidget {
  const ReimbursePage({super.key});

  @override
  State<ReimbursePage> createState() => _ReimbursePageState();
}

class _ReimbursePageState extends State<ReimbursePage> {
  final List<Map<String, String>> reimburseList = [
    {
      "title": "Bensin",
      "km": "1.250 KM",
      "date": "12 Des 2023",
      "status": "POSTED",
    },
    {
      "title": "Bensin",
      "km": "1.000 KM",
      "date": "05 Des 2023",
      "status": "POSTED",
    },
    {
      "title": "Bensin",
      "km": "920 KM",
      "date": "28 Nov 2023",
      "status": "LUNAS",
    },
    {
      "title": "Bensin",
      "km": "1.200 KM",
      "date": "21 Nov 2023",
      "status": "LUNAS",
    },
    {
      "title": "Bensin",
      "km": "1.250 KM",
      "date": "14 Nov 2023",
      "status": "LUNAS",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFB9B1C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "List Reimburse",
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            itemCount: reimburseList.length,
            itemBuilder: (context, index) {
              return ReimburseCardItem(item: reimburseList[index]);
            },
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Navigasi ke halaman Ajukan Reimburse
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AjukanReimbursePage(), // Pastikan nama class halaman register Anda sesuai
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFB9B1C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Ajukan Reimburse",
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
}
