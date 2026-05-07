class ComplainDetailModel {
  final String id;
  final String? code;
  final String? customer;
  final String? customerId;
  final String? refType;
  final String? siId;
  final String? sjId;
  final int? status;
  final DateTime? date;
  final String? reason;
  final String? notes;
  final String? complainType;
  final String? complainTypeId;
  final String? sales;
  final int? approvalCount;
  final int? approvedCount;
  final int? currentApprovalLevel;

  final List<ComplainItemModel> items;

  ComplainDetailModel({
    required this.id,
    this.code,
    this.customer,
    this.customerId,
    this.refType,
    this.siId,
    this.sjId,
    this.status,
    this.date,
    this.reason,
    this.notes,
    this.complainType,
    this.complainTypeId,
    this.sales,
    this.approvalCount,
    this.approvedCount,
    this.currentApprovalLevel,
    required this.items,
  });

  factory ComplainDetailModel.fromJson(Map<String, dynamic> json) {
    return ComplainDetailModel(
      id: json['id']?.toString() ?? '',
      code: json['code'],
      customer: json['customer'],
      customerId: json['customer_id']?.toString(),
      refType: json['ref_type'],
      siId: json['si_id']?.toString(),
      sjId: json['sj_id']?.toString(),
      status: json['status'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      reason: json['reason'],
      notes: json['notes'],
      complainType: json['complain_type'],
      complainTypeId: json['complain_type_id']?.toString(),
      sales: json['sales'],
      approvalCount: json['approval_count'],
      approvedCount: json['approved_count'],
      currentApprovalLevel: json['current_approval_level'],
      items: (json['t_complain_ds'] as List? ?? [])
          .map((e) => ComplainItemModel.fromJson(e))
          .toList(),
    );
  }
}

class ComplainItemModel {
  final String? id;
  final String? itemId;
  final String? itemName;
  final int? qtyRef;
  final int? qtyReturn;
  final String? uomUnit;
  final String? reasonId;
  final String? soId;
  final String? sjId;
  final List<ComplainImageModel> images;

  ComplainItemModel({
    this.id,
    this.itemId,
    this.itemName,
    this.qtyRef,
    this.qtyReturn,
    this.uomUnit,
    this.reasonId,
    this.soId,
    this.sjId,
    required this.images,
  });

  factory ComplainItemModel.fromJson(Map<String, dynamic> json) {
    return ComplainItemModel(
      id: json['id'],
      itemId: json['item_id'],
      itemName: json['item_name'],
      qtyRef: json['qty_ref'],
      qtyReturn: json['qty_return'],
      uomUnit: json['uom_unit'],
      reasonId: json['reason_id'],
      soId: json['so_id'],
      sjId: json['sj_id'],
      images: (json['t_complain_d_imagess'] as List? ?? [])
          .map((e) => ComplainImageModel.fromJson(e))
          .toList(),
    );
  }
}

class ComplainImageModel {
  final String? id;
  final String? imageUrl;

  ComplainImageModel({this.id, this.imageUrl});

  factory ComplainImageModel.fromJson(Map<String, dynamic> json) {
    return ComplainImageModel(id: json['id'], imageUrl: json['image_url']);
  }
}
