class DpRealisasiModel {
  final String id;
  final String timeIn;
  final String? timeOut;
  final String latIn;
  final String longIn;
  final String? latOut;
  final String? longOut;
  final String? addressIn;
  final String? addressOut;
  final String? durasi;
  final String? note;
  final String? fotoIn;
  final String? fotoOut;
  final String userId;
  final String? date;
  final String? createdAt;
  final String? updatedAt;

  DpRealisasiModel({
    required this.id,
    required this.timeIn,
    this.timeOut,
    required this.latIn,
    required this.longIn,
    this.latOut,
    this.longOut,
    this.addressIn,
    this.addressOut,
    this.durasi,
    this.note,
    this.fotoIn,
    this.fotoOut,
    required this.userId,
    this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory DpRealisasiModel.fromJson(Map<String, dynamic> json) {
    return DpRealisasiModel(
      id: json['id'],
      timeIn: json['time_in'],
      timeOut: json['time_out'],
      latIn: json['lat_in'],
      longIn: json['long_in'],
      latOut: json['lat_out'],
      longOut: json['long_out'],
      addressIn: json['address_in'],
      addressOut: json['address_out'],
      durasi: json['durasi'],
      note: json['note'],
      fotoIn: json['foto_in'],
      fotoOut: json['foto_out'],
      userId: json['user_id'],
      date: json['date'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
