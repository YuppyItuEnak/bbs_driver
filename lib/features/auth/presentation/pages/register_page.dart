import 'package:bbs_driver/features/auth/presentation/pages/login_page.dart';
import 'package:bbs_driver/features/auth/presentation/widgets/register_form.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Header Title
              const Text(
                "Register",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Buat akun baru",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Form Fields menggunakan widget RegisterForm
              const RegisterForm(
                label: "Nama",
                hint: "masukkan nama lengkap",
              ),
              const RegisterForm(
                label: "ID Pengawai",
                hint: "masukkan nomor ID pegawai",
              ),
              RegisterForm(
                label: "Area",
                hint: "pilih area",
                isDropdown: true,
                dropdownItems: const ['Surabaya', 'Sidoarjo', 'Gresik'],
                onChanged: (value) {
                  // Simpan nilai area di sini
                },
              ),
              const RegisterForm(
                label: "Email",
                hint: "masukkan email",
                keyboardType: TextInputType.emailAddress,
              ),
              const RegisterForm(
                label: "No. HP",
                hint: "masukkan no. HP",
                keyboardType: TextInputType.phone,
              ),

              // Password Field
              RegisterForm(
                label: "Password",
                hint: "masukkan password",
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),

              // Confirm Password Field
              RegisterForm(
                label: "Konfirmasi Password",
                hint: "masukkan ulang password",
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),

              const SizedBox(height: 40),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Action Register
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB9B1C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Login Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFFFB9B1C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}