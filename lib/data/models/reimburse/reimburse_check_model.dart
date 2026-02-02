class ReimburseCheckModel {
  final String id;
  final int? kmAwal;
  final int? kmAkhir;

  ReimburseCheckModel({required this.id, this.kmAwal, this.kmAkhir});

  factory ReimburseCheckModel.fromJson(Map<String, dynamic> json) {
    return ReimburseCheckModel(
      id: json['id'],
      kmAwal: json['km_awal'],
      kmAkhir: json['km_akhir'],
    );
  }
}
