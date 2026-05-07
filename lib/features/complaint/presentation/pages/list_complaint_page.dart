import 'package:bbs_driver/core/constants/app_colors.dart';
import 'package:bbs_driver/data/models/complaint/complaint_model.dart';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_driver/features/complaint/presentation/pages/add_complaint_page.dart';
import 'package:bbs_driver/features/complaint/presentation/pages/complaint_detail_page.dart';
import 'package:bbs_driver/features/complaint/presentation/providers/complaint_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class KomplainListPage extends StatelessWidget {
  const KomplainListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ComplaintListProvider(),
      child: const _KomplainListContent(),
    );
  }
}

class _KomplainListContent extends StatefulWidget {
  const _KomplainListContent();

  @override
  State<_KomplainListContent> createState() => _KomplainListContentState();
}

class _KomplainListContentState extends State<_KomplainListContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData([String? search]) {
    final auth = context.read<AuthProvider>();
    final provider = context.read<ComplaintListProvider>();

    if (auth.token != null &&
        auth.user?.id != null &&
        auth.unitBusinessId != null) {
      provider.fetchComplaints(
        token: auth.token!,
        salesId: auth.user!.id!,
        unitBusinessId: auth.unitBusinessId!,
        search: search,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Komplain',
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
                onChanged: (val) => _fetchData(val),
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
              child: Consumer<ComplaintListProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(child: Text("Error: ${provider.error}"));
                  }

                  if (provider.items.isEmpty) {
                    return const Center(child: Text("Data tidak ditemukan"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.items.length,
                    itemBuilder: (context, index) {
                      final item = provider.items[index];
                      return _buildKomplainTile(item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const AddComplaintPage()),
            );
            if (result == true && context.mounted) {
              _fetchData();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('Berhasil'),
                  content: const Text('Komplain berhasil disimpan.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
          backgroundColor: const Color(0xFF6366F1),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildKomplainTile(ComplaintModel item) {
    final statusInfo = _getStatusInfo(item.status ?? 0);
    final dateStr = item.date != null
        ? DateFormat('dd MMM yyyy').format(item.date!)
        : '-';

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ComplaintDetailPage(id: item.id)),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.customer ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.refType ?? '-',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  statusInfo['text'],
                  style: TextStyle(
                    color: statusInfo['color'],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(int status) {
    switch (status) {
      case 1:
        return {'text': 'In Approval', 'color': Colors.blue};
      case 2:
        return {'text': 'In Approval', 'color': Colors.blue};
      case 3:
        return {'text': 'Revision', 'color': Colors.orange};
      case 4:
        return {'text': 'Approved', 'color': Colors.green};
      case 9:
        return {'text': 'Rejected', 'color': Colors.red};
      default:
        return {'text': 'Unknown', 'color': Colors.grey};
    }
  }
}
