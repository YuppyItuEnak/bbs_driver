import 'package:flutter/material.dart';

class CheckinItem {
  /// Widget untuk menampilkan baris informasi (Label dan Nilai)
  static Widget infoTile({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  /// Widget untuk Tombol Check In yang berubah warna
  static Widget actionButton({
    required bool isActive,
    required VoidCallback? onPressed,
    String text = "Check In",
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isActive ? onPressed : null,
        style: ElevatedButton.styleFrom(
          // Warna Hijau jika aktif, jika tidak otomatis pakai disabledBackgroundColor
          backgroundColor: const Color(0xFF4CAF50),
          disabledBackgroundColor: const Color(0xFFA6A6A6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}