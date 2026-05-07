import 'package:bbs_driver/data/models/reimburse/reimburse_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReimburseCardItem extends StatelessWidget {
  final ReimburseModel item;

  const ReimburseCardItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    // Logika status warna
    final status = item.status?.toUpperCase();
    bool isPosted = status == "IN_APPROVAL";
    bool isDraft = status == "DRAFT";
    bool isApproved = status == "APPROVED";
    bool isRejected = status == "REJECT";

    Color statusColor;
    if (isPosted) {
      statusColor = const Color(0xFF6366F1);
    } else if (isDraft) {
      statusColor = Colors.grey;
    } else if (isApproved) {
      statusColor = const Color(0xFF22C55E);
    } else if (isRejected) {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.black;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.type ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2D3142),
                ),
              ),
              Text(
                item.status ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(item.kmAkhir ?? 0) - (item.kmAwal ?? 0)} KM',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                item.date != null
                    ? DateFormat('dd MMM yyyy').format(item.date!)
                    : '',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}