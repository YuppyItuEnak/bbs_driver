import 'package:bbs_driver/data/models/complaint/complaint_add_model.dart';
import 'package:bbs_driver/core/constants/app_colors.dart';
import 'package:bbs_driver/data/models/delivery_order/surat_jalan_model.dart';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_driver/features/complaint/presentation/providers/return_item_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReturnItemSelectedPage extends StatefulWidget {
  final String sjId;
  final List<String> addedItemIds;

  const ReturnItemSelectedPage({
    super.key,
    required this.sjId,
    required this.addedItemIds,
  });

  @override
  State<ReturnItemSelectedPage> createState() => _ReturnItemSelectedPageState();
}

class _ReturnItemSelectedPageState extends State<ReturnItemSelectedPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReturnItemProvider>();
      final auth = context.read<AuthProvider>();
      provider.loadSJDetails(token: auth.token!, sjId: widget.sjId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReturnItemProvider>();
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Pilih Item Retur',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? Center(child: Text("Error: ${provider.error}"))
                  : ListView(
                      children: provider.sjDetails
                          .map((item) => _buildSJItemTile(item, provider))
                          .toList(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.selectedItems.isNotEmpty
                      ? () {
                          final complaintItems = provider.selectedItems.map((
                            selected,
                          ) {
                            return ComplainCreateItemModel()
                              ..itemId = selected.itemId
                              ..itemName = selected.itemName
                              ..qtyRef = selected.qty
                              ..uomUnit = selected.uomUnit
                              ..qtyReturn = 1
                              ..qtyReplaced = 1;
                          }).toList();
                          Navigator.pop(context, complaintItems);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Pilih (${provider.selectedItems.length})",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSJItemTile(
    SuratJalanDetailModel item,
    ReturnItemProvider provider,
  ) {
    final isAlreadyAdded = widget.addedItemIds.contains(item.itemId);
    final isSelected = provider.selectedItems.any(
      (selected) => selected.itemId == item.itemId,
    );
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        value: isAlreadyAdded || isSelected,
        onChanged: isAlreadyAdded
            ? null
            : (selected) =>
                  provider.toggleSJItemSelection(item, selected ?? false),
        title: Text(
          item.itemName ?? '-',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          "${item.qty ?? 0} ${item.uomUnit}",
          style: const TextStyle(fontSize: 11),
        ),
        activeColor: const Color(0xFF6366F1),
      ),
    );
  }
}
