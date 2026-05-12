
class TSJRealisasiLightModel {
  final String? id;
  final String? tSuratJalanId;
  final String? timeOut;

  const TSJRealisasiLightModel({
    this.id,
    this.tSuratJalanId,
    this.timeOut,
  });

  factory TSJRealisasiLightModel.fromJson(Map<String, dynamic> json) {
    return TSJRealisasiLightModel(
      id: json['id']?.toString(),
      tSuratJalanId: json['t_surat_jalan_id']?.toString(),
      timeOut: json['time_out']?.toString(),
    );
  }

  bool get hasTimeOut => timeOut != null && timeOut!.isNotEmpty;
}

