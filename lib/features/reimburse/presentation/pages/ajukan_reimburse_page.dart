import 'package:bbs_driver/features/reimburse/presentation/widget/ajukan_reimburse_form.dart';
import 'package:flutter/material.dart';


class AjukanReimbursePage extends StatefulWidget {
  const AjukanReimbursePage({super.key});

  @override
  State<AjukanReimbursePage> createState() => _AjukanReimbursePageState();
}

class _AjukanReimbursePageState extends State<AjukanReimbursePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFB9B1C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tambah Reimburse",
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const AjukanReimburseForm(label: "Tanggal", hint: "DD/MM/YYYY"),

            const AjukanReimburseForm(
              label: "Deskripsi",
              isDropdown: true,
              dropdownValue: "Bensin",
              dropdownItems: ["Bensin", "Parkir", "Tol", "Lainnya"],
            ),

            Row(
              children: const [
                Expanded(
                  child: AjukanReimburseForm(
                    label: "Kilometer Awal",
                    hint: "11.250",
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: AjukanReimburseForm(
                    label: "Kilometer Akhir",
                    hint: "12.500",
                  ),
                ),
              ],
            ),

            const AjukanReimburseForm(
              label: "Jumlah Reimburse",
              hint: "50.000",
            ),

            Row(
              children: const [
                Expanded(
                  child: AjukanReimburseForm(
                    label: "Foto KM awal",
                    isPhotoUpload: true,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: AjukanReimburseForm(
                    label: "Foto KM akhir",
                    isPhotoUpload: true,
                  ),
                ),
              ],
            ),

            const AjukanReimburseForm(label: "Catatan", maxLines: 3),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFB9B1C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
