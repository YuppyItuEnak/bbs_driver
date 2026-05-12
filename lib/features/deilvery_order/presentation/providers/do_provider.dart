import 'dart:io';

import 'package:bbs_driver/data/models/delivery_order/delivery_plan_realisasi_model.dart';
import 'package:bbs_driver/data/models/delivery_order/delivery_order_detail.dart';
import 'package:bbs_driver/data/models/delivery_order/delivery_order_model.dart';
import 'package:bbs_driver/data/models/delivery_order/surat_jalan_realisasi_model.dart';
import 'package:bbs_driver/data/models/delivery_order/tracking_model.dart';
import 'package:bbs_driver/data/services/delivery_order/do_repository.dart';
import 'package:flutter/material.dart';

class DoProvider extends ChangeNotifier {
  final DoRepository _repository = DoRepository();

  // Home check-in/out state derived from today's t_delivery_plan_realisasi.
  // Values: check_in | check_out | done
  String _homeActionState = 'check_in';
  bool _hasConfirmedDo = false;
  bool _hasOutstandingDo = false;

  List<DeliveryOrderModel> _doList = [];
  int _doMasukTotal = 0;
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
  List<TrackingModel> _trackingList = [];
  List<TrackingModel> get trackingList => _trackingList;
  Map<String, dynamic> get checkInStatus => _checkInStatus;
  bool get canCheckIn => _checkInStatus['has_open'] == false;
  bool get hasConfirmedDo => _hasConfirmedDo;
  bool get hasOutstandingDo => _hasOutstandingDo;

  DpRealisasiModel? getDpRealisasi() => _repository.getDpRealisasi();

  String get homeActionState => _homeActionState;
  bool get homeCheckInEnabled =>
      _homeActionState == 'check_in' && _hasOutstandingDo;
  bool get homeCheckOutEnabled =>
      _homeActionState == 'check_out' && !_hasOutstandingDo;
  bool get homeDone => _homeActionState == 'done';

  List<DeliveryOrderModel> get doList => _doList;
  int get totalDoMasuk => _doList.length;
  int get doMasukTotal => _doMasukTotal;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  List<DeliveryOrderDetail> get details => _details;

