import 'package:flutter/material.dart';

class RegisterForm extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType keyboardType;
  final bool isDropdown;
  final List<String>? dropdownItems;
  final Function(String?)? onChanged;
  final String? value;
  final TextEditingController? controller; // Tambahan untuk mengambil input teks

  const RegisterForm({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.keyboardType = TextInputType.text,
    this.isDropdown = false,
    this.dropdownItems,
    this.onChanged,
    this.value,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 8),
          isDropdown ? _buildDropdown() : _buildTextField(),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: _inputDecoration(),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(),
      hint: Text(
        hint,
        style: const TextStyle(
          color: Colors.black26, 
          fontSize: 14, 
          fontStyle: FontStyle.italic
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFB9B1C)),
      items: dropdownItems?.map((String val) {
        return DropdownMenuItem<String>(
          value: val,
          child: Text(val),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintText: isDropdown ? null : hint,
      hintStyle: const TextStyle(
        color: Colors.black26,
        fontSize: 14,
        fontStyle: FontStyle.italic,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: const Color(0xFFFB9B1C),
              ),
              onPressed: onToggleVisibility,
            )
          : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFFB9B1C)),
      ),
    );
  }
}