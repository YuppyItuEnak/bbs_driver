import 'dart:io';
import 'package:bbs_driver/data/models/reimburse/reimburse_add_model.dart';
import 'package:bbs_driver/data/models/reimburse/reimburse_check_model.dart';
import 'package:bbs_driver/data/models/reimburse/reimburse_detail_model.dart';
import 'package:bbs_driver/data/models/reimburse/reimburse_model.dart';
import 'package:bbs_driver/data/services/reimburse/reimburse_repository.dart';
import 'package:flutter/material.dart';

class ReimburseProvider extends ChangeNotifier {
  final ReimburseRepository _repo = ReimburseRepository();

  List<ReimburseModel> _items = [];
  ReimburseDetailModel? _selected;
  ReimburseCheckModel? _reimburseCheck;

  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  int _page = 1;
  final int _paginate = 25;

  String? _error;
  String? _search;

  // GETTERS
  List<ReimburseModel> get items => _items;
  ReimburseDetailModel? get selected => _selected;
  ReimburseCheckModel? get reimburseCheck => _reimburseCheck;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  void setSearch(String? val) {
    _search = val;
    notifyListeners();
  }

  // ================= LIST =================
  Future<void> fetch({
    required String token,
    required String salesId,
    bool refresh = false,
  }) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _items.clear();
      _isLoading = true;
    } else {
      if (_isFetchingMore || !_hasMore) return;
      _isFetchingMore = true;
    }

    notifyListeners();

    try {
      final data = await _repo.fetchReimburse(
        token: token,
        salesId: salesId,
        page: _page,
        paginate: _paginate,
        search: _search,
      );

      if (data.length < _paginate) _hasMore = false;

      _items.addAll(data);
      _page++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> getDetail(String token, String id) async {
    _selected = null;
    notifyListeners();

    try {
      _selected = await _repo.fetchDetailReimburse(token: token, id: id);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<ReimburseModel?> create(
    String token,
    ReimburseCreateModel data,
    File? fotoAwal,
    File? fotoAkhir,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final createdReimburse = await _repo.createReimburse(
        token: token,
        data: data,
        fotoAwal: fotoAwal,
        fotoAkhir: fotoAkhir,
      );
      _isLoading = false;
      notifyListeners();
      return createdReimburse;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> requestApproval({
    required String token,
    required String reimburseId,
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repo.requestApproval(
        token: token,
        reimburseId: reimburseId,
        userId: userId,
      );
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> checkReimburseToday({
    required String token,
    required String salesId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reimburseCheck =
          await _repo.checkReimburseToday(token: token, salesId: salesId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> update(
    String token,
    String id,
    ReimburseCreateModel data,
  ) async {
    try {
      await _repo.updateReimburse(token: token, id: id, data: data);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
