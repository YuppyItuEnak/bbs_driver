class ReimburseCreateModel {
  String? type;
  DateTime? date;
  double? kmAwal;
  double? kmAkhir;
  String? code;
  String? salesId;
  String? unitBusinessId;
  String? note;
  double? total;
  String? alasan;
  String? fotoAwal;
  String? fotoAkhir;
  int? approvalCount;
  int? approvalLevel;
  int? approvedCount;
  String? status;

  ReimburseCreateModel({
    this.type,
    this.date,
    this.kmAwal,
    this.kmAkhir,
    this.code,
    this.total,
    this.salesId,
    this.unitBusinessId,
    this.approvalCount,
    this.approvalLevel,
    this.approvedCount,
    this.note,
    this.alasan,
    this.fotoAwal,
    this.fotoAkhir,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "date": date?.toIso8601String().split('T').first,
      "km_awal": kmAwal,
      "km_akhir": kmAkhir,
      "code": code,
      "total": total,
      "sales_id": salesId,
      "unit_bussiness_id": unitBusinessId,
      "note": note,
      "alasan": alasan,
      "approval_level": approvalLevel,
      "approval_count": approvalCount,
      "approved_count": approvedCount,
      "foto_awal": fotoAwal,
      "foto_akhir": fotoAkhir,
      "status": status,
    }..removeWhere((key, value) => value == null);
  }
}
