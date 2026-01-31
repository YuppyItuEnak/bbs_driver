import 'dart:io';

import 'package:bbs_driver/data/models/delivery_order/delivery_order_detail.dart';
import 'package:bbs_driver/data/models/delivery_order/delivery_order_model.dart';
import 'package:bbs_driver/data/services/delivery_order/do_repository.dart';
import 'package:flutter/material.dart';

class DoProvider extends ChangeNotifier {
  final DoRepository _repository = DoRepository();

  List<DeliveryOrderModel> _doList = [];
  DeliveryOrderModel? _detailDO;
  DeliveryOrderModel? get detailDO => _detailDO;
  List<DeliveryOrderDetail> _details = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _hasMore = true;

  int _page = 1;
  final int _paginate = 10;

  String? _searchKeyword;
  String? _error;

  Map<String, dynamic> _checkInStatus = {
    'has_open': true,
    'total': 0,
    'data': [],
  };
  Map<String, dynamic> get checkInStatus => _checkInStatus;
  bool get canCheckIn => _checkInStatus['has_open'] == false;

  List<DeliveryOrderModel> get doList => _doList;
  int get totalDoMasuk => _doList.length;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  List<DeliveryOrderDetail> get details => _details;

  Future<void> fetchDoMasuk({
    required String token,
    bool isRefresh = false,
    String? search,
  }) async {
    if (isRefresh) {
      _page = 1;
      _hasMore = true;
      _doList = [];
      _isLoading = true;
      _searchKeyword = search;
    } else {
      if (_isFetchingMore || !_hasMore) return;
      _isFetchingMore = true;
    }

    _error = null;
    notifyListeners();

    try {
      final newList = await _repository.getListDOMasuk(
        token: token,
        page: _page,
        paginate: _paginate,
        search: _searchKeyword,
      );

      if (newList.length < _paginate) {
        _hasMore = false;
      }

      if (isRefresh) {
        _doList = newList;
      } else {
        _doList.addAll(newList);
      }

      _page++;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (isRefresh) {
        _isLoading = false;
      } else {
        _isFetchingMore = false;
      }
      notifyListeners();
    }
  }

  Future<void> fetchListDOSudahConfirm({
    required String token,
    required String userId,
    bool isRefresh = false,
    String? search,
  }) async {
    if (isRefresh) {
      _page = 1;
      _hasMore = true;
      _doList = [];
      _isLoading = true;
      _searchKeyword = search;
    } else {
      if (_isFetchingMore || !_hasMore) return;
      _isFetchingMore = true;
    }

    _error = null;
    notifyListeners();

    try {
      final newDoList = await _repository.getListDOSudahConfirm(
        token: token,
        userId: userId,
        page: _page,
        paginate: _paginate,
        search: _searchKeyword,
      );

      // kalau data < paginate → berarti halaman terakhir
      if (newDoList.length < _paginate) {
        _hasMore = false;
      }

      if (isRefresh) {
        _doList = newDoList;
      } else {
        _doList.addAll(newDoList);
      }

      _page++;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (isRefresh) {
        _isLoading = false;
      } else {
        _isFetchingMore = false;
      }
      notifyListeners();
    }
  }

  Future<void> fetchDetailDo({
    required String token,
    required String doId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _detailDO = await _repository.getDetailDo(token: token, doId: doId);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmDo({
    required String token,
    required List<String> doIds,
    required String userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.confirmDo(token: token, doIds: doIds, userId: userId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkOpenTimeIn({required String token}) async {
    try {
      _checkInStatus = await _repository.checkOpenTimeIn(token: token);
    } catch (e) {
      _checkInStatus = {'has_open': true, 'total': 0, 'data': []};
    }
    notifyListeners();
  }

  Future<void> checkIn({
    required String token,
    required String doId,
    required String timeIn,
    required String latIn,
    required String longIn,
    required String addressIn,
    required File photo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.checkIn(
        token: token,
        doId: doId,
        timeIn: timeIn,
        latIn: latIn,
        longIn: longIn,
        addressIn: addressIn,
        photo: photo,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkOut({
    required String token,
    required String checkInId,
    required String doId,
    required String timeOut,
    required String latOut,
    required String longOut,
    required String addressOut,
    required String duration,
    required File photo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.checkOut(
        token: token,
        checkInId: checkInId,
        doId: doId,
        timeOut: timeOut,
        latOut: latOut,
        longOut: longOut,
        addressOut: addressOut,
        duration: duration,
        photo: photo,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
