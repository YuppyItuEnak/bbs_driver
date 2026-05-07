import 'package:bbs_driver/features/auth/presentation/pages/forget_password.dart';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_driver/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Untuk fitur toggle mata pada password

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definisi warna utama sesuai gambar
    const Color primaryOrange = Color(0xFFFCAA26);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Field Username ---
              const Text(
                "Email / Username",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan email',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Username tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 20),

              // --- Field Password ---
              const Text(
                "Password",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Masukkan password',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off_outlined,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Password tidak boleh kosong'
                    : null,
              ),

              // --- Forget Password (Align Right sesuai gambar) ---
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ForgetPassword(), // Pastikan nama class halaman register Anda sesuai
                      ),
                    );
                  },
                  child: const Text(
                    "Forget Password?",
                    style: TextStyle(
                      color: primaryOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- Error Message dari Provider ---
              if (authProvider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          authProvider.error!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () {
                                  authProvider.login(
                                    _usernameController.text,
                                    _passwordController.text,
                                  );
                                },
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),

              // --- Tombol Login (Style Rounded & Orange) ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            await authProvider.login(
                              _usernameController.text,
                              _passwordController.text,
                            );
                            // After successful login, navigate to HomePage
                            if (authProvider.isAuthenticated) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