  Future<void> fetchDoMasuk({
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
      final newList = await _repository.getListDOMasuk(
        token: token,
        userId: userId,
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

  Future<void> refreshDoMasukTotal({required String token}) async {
    try {
      _doMasukTotal = await _repository.getDoMasukTotal(token: token);
    } catch (_) {
      _doMasukTotal = 0;
    }
    notifyListeners();
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

  Future<void> fetchListDOSudahReceived({
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
      final newDoList = await _repository.getListDOSudahReceived(
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
      // GUARD: DO yang sudah punya realisasi open (time_out == null) tidak boleh dikonfirmasi lagi.
      // Ini mencegah kasus setelah check-in masih bisa "konfirmasi" DO.
      final openSj = await _repository.checkOpenTimeInSuratJalan(token: token);
      final openRows = (openSj['data'] as List?)?.cast<dynamic>() ?? [];

      bool isDoAlreadyCheckedIn(String doId) {
        for (final row in openRows) {
          if (row is! Map) continue;
          final sjId = row['t_surat_jalan_id']?.toString();
          final timeOut = row['time_out'];
          final open = timeOut == null || timeOut.toString().isEmpty;
          if (open && sjId == doId) return true;
        }
        return false;
      }

      for (final doId in doIds) {
        if (isDoAlreadyCheckedIn(doId)) {
          throw Exception(
            'DO ${doId} sudah check-in (realisasi open). Konfirmasi tidak bisa dilakukan lagi.',
          );
        }
      }

      await _repository.confirmDo(token: token, doIds: doIds, userId: userId);
      // After confirm, DO status becomes 4 (confirmed).
      // Status 5 is only when the DO/customer is checked-in.
      const toStatus = 4;
      for (final doId in doIds) {
        await _repository.updateDoStatus(
          token: token,
          doId: doId,
          status: toStatus,
        );
      }
      _hasConfirmedDo = true;
      await checkOpenTimeIn(token: token, userId: userId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkOpenTimeIn({required String token, String? userId}) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        final rows = await _repository.fetchTodayDeliveryPlanRealisasi(
          token: token,
          userId: userId,
        );

        bool hasOpen = false;
        bool hasCompleted = false;
        bool hasNotCheckedIn = false;
        for (final r in rows) {
          if (r is! Map) continue;
          final timeIn = r['time_in'];
          final timeOut = r['time_out'];
          if (timeIn == null || timeIn.toString().isEmpty) {
            if (timeOut == null || timeOut.toString().isEmpty) {
              hasNotCheckedIn = true;
            }
            continue;
          }
          if (timeOut == null || timeOut.toString().isEmpty) {
            hasOpen = true;
          } else {
            hasCompleted = true;
          }
        }

        _homeActionState = hasOpen
            ? 'check_out'
            : (hasNotCheckedIn || rows.isEmpty)
            ? 'check_in'
            : hasCompleted
            ? 'done'
            : 'check_in';

        // Jika state adalah 'check_out' tapi cache lokal kosong (misal: setelah app restart),
        // pulihkan state dari data yang di-fetch.
        if (_homeActionState == 'check_out' &&
            _repository.getDpRealisasi() == null) {
          final openRealisasiData = rows.firstWhere(
            (r) =>
                r is Map &&
                r['time_in'] != null &&
                (r['time_out'] == null || r['time_out'].toString().isEmpty),
            orElse: () => null,
          );

          if (openRealisasiData != null) {
            final model = DpRealisasiModel.fromJson(openRealisasiData);
            _repository.setCachedDpRealisasi(model);
          }
        }

        _checkInStatus = {
          'has_open': hasOpen,
          'total': rows.length,
          'data': rows,
        };
      } else {
        _checkInStatus = await _repository.checkOpenTimeIn(token: token);
      }
    } catch (e) {
      _checkInStatus = {'has_open': true, 'total': 0, 'data': []};
    }
    notifyListeners();
  }

  Future<void> refreshHasConfirmedDo({
    required String token,
    required String userId,
  }) async {
    try {
      _hasConfirmedDo = await _repository.hasConfirmedDo(
        token: token,
        userId: userId,
      );
    } catch (_) {
      _hasConfirmedDo = false;
    }
    notifyListeners();
  }

  Future<void> refreshHasOutstandingDo({
    required String token,
    required String userId,
  }) async {
    try {
      final confirmed = await fetchConfirmedDoForUser(
        token: token,
        userId: userId,
      );
      _hasOutstandingDo = confirmed.isNotEmpty;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<DeliveryOrderModel>> fetchConfirmedDoForUser({
    required String token,
    required String userId,
  }) async {
    return _repository.getListDOSudahConfirm(
      token: token,
      userId: userId,
      page: 1,
      paginate: 200,
    );
  }

  Future<List<String>> getConfirmedDeliveryPlanIds({
    required String token,
    required String userId,
  }) async {
    final list = await fetchConfirmedDoForUser(token: token, userId: userId);
    return list
        .map((e) => e.deliveryPlanId)
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<String> checkInDeliveryPlanOnly({
    required String token,
    required String deliveryPlanId,
    required String userId,
    required String timeIn,
    required String latIn,
    required String longIn,
    required String addressIn,
    required File photo,
  }) async {
    final dpRealisasiId = await _repository.checkIn(
      token: token,
      deliveryPlanId: deliveryPlanId,
      userId: userId,
      timeIn: timeIn,
      latIn: latIn,
      longIn: longIn,
      addressIn: addressIn,
      photo: photo,
    );

    await checkOpenTimeIn(token: token, userId: userId);
    return dpRealisasiId;
  }

  Future<void> checkIn({
    required String token,
    required List<String> doIds,
    String? deliveryPlanId,
    required String userId,
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
      final dpRealisasiId = await _repository.checkIn(
        token: token,
        deliveryPlanId: deliveryPlanId ?? '',
        userId: userId,
        timeIn: timeIn,
        latIn: latIn,
        longIn: longIn,
        addressIn: addressIn,
        photo: photo,
      );

      for (final doId in doIds) {
        await _repository.checkInSuratJalanRealisasi(
          token: token,
          suratJalanId: doId,
          userId: userId,
          dpRealisasiId: dpRealisasiId,
          timeIn: timeIn,
          latIn: latIn,
          longIn: longIn,
          addressIn: addressIn,
          photo: photo,
        );
        await _repository.updateDoStatus(token: token, doId: doId, status: 5);
      }

      await checkOpenTimeIn(token: token, userId: userId);
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
    required String realisasiId,
    required String deliveryPlanId,
    required String userId,
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
        realisasiId: realisasiId,
        deliveryPlanId: deliveryPlanId,
        userId: userId,
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

  Future<void> checkOutCustomerDos({
    required String token,
    required List<String> doIds,
    required String userId,
    required String timeOut,
    required String latOut,
    required String longOut,
    required String addressOut,
    required String duration,
    required File photo,
  }) async {
    final open = await _repository.checkOpenTimeInSuratJalan(token: token);
    final data = (open['data'] as List?)?.cast<dynamic>() ?? [];

    String? findRealisasiId(String doId) {
      for (final row in data) {
        if (row is! Map) continue;
        final sjId = row['t_surat_jalan_id']?.toString();
        final timeOut = row['time_out'];
        if (sjId == doId && (timeOut == null || timeOut.toString().isEmpty)) {
          final id = row['id']?.toString();
          if (id != null && id.isNotEmpty) return id;
        }
      }
      return null;
    }

    for (final doId in doIds) {
      final sjRealisasiId = findRealisasiId(doId);
      if (sjRealisasiId == null) continue;
      await _repository.checkOutSuratJalanRealisasi(
        token: token,
        realisasiId: sjRealisasiId,
        suratJalanId: doId,
        userId: userId,
        timeOut: timeOut,
        latOut: latOut,
        longOut: longOut,
        addressOut: addressOut,
        duration: duration,
        note: null,
        photo: photo,
      );
    }
  }

  Future<void> completeCustomerCheckout({
    required String token,
    required List<String> doIds,
    required String userId,
    required String timeOut,
    required String latOut,
    required String longOut,
    required String addressOut,
    required String duration,
    required File photo,
    required bool isFailed,
    String? note,
  }) async {
    // 1) Close SJ realisasi rows (per DO)
    final open = await _repository.checkOpenTimeInSuratJalan(token: token);
    final data = (open['data'] as List?)?.cast<dynamic>() ?? [];

    String? findRealisasiId(String doId) {
      for (final row in data) {
        if (row is! Map) continue;
        final sjId = row['t_surat_jalan_id']?.toString();
        final timeOut = row['time_out'];
        if (sjId == doId && (timeOut == null || timeOut.toString().isEmpty)) {
          final id = row['id']?.toString();
          if (id != null && id.isNotEmpty) return id;
        }
      }
      return null;
    }

    for (final doId in doIds) {
      final sjRealisasiId = findRealisasiId(doId);
      if (sjRealisasiId == null) continue;
      await _repository.checkOutSuratJalanRealisasi(
        token: token,
        realisasiId: sjRealisasiId,
        suratJalanId: doId,
        userId: userId,
        timeOut: timeOut,
        latOut: latOut,
        longOut: longOut,
        addressOut: addressOut,
        duration: duration,
        note: isFailed ? note : null,
        photo: photo,
      );
    }

    // 2) Mark all DOs as completed:
    // - success => 3
    // - failed  => 6
    final newStatus = isFailed ? 6 : 3;
    for (final doId in doIds) {
      await _repository.updateDoStatus(
        token: token,
        doId: doId,
        status: newStatus,
      );
    }
  }

  Future<bool> isDeliveryPlanCheckedOutToday({
    required String token,
    required String userId,
    required String deliveryPlanId,
  }) async {
    return _repository.isDeliveryPlanCheckedOutToday(
      token: token,
      userId: userId,
      deliveryPlanId: deliveryPlanId,
    );
  }

  Future<bool> hasOutstandingDoForDeliveryPlan({
    required String token,
    required String userId,
    required String deliveryPlanId,
  }) async {
    return _repository.hasOutstandingDoForDeliveryPlan(
      token: token,
      userId: userId,
      deliveryPlanId: deliveryPlanId,
    );
  }

  Future<void> updateDeliveryPlanStatusFromDoResult({
    required String token,
    required String userId,
    required String deliveryPlanId,
  }) async {
    // If any DO under DP has status 6 -> t_delivery_plan.status = 6
    // Else (all must be 3/6 by precondition) -> status = 5
    final has6 = await _repository.hasDoWithStatusForDeliveryPlan(
      token: token,
      userId: userId,
      deliveryPlanId: deliveryPlanId,
      status: '6',
    );
    await _repository.updateDeliveryPlanStatus(
      token: token,
      deliveryPlanId: deliveryPlanId,
      status: has6 ? 6 : 5,
    );
  }

  Future<SjRealisasiModel?> getOpenSjRealisasi({
    required String token,
    required List<String> doIds,
  }) async {
    try {
      return await _repository.getOpenSjRealisasi(token: token, doIds: doIds);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<SjRealisasiModel> startCustomerCheckin({
    required String token,
    required String doId,
    required String userId,
    required String timeIn,
    required String latIn,
    required String longIn,
    required String addressIn,
    required File photo,
  }) async {
    try {
      // 1. Mulai SJ Realisasi (check-in di lokasi)
      final sjRealisasi = await _repository.startSjRealisasi(
        token: token,
        doId: doId,
        userId: userId,
        timeIn: timeIn,
        latIn: latIn,
        longIn: longIn,
        addressIn: addressIn,
        photo: photo,
      );

      // 2. Update status DO menjadi 'dalam pengiriman' (status 5)
      await _repository.updateDoStatus(token: token, doId: doId, status: 5);

      return sjRealisasi;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateDoStatus({
    required String token,
    required String doId,
    required int status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateDoStatus(
        token: token,
        doId: doId,
        status: status,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTodayTracking({required String token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trackingList = await _repository.getTodayTracking(token: token);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
