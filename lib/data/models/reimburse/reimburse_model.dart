import 'dart:convert';

List<ReimburseModel> reimburseModelFromJson(String str) =>
    List<ReimburseModel>.from(
      json.decode(str).map((x) => ReimburseModel.fromJson(x)),
    );

String reimburseModelToJson(List<ReimburseModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReimburseModel {
  final String id;
  final String? type;
  final DateTime? date;
  final int? kmAwal;
  final int? kmAkhir;
  final String? code;
  final String? salesId;
  final String? unitBussinessId;
  final String? note;
  final String? alasan;
  final int? total;
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReimburseModel({
    required this.id,
    this.type,
    this.date,
    this.kmAwal,
    this.kmAkhir,
    this.code,
    this.salesId,
    this.unitBussinessId,
    this.note,
    this.alasan,
    this.total,
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
    this.createdAt,
    this.updatedAt,
  });

  factory ReimburseModel.fromJson(Map<String, dynamic> json) => ReimburseModel(
    id: json["id"],
    type: json["type"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    kmAwal: (json["km_awal"] as num?)?.toInt(),
    kmAkhir: (json["km_akhir"] as num?)?.toInt(),
    code: json["code"],
    salesId: json["sales_id"],
    unitBussinessId: json["unit_bussiness_id"],
    note: json["note"],
    alasan: json["alasan"],
    total: (json["total"] as num?)?.toInt(),
    fotoAwal: json["foto_awal"],
    fotoAkhir: json["foto_akhir"],
    status: json["status"],
    approvalCount: (json["approval_count"] as num?)?.toInt(),
    approvedCount: (json["approved_count"] as num?)?.toInt(),
    currentApprovalLevel: (json["current_approval_level"] as num?)?.toInt(),
    submittedBy: json["submitted_by"],
    submittedAt: json["submitted_at"] == null
        ? null
        : DateTime.parse(json["submitted_at"]),
    rejectReason: json["reject_reason"],
    revisedCount: (json["revised_count"] as num?)?.toInt(),
    revisionReason: json["revision_reason"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "date": date?.toIso8601String(),
    "km_awal": kmAwal,
    "km_akhir": kmAkhir,
    "code": code,
    "sales_id": salesId,
    "unit_bussiness_id": unitBussinessId,
    "note": note,
    "alasan": alasan,
    "total": total,
    "foto_awal": fotoAwal,
    "foto_akhir": fotoAkhir,
    "status": status,
    "approval_count": approvalCount,
    "approved_count": approvedCount,
    "current_approval_level": currentApprovalLevel,
    "submitted_by": submittedBy,
    "submitted_at": submittedAt?.toIso8601String(),
    "reject_reason": rejectReason,
    "revised_count": revisedCount,
    "revision_reason": revisionReason,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };

  int get totalKm => kmAkhir != null && kmAwal != null ? kmAkhir! - kmAwal! : 0;
}
