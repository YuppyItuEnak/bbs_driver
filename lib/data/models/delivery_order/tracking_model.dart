class TrackingModel {
  final String id;
  final String? doId;
  final String? doCode;
  final String? customerName;
  final double lat;
  final double long;
  final String? address;
  final String? timeIn;
  final String? timeOut;
  final String? duration;

  TrackingModel({
    required this.id,
    this.doId,
    this.doCode,
    this.customerName,
    required this.lat,
    required this.long,
    this.address,
    this.timeIn,
    this.timeOut,
    this.duration,
  });

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    return TrackingModel(
      id: json['id']?.toString() ?? '',
      doId: json['t_surat_jalan_id']?.toString(),
      doCode: json['do_code']?.toString(),
      customerName: json['customer_name']?.toString(),
      lat: double.tryParse(json['lat_in']?.toString() ?? '0') ?? 0.0,
      long: double.tryParse(json['long_in']?.toString() ?? '0') ?? 0.0,
      address: json['address_in']?.toString(),
      timeIn: json['time_in']?.toString(),
      timeOut: json['time_out']?.toString(),
      duration: json['durasi']?.toString(),
    );
  }

  bool get isCompleted => timeOut != null && timeOut!.isNotEmpty;
}
