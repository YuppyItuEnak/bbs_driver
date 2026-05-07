import 'package:bbs_driver/data/models/delivery_order/surat_jalan_model.dart';
import 'package:bbs_driver/data/services/delivery_order/surat_jalan_repository.dart';
import 'package:flutter/material.dart';

class ReturnItemProvider extends ChangeNotifier {
  final SuratJalanRepository _sjRepo = SuratJalanRepository();

  List<SuratJalanDetailModel> _sjDetails = [];
  List<SelectedItem> _selectedItems = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<SuratJalanDetailModel> get sjDetails => _sjDetails;
  List<SelectedItem> get selectedItems => _selectedItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSJDetails({
    required String token,
    required String sjId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final sjDetail = await _sjRepo.fetchSuratJalanDetail(
        token: token,
        id: sjId,
      );
      _sjDetails = sjDetail.details;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSJItemSelection(SuratJalanDetailModel item, bool selected) {
    if (selected) {
      _selectedItems.add(SelectedItem.fromSJDetail(item));
    } else {
      _selectedItems.removeWhere(
        (selectedItem) => selectedItem.itemId == item.itemId,
      );
    }
    notifyListeners();
  }


  void clearSelections() {
    _selectedItems.clear();
    notifyListeners();
  }

  void updateQuantity(String itemId, int qtyReturn, int qtyReplaced) {
    final index = _selectedItems.indexWhere((item) => item.itemId == itemId);
    if (index != -1) {
      _selectedItems[index].qtyReturn = qtyReturn;
      _selectedItems[index].qtyReplaced = qtyReplaced;
      notifyListeners();
    }
  }

  SelectedItem? findSelectedItem(String itemId) {
    try {
      return _selectedItems.firstWhere((item) => item.itemId == itemId);
    } catch (e) {
      return null;
    }
  }
}

class SelectedItem {
  final String? itemId;
  final String? itemName;
  final int? qty;
  final String? uomUnit;
  final int? uomValue;
  int qtyReturn;
  int qtyReplaced;

  SelectedItem({
    this.itemId,
    this.itemName,
    this.qty,
    this.uomUnit,
    this.uomValue,
    this.qtyReturn = 0,
    this.qtyReplaced = 0,
  });

  factory SelectedItem.fromSJDetail(SuratJalanDetailModel detail) {
    return SelectedItem(
      itemId: detail.itemId,
      itemName: detail.itemName,
      qty: detail.qty,
      uomUnit: detail.uomUnit,
      uomValue: detail.uomValue,
    );
  }
}
