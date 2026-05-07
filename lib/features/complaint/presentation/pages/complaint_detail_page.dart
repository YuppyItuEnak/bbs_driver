import 'package:bbs_driver/core/constants/app_colors.dart';
import 'package:bbs_driver/data/models/complaint/complaint_detail_model.dart';
import 'package:bbs_driver/data/services/complaint/complaint_repository.dart';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ComplaintDetailPage extends StatefulWidget {
  final String id;
  const ComplaintDetailPage({super.key, required this.id});

  @override
  State<ComplaintDetailPage> createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  final ComplainRepository _repo = ComplainRepository();
  late Future<ComplainDetailModel> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<ComplainDetailModel> _fetch() async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;
    if (token == null) {
      throw Exception('User not authenticated.');
    }
    return _repo.getDetailComplaint(token: token, id: widget.id);
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
            'Detail Komplain',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
        body: FutureBuilder<ComplainDetailModel>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final detail = snapshot.data!;
            final dateStr = detail.date != null
                ? DateFormat('dd MMM yyyy').format(detail.date!)
                : '-';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _InfoCard(
                  children: [
                    _InfoRow(label: 'Customer', value: detail.customer ?? '-'),
                    _InfoRow(label: 'Tanggal', value: dateStr),
                    _InfoRow(label: 'Ref Type', value: detail.refType ?? '-'),
                    _InfoRow(
                      label: 'Tipe Komplain',
                      value: detail.complainType ?? '-',
                    ),
                    if ((detail.notes ?? '').isNotEmpty)
                      _InfoRow(label: 'Catatan', value: detail.notes ?? ''),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Items',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (detail.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Tidak ada item.'),
                  )
                else
                  ...detail.items.map(
                    (i) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            i.itemName ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Qty Ref: ${i.qtyRef ?? 0} ${i.uomUnit ?? ''}'.trim(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Qty Return: ${i.qtyReturn ?? 0}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        // Edit flow intentionally omitted for driver app.
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value, style: const TextStyle(height: 1.35)),
          ),
        ],
      ),
    );
  }
}
