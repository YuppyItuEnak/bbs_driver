class ReimburseModel {
  final String id;
  final String type;
  final DateTime date;
  final int kmAwal;
  final int kmAkhir;
  final String code;
  final String status;

  ReimburseModel({
    required this.id,
    required this.type,
    required this.date,
    required this.kmAwal,
    required this.kmAkhir,
    required this.code,
    required this.status,
  });

  factory ReimburseModel.fromJson(Map<String, dynamic> json) {
    return ReimburseModel(
      id: json['id'],
      type: json['type'] ?? '',
      date: DateTime.parse(json['date']),
      kmAwal: (json['km_awal'] as num).toInt(),
      kmAkhir: (json['km_akhir'] as num).toInt(),
      code: json['code'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type,
      "date": date.toIso8601String().split('T').first,
      "km_awal": kmAwal,
      "km_akhir": kmAkhir,
      "code": code,
    };
  }

  int get totalKm => kmAkhir - kmAwal;
}
