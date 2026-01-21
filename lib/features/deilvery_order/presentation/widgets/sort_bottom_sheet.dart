import 'package:flutter/material.dart';

class SortBottomSheet extends StatefulWidget {
  final String initialSort;
  final Function(String) onApply;

  const SortBottomSheet({
    super.key,
    required this.initialSort,
    required this.onApply,
  });

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();

  // Helper function untuk memanggil bottom sheet dari file mana saja
  static void show(BuildContext context, String currentSort, Function(String) onApply) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => SortBottomSheet(
        initialSort: currentSort,
        onApply: onApply,
      ),
    );
  }
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  late String selectedSort;

  @override
  void initState() {
    super.initState();
    selectedSort = widget.initialSort;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Judul dan tombol Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Sort By",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedSort = 'Terbaru - Terlama';
                  });
                },
                child: const Text("Reset", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Daftar Pilihan Radio
          _buildSortOption("Terbaru - Terlama"),
          _buildSortOption("Terlama - Terbaru"),
          _buildSortOption("Customer A-Z"),
          _buildSortOption("Customer Z-A"),

          const SizedBox(height: 20),

          // Tombol Terapkan
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(selectedSort);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                "Terapkan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10), // Padding bawah tambahan
        ],
      ),
    );
  }

  Widget _buildSortOption(String title) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      value: title,
      groupValue: selectedSort,
      activeColor: const Color(0xFFFFC107),
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
      onChanged: (val) {
        setState(() {
          selectedSort = val!;
        });
      },
    );
  }
}