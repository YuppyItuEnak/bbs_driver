import 'package:bbs_driver/data/models/complaint/complaint_model.dart';
import 'package:bbs_driver/data/services/complaint/complaint_repository.dart';
import 'package:flutter/material.dart';

class ComplaintListProvider extends ChangeNotifier {
  final ComplainRepository _repository = ComplainRepository();

  List<ComplaintModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<ComplaintModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchComplaints({
    required String token,
    required String salesId,
    required String unitBusinessId,
    String? search,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.fetchListComplaint(
        token: token,
        salesId: salesId,
        unitBusinessId: unitBusinessId,
        search: search,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
