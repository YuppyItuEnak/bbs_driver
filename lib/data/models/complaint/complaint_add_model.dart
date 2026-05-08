import 'dart:io';

class ComplainCreateModel {
  String? unitBusinessId;
  String? unitBusiness;
  String? customerId;
  String? customer;
  String? refType;
  String? reason;
  String? complainTypeId;
  String? complainType;
  String? salesId;
  String? sales;
  String? sjId;
  String? siId;
  String? notes;
  int? status;
  DateTime? date;
  String? requestApprovalBy;
  DateTime? requestApprovalAt;
  String? createdBy;
  String? updatedBy;

  List<ComplainCreateItemModel> items = [];

  Map<String, dynamic> toJson() {
    return {
      "unit_bussiness_id": unitBusinessId,
      "unit_bussiness": unitBusiness,
      "customer_id": customerId,
      "customer": customer,
      "ref_type": refType,
      "reason": reason,
      "complain_type_id": complainTypeId,
      "complain_type": complainType,
      "sales_id": salesId,
      "sales": sales,
      "sj_id": sjId,
      "si_id": siId,
      "notes": notes,
      "status": status,
      "date": date?.toIso8601String().split('T').first,
      "request_approval_by": requestApprovalBy,
      "request_approval_at": requestApprovalAt?.toUtc().toIso8601String(),
      "created_by": createdBy,
      "updated_by": updatedBy,
      "t_complain_ds": items.map((e) => e.toJson()).toList(),
    }..removeWhere((k, v) => v == null);
  }
}

class ComplainCreateItemModel {
  String? itemId;
  String? itemName;
  int? qtyRef;
  int? qtyReturn;
  int? qtyReplaced;
  String? uomUnit;
  String? reasonId;
  String? soId;
  String? sjId;
  List<String> imageUrls = [];
  List<File> imageFiles = [];

  Map<String, dynamic> toJson() {
    return {
      "item_id": itemId,
      "item_name": itemName,
      "qty_ref": qtyRef,
      "qty_return": qtyReturn,
      "qty_replaced": qtyReplaced,
      "uom_unit": uomUnit,
      "reason_id": reasonId,
      "so_id": soId,
      "sj_id": sjId,
      "t_complain_d_imagess": imageUrls.map((e) => {"image_url": e}).toList(),
    }..removeWhere((k, v) => v == null);
  }
}
