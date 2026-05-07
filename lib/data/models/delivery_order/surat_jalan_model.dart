class SuratJalanModel {
  final String? id;
  final String? deliveryPlanId;
  final DateTime? date;
  final int? status;
  final String? unitBussinessId;
  final String code;
  final int? printCount;
  final String? customerId;
  final String? topId;
  final String? shipTo;
  final String? npwp;
  final String? soId;
  final String? unitBussiness;
  final String? customer;
  final String? deliveryArea;
  final String? vehicle;
  final String? nopol;
  final String? expeditionType;
  final String? notes;
  final bool? siUsed;
  final String? createdBy;
  final String? updatedBy;
  final double? jurnalAmount;
  final bool? isTaken;
  final String? takenBy;

  final List<SuratJalanDetailModel> details;

  SuratJalanModel({
    this.id,
    this.deliveryPlanId,
    this.date,
    this.status,
    this.unitBussinessId,
    required this.code,
    this.printCount,
    this.customerId,
    this.topId,
    this.shipTo,
    this.npwp,
    this.soId,
    this.unitBussiness,
    this.customer,
    this.deliveryArea,
    this.vehicle,
    this.nopol,
    this.expeditionType,
    this.notes,
    this.siUsed,
    this.createdBy,
    this.updatedBy,
    this.jurnalAmount,
    this.isTaken,
    this.takenBy,
    required this.details,
  });

  factory SuratJalanModel.fromJson(Map<String, dynamic> json) {
    return SuratJalanModel(
      id: json['id'],
      deliveryPlanId: json['delivery_plan_id'],
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : null,
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '0'),
      unitBussinessId: json['unit_bussiness_id'],
      code: json['code'] ?? '',
      printCount: json['print_count'] is int
          ? json['print_count']
          : int.tryParse(json['print_count']!.toString()),
      customerId: json['customer_id'],
      topId: json['top_id'],
      shipTo: json['ship_to'],
      npwp: json['npwp'],
      soId: json['so_id'],
      unitBussiness: json['unit_bussiness'],
      customer: json['customer'],
      deliveryArea: json['delivery_area'],
      vehicle: json['vehicle'],
      nopol: json['nopol'],
      expeditionType: json['expedition_type'],
      notes: json['notes'],
      siUsed: json['si_used'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      jurnalAmount: (json['jurnal_amount'] as num?)?.toDouble(),
      isTaken: json['is_taken'],
      takenBy: json['taken_by'],
      details: (json['t_surat_jalan_ds'] as List<dynamic>? ?? [])
          .map((e) => SuratJalanDetailModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SuratJalanDetailModel {
  final String? suratJalanId;
  final String? itemId;
  final int? qty;
  final double? price;
  final double? amount;
  final double? weight;
  final int? qtyReturn;
  final String? itemName;
  final int? qtySnapshot;
  final String uomUnit;
  final int uomValue;
  final String? uomId;
  final int? qtyInventory;
  final double? resultCogs;

  SuratJalanDetailModel({
    this.suratJalanId,
    this.itemId,
    this.qty,
    this.price,
    this.amount,
    this.weight,
    this.qtyReturn,
    this.itemName,
    this.qtySnapshot,
    required this.uomUnit,
    required this.uomValue,
    this.uomId,
    this.qtyInventory,
    this.resultCogs,
  });

  factory SuratJalanDetailModel.fromJson(Map<String, dynamic> json) {
    return SuratJalanDetailModel(
      suratJalanId: json['surat_jalan_id'],
      itemId: json['item_id'],
      qty: json['qty'] is int
          ? json['qty']
          : int.tryParse(json['qty']!.toString()),
      price: (json['price'] as num?)?.toDouble(),
      amount: (json['amount'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      qtyReturn: json['qty_return'] is int
          ? json['qty_return']
          : int.tryParse(json['qty_return']!.toString()),
      itemName: json['item_name'],
      qtySnapshot: json['qty_snapshot'] is int
          ? json['qty_snapshot']
          : int.tryParse(json['qty_snapshot']!.toString()),
      uomUnit: json['uom_unit'] as String,
      uomValue: json['uom_value'] is int
          ? json['uom_value']
          : int.tryParse(json['uom_value']?.toString() ?? '0') ?? 0,
      uomId: json['uom_id'],
      qtyInventory: json['qty_inventory'] is int
          ? json['qty_inventory']
          : int.tryParse(json['qty_inventory']!.toString()),
      resultCogs: (json['result_cogs'] as num?)?.toDouble(),
    );
  }
}
