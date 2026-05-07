import 'package:bbs_driver/data/models/delivery_order/delivery_order_detail.dart';

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
  final List<DeliveryOrderDetail> details;
  final SalesOrderModel? salesOrder;

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
    required this.details,
    this.salesOrder,
  });

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderModel(
      id: json['id'],
      deliveryPlanId: json['delivery_plan_id'],
      code: json['code'],
      date: json['date'],
      status: (json['status'] as num?)?.toInt() ?? 0,
      siUsed: json['si_used'] ?? false,
      isTaken: json['is_taken'] ?? false,
      customer: json['m_customer']['name'],
      shipTo: json['ship_to'],
      deliveryArea: json['delivery_area'],
      vehicle: json['vehicle'],
      nopol: json['nopol'],
      notes: json['notes'],
      details: (json['t_surat_jalan_ds'] as List? ?? [])
          .map((e) => DeliveryOrderDetail.fromJson(e))
          .toList(),

      salesOrder: json['t_sales_order'] != null
          ? SalesOrderModel.fromJson(json['t_sales_order'])
          : null,
    );
  }
}

class SalesOrderModel {
  final String id;
  final String code;
  final String date;
  final String estDate;
  final int status;

  final String unitBusiness;
  final String top;
  final String sales;
  final String expedition;
  final String expeditionType;

  final String shipToName;
  final String shipToAddress;
  final String customerName;

  final double dpp;
  final double dpp2;
  final double totalDisc;
  final double ppn;
  final double grandTotal;

  SalesOrderModel({
    required this.id,
    required this.code,
    required this.date,
    required this.estDate,
    required this.status,
    required this.unitBusiness,
    required this.top,
    required this.sales,
    required this.expedition,
    required this.expeditionType,
    required this.shipToName,
    required this.shipToAddress,
    required this.customerName,
    required this.dpp,
    required this.dpp2,
    required this.totalDisc,
    required this.ppn,
    required this.grandTotal,
  });

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderModel(
      id: json['id'],
      code: json['code'],
      date: json['date'],
      estDate: json['est_date'],
      status: (json['status'] as num?)?.toInt() ?? 0,

      unitBusiness: json['unit_bussiness'] ?? '-',
      top: json['top'] ?? '-',
      sales: json['sales'] ?? '-',
      expedition: json['expedition'] ?? '-',
      expeditionType: json['expedition_type'] ?? '-',

      shipToName: json['ship_to_name'] ?? '-',
      shipToAddress: json['ship_to_address'] ?? '-',
      customerName: json['customer_name'] ?? '-',

      dpp: (json['dpp'] ?? 0).toDouble(),
      dpp2: (json['dpp2'] ?? 0).toDouble(),
      totalDisc: (json['total_disc'] ?? 0).toDouble(),
      ppn: (json['ppn'] ?? 0).toDouble(),
      grandTotal: (json['grand_total'] ?? 0).toDouble(),
    );
  }
}
