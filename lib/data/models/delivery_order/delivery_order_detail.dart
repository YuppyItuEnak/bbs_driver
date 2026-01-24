class DeliveryOrderDetail {
  final String id;
  final String suratJalanId;
  final String itemId;
  final int qty;
  final double price;
  final double amount;
  final double weight;
  final int qtyReturn;
  final int qtySnapshot;
  final String uomUnit;
  final int uomValue;
  final String uomId;
  final int? qtyInventory;
  final double? resultCogs;

  /// 🔥 relasi item
  final ItemModel? item;

  DeliveryOrderDetail({
    required this.id,
    required this.suratJalanId,
    required this.itemId,
    required this.qty,
    required this.price,
    required this.amount,
    required this.weight,
    required this.qtyReturn,
    required this.qtySnapshot,
    required this.uomUnit,
    required this.uomValue,
    required this.uomId,
    this.qtyInventory,
    this.resultCogs,
    this.item,
  });

  factory DeliveryOrderDetail.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderDetail(
      id: json['id'],
      suratJalanId: json['surat_jalan_id'],
      itemId: json['item_id'],
      qty: json['qty'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      qtyReturn: json['qty_return'] ?? 0,
      qtySnapshot: json['qty_snapshot'] ?? 0,
      uomUnit: json['uom_unit'] ?? '',
      uomValue: json['uom_value'] ?? 1,
      uomId: json['uom_id'] ?? '',
      qtyInventory: json['qty_inventory'],
      resultCogs: json['result_cogs']?.toDouble(),

      /// 🔥 nested item
      item: json['m_item'] != null ? ItemModel.fromJson(json['m_item']) : null,
    );
  }
}

class ItemModel {
  final String id;
  final String code;
  final String name;
  final String dimension;
  final String thickness;
  final String length;
  final int actualWeight;
  final int marketingWeight;
  final String photo;

  ItemModel({
    required this.id,
    required this.code,
    required this.name,
    required this.dimension,
    required this.thickness,
    required this.length,
    required this.actualWeight,
    required this.marketingWeight,
    required this.photo,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      dimension: json['dimension'] ?? '',
      thickness: json['thickness'] ?? '',
      length: json['length'] ?? '',
      actualWeight: json['actual_weight'] ?? 0,
      marketingWeight: json['marketing_weight'] ?? 0,
      photo: json['photo'] ?? '',
    );
  }
}
