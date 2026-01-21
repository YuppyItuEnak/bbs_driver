import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
// Pastikan import ini sesuai dengan struktur project Anda
import 'package:bbs_driver/features/auth/presentation/pages/login_page.dart';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.user?.name ?? "Guest";
    // final userEmail = authProvider.user?. ?? "email@notfound.com";
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bagian Header Kuning
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC107), // Warna Kuning Sesuai Gambar
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(
                               "https://i.pravatar.cc/150?img=32",
                              ), // Ganti dengan foto asli
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName ?? "Dwi Kurnia",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Surabaya",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Bagian Form Profil
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Basic Profile",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    label: "dwikurnia@bbs.com",
                    icon: Icons.email_outlined,
                    isEditable: true,
                  ),
                  _buildTextField(
                    label: "+62 8234567890",
                    icon: Icons.phone_outlined,
                    isEditable: true,
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Change Password",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    label: "enter new password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  _buildTextField(
                    label: "retype new password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  const SizedBox(height: 10),

                  // Tombol Logout
                  TextButton.icon(
                    onPressed: () {
                      Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).logout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tombol Save
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Save",
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
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk TextField / Baris Informasi
  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool isEditable = false,
    bool isPassword = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey, size: 22),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            if (isEditable)
              const Icon(
                Icons.edit_outlined,
                color: Color(0xFFFFC107),
                size: 20,
              ),
          ],
        ),
        const Divider(height: 30, thickness: 1),
      ],
    );
  }
}
