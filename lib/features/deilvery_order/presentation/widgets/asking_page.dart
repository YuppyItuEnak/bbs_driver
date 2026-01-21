import 'package:flutter/material.dart';
import 'success_do.dart'; // Import halaman tujuan setelah klik 'Yes'

class AskingPage extends StatefulWidget {
  const AskingPage({super.key});

  @override
  State<AskingPage> createState() => _AskingPageState();
}

class _AskingPageState extends State<AskingPage> {
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

              // 1. Gambar Ilustrasi
              // Ganti 'assets/asking_illustration.png' sesuai nama file Anda
              Center(
                child: Image.asset(
                  'assets/asking_illustration.png',
                  height: 250,
                  fit: BoxFit.contain,
                  // Jika gambar belum ada, gunakan placeholder sementara:
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.help_outline,
                    size: 150,
                    color: Color(0xFFFFB703),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 2. Teks Pertanyaan
              const Text(
                "Apakah anda yakin?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3142),
                ),
              ),

              const Spacer(),

              // 3. Tombol Aksi (No & Yes)
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Row(
                  children: [
                    // Tombol No
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFF1F5F9,
                            ), // Abu-abu terang
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "No",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Tombol Yes
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            // Berpindah ke halaman SuccessDo
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SuccessDo(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB703), // Oranye
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Yes",
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
            ],
          ),
        ),
      ),
    );
  }
}
