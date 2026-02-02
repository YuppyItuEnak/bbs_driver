class ReimburseDetailModel {
  final String id;
  final String type;
  final DateTime date;
  final double kmAwal;
  final double kmAkhir;
  final String? code;
  final double total;

  final String? salesId;
  final String? unitBusinessId;
  final String? note;
  final String? alasan;

  final String? fotoAwal;
  final String? fotoAkhir;

  final String? status;
  final int? approvalCount;
  final int? approvedCount;
  final int? currentApprovalLevel;

  final String? submittedBy;
  final DateTime? submittedAt;

  final String? rejectReason;
  final int? revisedCount;
  final String? revisionReason;

  ReimburseDetailModel({
    required this.id,
    required this.type,
    required this.date,
    required this.kmAwal,
    required this.kmAkhir,
    this.code,
    required this.total,
    this.salesId,
    this.unitBusinessId,
    this.note,
    this.alasan,
    this.fotoAwal,
    this.fotoAkhir,
    this.status,
    this.approvalCount,
    this.approvedCount,
    this.currentApprovalLevel,
    this.submittedBy,
    this.submittedAt,
    this.rejectReason,
    this.revisedCount,
    this.revisionReason,
  });

  factory ReimburseDetailModel.fromJson(Map<String, dynamic> json) {
    return ReimburseDetailModel(
      id: json['id'],
      type: json['type'],
      total: (json['total'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      kmAwal: (json['km_awal'] as num).toDouble(),
      kmAkhir: (json['km_akhir'] as num).toDouble(),
      code: json['code'],
      salesId: json['sales_id'],
      unitBusinessId: json['unit_bussiness_id'],
      note: json['note'] ?? '',
      alasan: json['alasan'],
      fotoAwal: json['foto_awal'],
      fotoAkhir: json['foto_akhir'],
      status: json['status'],
      approvalCount: json['approval_count'],
      approvedCount: json['approved_count'],
      currentApprovalLevel: json['current_approval_level'],
      submittedBy: json['submitted_by'],
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : null,
      rejectReason: json['reject_reason'],
      revisedCount: json['revised_count'],
      revisionReason: json['revision_reason'],
    );
  }

  double get totalKm => kmAkhir - kmAwal;
}
