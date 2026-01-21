import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildDateSection("28 April 2023"),
          _buildNotificationItem(
            title: "DO-007 telah masuk ke daftar pengiriman Anda. Silakan laku...",
            isRead: false,
          ),
          const SizedBox(height: 20),
          
          _buildDateSection("27 April 2023"),
          _buildNotificationItem(
            title: "DO-006 telah masuk ke daftar pengiriman Anda. Silakan laku...",
            isRead: false,
          ),
          const Divider(height: 30, thickness: 1, color: Color(0xFFF1F5F9)),
          _buildNotificationItem(
            title: "DO-005 telah masuk ke daftar pengiriman Anda. Silakan lakukan pengiriman.",
            isRead: true, // Item yang sudah dibaca (warna abu-abu)
            showArrow: false,
          ),
        ],
      ),
    );
  }

  // Widget untuk Label Tanggal
  Widget _buildDateSection(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        date,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // Widget untuk Item Notifikasi
  Widget _buildNotificationItem({
    required String title,
    bool isRead = false,
    bool showArrow = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lingkaran Ikon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              // Warna hijau jika belum dibaca, abu-abu jika sudah
              color: isRead ? Colors.grey : const Color(0xFF42CC35),
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          
          // Teks Notifikasi
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: const Color(0xFF2D3142),
                fontSize: 14,
                fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Panah Navigasi
          if (showArrow)
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 24,
            ),
        ],
      ),
    );
  }
}