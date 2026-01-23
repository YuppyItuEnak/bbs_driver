import 'package:bbs_driver/data/models/delivery_order/delivery_order_model.dart';
import 'package:bbs_driver/data/services/delivery_order/do_repository.dart';
import 'package:flutter/material.dart';

class DoProvider extends ChangeNotifier {
  final DoRepository _repository = DoRepository();

  bool _isLoading = false;
  String? _error;
  List<DeliveryOrderModel> _doList = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<DeliveryOrderModel> get doList => _doList;

  int get totalDoMasuk => _doList.length;

  Future<void> fetchDoMasuk({required String token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getListDOMasuk(token: token);
      _doList = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchListDOSudahConfirm({
    required String token,
    required String userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _doList = await _repository.getListDOSudahConfirm(
        token: token,
        userId: userId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
