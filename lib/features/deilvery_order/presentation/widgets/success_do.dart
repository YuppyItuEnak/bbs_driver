import 'package:flutter/material.dart';

class SuccessDo extends StatefulWidget {
  const SuccessDo({super.key});

  @override
  State<SuccessDo> createState() => _SuccessDoState();
}

class _SuccessDoState extends State<SuccessDo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Bagian Gambar Ilustrasi
              // Jika Anda menggunakan file gambar asli: Image.asset('assets/success_ilustration.png')
              // Sebagai contoh, saya gunakan icon placeholder yang mirip
              Center(
                child: SizedBox(
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Lingkaran background (opsional jika tidak pakai gambar asset)
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB703).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 100,
                        color: Color(0xFFFFB703),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Teks Pesan Berhasil
              const Text(
                "Konfirmasi berhasil!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              
              const Spacer(),
              
              // Tombol Selesai
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Kembali ke Home atau reset stack navigasi
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB703),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Selesai",
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
        ),
      ),
    );
  }
}