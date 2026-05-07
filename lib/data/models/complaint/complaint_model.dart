class ComplaintModel {
  final String id;
  final String? customer;
  final String? refType;
  final int? status;
  final DateTime? date;

  ComplaintModel({
    required this.id,
    this.customer,
    this.refType,
    this.status,
    this.date,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'],
      customer: json['customer'],
      refType: json['ref_type'],
      status: json['status'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }
}
