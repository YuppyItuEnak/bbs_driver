class DeliveryOrderModel {
  final String id;
  final String? deliveryPlanId;
  final String code;
  final String date;
  final int status;
  final bool siUsed;
  final bool isTaken;

  final String? customer;
  final String? shipTo;
  final String? deliveryArea;
  final String? vehicle;
  final String? nopol;
  final String? notes;

  DeliveryOrderModel({
    required this.id,
    this.deliveryPlanId,
    required this.code,
    required this.date,
    this.status = 0,
    this.siUsed = false,
    this.isTaken = false,
    this.customer,
    this.shipTo,
    this.deliveryArea,
    this.vehicle,
    this.nopol,
    this.notes,
  });

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderModel(
      id: json['id'],
      deliveryPlanId: json['delivery_plan_id'],
      code: json['code'],
      date: json['date'],
      status: json['status'],
      siUsed: json['si_used'] ?? false,
      isTaken: json['is_taken'] ?? false,
      customer: json['customer'],
      shipTo: json['ship_to'],
      deliveryArea: json['delivery_area'],
      vehicle: json['vehicle'],
      nopol: json['nopol'],
      notes: json['notes'],
    );
  }
}