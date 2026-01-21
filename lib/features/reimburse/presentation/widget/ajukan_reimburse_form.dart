import 'package:flutter/material.dart';

class AjukanReimburseForm extends StatelessWidget {
  final String label;
  final String hint;
  final bool isDropdown;
  final bool isPhotoUpload;
  final int maxLines;
  final List<String>? dropdownItems;
  final String? dropdownValue;
  final Function(String?)? onChanged;

  const AjukanReimburseForm({
    super.key,
    required this.label,
    this.hint = "",
    this.isDropdown = false,
    this.isPhotoUpload = false,
    this.maxLines = 1,
    this.dropdownItems,
    this.dropdownValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 8),
          if (isPhotoUpload)
            _buildPhotoUpload()
          else if (isDropdown)
            _buildDropdownField()
          else
            _buildTextField(),
        ],
      ),
    );
  }

  // Label dengan Asterisk Merah
  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF2D3142),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        children: const [
          TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  // Input Teks Biasa
  Widget _buildTextField() {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFB9B1C)),
        ),
      ),
    );
  }

  // Dropdown Field
  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: dropdownValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          items: dropdownItems?.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Area Upload Foto
  Widget _buildPhotoUpload() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: const Icon(
        Icons.camera_alt_outlined,
        color: Color(0xFFC0C0C0),
        size: 40,
      ),
    );
  }
}