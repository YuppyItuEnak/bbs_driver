import 'dart:convert';
import 'dart:io';

import 'package:bbs_driver/core/constants/api_constants.dart';
import 'package:bbs_driver/data/models/delivery_order/delivery_order_model.dart';
import 'package:bbs_driver/data/models/delivery_order/delivery_plan_realisasi_model.dart';
import 'package:bbs_driver/data/models/delivery_order/surat_jalan_realisasi_model.dart';
import 'package:bbs_driver/data/models/delivery_order/tracking_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class DoRepository {
  final String baseUrl = ApiConstants.baseUrl;

  DpRealisasiModel? _cachedDpRealisasi;
  DpRealisasiModel? getDpRealisasi() => _cachedDpRealisasi;

  void setCachedDpRealisasi(DpRealisasiModel model) {
    _cachedDpRealisasi = model;
    print("[CACHE] DP Realisasi state recovered and cached. ID: ${model.id}");
  }

  void resetDpRealisasi() {
    _cachedDpRealisasi = null;
    print("[CACHE] DP Realisasi cache has been reset.");
  }

  // Mendapatkan SJ Realisasi yang masih open (time_out is null)
  Future<SjRealisasiModel?> getOpenSjRealisasi({
    required String token,
    required List<String> doIds,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan_realisasi').replace(
        queryParameters: {
          'filter_in_t_surat_jalan_id': doIds.join(','),
          'filter_is_null_time_out': 'true',
          'limit': '1',
        },
      );

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);
        final List<dynamic> data = parsed['data'];
        if (data.isNotEmpty) {
          return SjRealisasiModel.fromJson(data.first);
        }
        return null; // Tidak ada realisasi yang open
      } else {
        throw Exception(
          'Failed to get open SJ realisasi: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('[SJ_REALISASI] Get Open Error: ${e.toString()}');
      rethrow;
    }
  }

  // Memulai SJ Realisasi (Check-in di lokasi customer)
  Future<SjRealisasiModel> startSjRealisasi({
    required String token,
    required String doId, // Hanya satu DO ID saat memulai
    required String userId,
    required String timeIn,
    required String latIn,
    required String longIn,
    required String addressIn,
    required File photo,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan_realisasi');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['t_surat_jalan_id'] = doId
        ..fields['user_id'] = userId
        ..fields['time_in'] = timeIn
        ..fields['lat_in'] = latIn
        ..fields['long_in'] = longIn
        ..fields['address_in'] = addressIn
        ..files.add(
          await http.MultipartFile.fromPath(
            'foto_in',
            photo.path,
            filename: basename(photo.path),
          ),
        );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = json.decode(responseBody);
        return SjRealisasiModel.fromJson(parsed['data']);
      } else {
        throw Exception(
          'Failed to start SJ realisasi: ${response.statusCode} $responseBody',
        );
      }
    } catch (e) {
      print('[SJ_REALISASI] Start Error: ${e.toString()}');
      rethrow;
    }
  }

  String _dateOnly(DateTime dt) => dt.toIso8601String().split('T').first;

  Future<int> getDoMasukTotal({required String token}) async {
    // Use paginate=1 and read pagination.total so Home can show remaining DO count.
    final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan').replace(
      queryParameters: {
        'filter_column_status': '2',
        'filter_column_is_taken': 'false',
        'page': '1',
        'paginate': '1',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed get DO masuk total: ${response.statusCode}');
    }

    final body = json.decode(response.body);
    final pagination = (body is Map<String, dynamic>)
        ? (body['pagination'] as Map<String, dynamic>?)
        : null;
    final total = pagination?['total'];
    return (total as num?)?.toInt() ?? 0;
  }

  String? _tryExtractId(dynamic body) {
    try {
      if (body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          final id = data['id']?.toString();
          if (id != null && id.isNotEmpty) return id;
        }
        final id = body['id']?.toString();
        if (id != null && id.isNotEmpty) return id;
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _getTodayDeliveryPlanRealisasiId({
    required String token,
    required String userId,
    required String deliveryPlanId,
    required String dateOnly,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/t_delivery_plan_realisasi').replace(
      queryParameters: {
        'where': 'date=$dateOnly',
        'filter_column_user_id': userId,
        'paginate': '200',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) return null;

    final body = json.decode(response.body);
    final data = (body is Map<String, dynamic>)
        ? (body['data'] as List?)
        : null;
    if (data == null) return null;

    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;
      final dpId = item['delivery_plan_id']?.toString();
      if (dpId != deliveryPlanId) continue;
      final id = item['id']?.toString();
      if (id != null && id.isNotEmpty) return id;
    }
    return null;
  }

  Future<List<dynamic>> fetchTodayDeliveryPlanRealisasi({
    required String token,
    required String userId,
    String? dateOnly,
  }) async {
    final today = dateOnly ?? _dateOnly(DateTime.now());
    final uri = Uri.parse('$baseUrl/dynamic/t_delivery_plan_realisasi').replace(
      queryParameters: {
        'where': 'date=$today',
        'filter_column_user_id': userId,
        'paginate': '200',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed fetch dp realisasi today: ${response.statusCode} ${response.body}',
      );
    }

    final body = json.decode(response.body);
    final data = (body is Map<String, dynamic>)
        ? (body['data'] as List?)
        : null;
    return data ?? [];
  }

  Future<bool> hasConfirmedDo({
    required String token,
    required String userId,
  }) async {
    // Confirmed DO statuses: 4 (confirmed) / 5 (in progress).
    for (final status in const ['4', '5']) {
      final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan').replace(
        queryParameters: {
          'filter_column_status': status,
          'filter_column_is_taken': 'true',
          'filter_column_taken_by': userId,
          'paginate': '1',
          'page': '1',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) continue;
      final body = json.decode(response.body);
      final data = (body is Map<String, dynamic>)
          ? (body['data'] as List?)
          : null;
      if ((data ?? []).isNotEmpty) return true;
    }
    return false;
  }

  Future<bool> hasOutstandingDo({
    required String token,
    required String userId,
  }) async {
    // Outstanding: status 4 (confirmed) or 5 (checked-in customer, in progress).
    for (final status in const ['4', '5']) {
      final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan').replace(
        queryParameters: {
          'filter_column_status': status,
          'filter_column_is_taken': 'true',
          'filter_column_taken_by': userId,
          'paginate': '1',
          'page': '1',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) continue;
      final body = json.decode(response.body);
      final data = (body is Map<String, dynamic>)
          ? (body['data'] as List?)
          : null;
      if ((data ?? []).isNotEmpty) return true;
    }
    return false;
  }

  Future<String> upsertDeliveryPlanRealisasiCheckIn({
    required String token,
    String? deliveryPlanId,
    required String userId,
    required String timeIn,
    required String latIn,
    required String longIn,
    required String addressIn,
    required File photo,
  }) async {
    final today = _dateOnly(DateTime.now());

    // Try to find today's dp_realisasi first (so we can PUT if exists).
    final existingId = await _getTodayDeliveryPlanRealisasiId(
      token: token,
      userId: userId,
      deliveryPlanId: deliveryPlanId ?? '',
      dateOnly: today,
    );

    final isUpdate = existingId != null && existingId.isNotEmpty;
    final uri = isUpdate
        ? Uri.parse('$baseUrl/dynamic/t_delivery_plan_realisasi/$existingId')
        : Uri.parse('$baseUrl/dynamic/t_delivery_plan_realisasi');

    final method = isUpdate ? 'PUT' : 'POST';
    if (kDebugMode) {
      debugPrint('[DP_REALISASI] $method $uri');
      debugPrint(
        '[DP_REALISASI] payload: delivery_plan_id=${deliveryPlanId ?? 'null'} user_id=$userId date=$today time_in=$timeIn lat_in=$latIn long_in=$longIn',
      );
      debugPrint('[DP_REALISASI] address_in=$addressIn');
      debugPrint('[DP_REALISASI] foto_in=${photo.path}');
    }
    final request = http.MultipartRequest(method, uri);
    request.headers['Authorization'] = 'Bearer $token';

    if (deliveryPlanId != null && deliveryPlanId.isNotEmpty) {
      request.fields['delivery_plan_id'] = deliveryPlanId;
    }
    request.fields['user_id'] = userId;
    request.fields['date'] = today;
    request.fields['time_in'] = timeIn;
    request.fields['lat_in'] = latIn;
    request.fields['long_in'] = longIn;
    request.fields['address_in'] = addressIn;

    request.files.add(await http.MultipartFile.fromPath('foto_in', photo.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    if (kDebugMode) {
      debugPrint('[DP_REALISASI] response: ${response.statusCode}');
      debugPrint('[DP_REALISASI] body: $responseBody');
    }
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Failed to check in delivery plan: ${response.statusCode} - $responseBody',
      );
    }

    final parsed = json.decode(responseBody);
    if (parsed['data'] != null) {
      _cachedDpRealisasi = DpRealisasiModel.fromJson(parsed['data']);
      final createdId = _cachedDpRealisasi?.id;
      if (createdId != null && createdId.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('[DP_REALISASI] extracted id from cache: $createdId');
        }
        return createdId;
      }
    }

    // Fallback to original extraction method if cache or its ID is null
    final createdId = _tryExtractId(parsed);
    if (kDebugMode) {
      debugPrint('[DP_REALISASI] extracted id: ${createdId ?? "-"}');
    }
    if (createdId != null && createdId.isNotEmpty) return createdId;

    // Fallback: re-fetch to get id (some servers don't return full JSON for multipart).
    final fetchedId = await _getTodayDeliveryPlanRealisasiId(
      token: token,
      userId: userId,
      deliveryPlanId: deliveryPlanId ?? '',
      dateOnly: today,
    );
    if (kDebugMode) {
      debugPrint('[DP_REALISASI] refetch id: ${fetchedId ?? "-"}');
    }
    if (fetchedId != null && fetchedId.isNotEmpty) return fetchedId;

    throw Exception('dp_realisasi tidak ditemukan setelah check-in.');
  }

  Future<void> updateDeliveryPlanRealisasiCheckOut({
    required String token,
    required String dpRealisasiId,
    required String timeOut,
    required String latOut,
    required String longOut,
    required String duration,
    required String addressOut,
    required File photo,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/dynamic/t_delivery_plan_realisasi/$dpRealisasiId',
    );
    if (kDebugMode) {
      final payload = {
        'dp_realisasi_id': dpRealisasiId,
        'time_out': timeOut,
        'lat_out': latOut,
        'long_out': longOut,
        'durasi': duration,
        'address_out': addressOut,
        'foto_out': photo.path,
      };
      debugPrint('[DP_REALISASI] CHECK-OUT');
      debugPrint('[DP_REALISASI] PUT $uri');
      debugPrint('[DP_REALISASI] DATA SENT: ${jsonEncode(payload)}');
    }
    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['time_out'] = timeOut;
    request.fields['lat_out'] = latOut;
    request.fields['long_out'] = longOut;
    request.fields['durasi'] = duration;
    request.fields['address_out'] = addressOut;

    request.files.add(
      await http.MultipartFile.fromPath('foto_out', photo.path),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    if (kDebugMode) {
      debugPrint('[DP_REALISASI] response: ${response.statusCode}');
      debugPrint('[DP_REALISASI] body: $responseBody');
    }
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to check out delivery plan: ${response.statusCode} - $responseBody',
      );
    }
    resetDpRealisasi();
  }

  Future<void> checkInSuratJalanRealisasi({
    required String token,
    required String suratJalanId,
    required String userId,
    required String dpRealisasiId,
    required String timeIn,
    required String latIn,
    required String longIn,
    required String addressIn,
    required File photo,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan_realisasi');
    if (kDebugMode) {
      debugPrint('[SJ_REALISASI] POST $uri');
      debugPrint(
        '[SJ_REALISASI] payload: t_surat_jalan_id=$suratJalanId user_id=$userId dp_realisasi=$dpRealisasiId time_in=$timeIn lat_in=$latIn long_in=$longIn',
      );
      debugPrint('[SJ_REALISASI] address_in=$addressIn');
      debugPrint('[SJ_REALISASI] foto_in=${photo.path}');
    }
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['t_surat_jalan_id'] = suratJalanId;
    request.fields['user_id'] = userId;
    request.fields['dp_realisasi'] = dpRealisasiId;
    request.fields['time_in'] = timeIn;
    request.fields['lat_in'] = latIn;
    request.fields['long_in'] = longIn;
    request.fields['address_in'] = addressIn;

    request.files.add(await http.MultipartFile.fromPath('foto_in', photo.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    if (kDebugMode) {
      debugPrint('[SJ_REALISASI] response: ${response.statusCode}');
      debugPrint('[SJ_REALISASI] body: $responseBody');
    }
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Failed to check in customer: ${response.statusCode} - $responseBody',
      );
    }
  }

  Future<List<DeliveryOrderModel>> getListDOMasuk({
    required String token,
    required String userId,
    String? search,
    int page = 1,
    int paginate = 10,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'filter_column_status': '2', // posted
        'filter_column_si_used': 'false',
        'filter_column_is_taken': 'false',
        'filter_column_driver_id': userId,
        'order_by': 'delivery_plan_id',
        'page': page.toString(),
        'paginate': paginate.toString(),
        'include': 'm_customer',
      };

      // 🔍 search (opsional)
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
        queryParams['searchfield'] = 'code,nopol,m_customer.name';
      }

      final uri = Uri.parse(
        '$baseUrl/dynamic/t_surat_jalan',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 DO URI: $uri');
      print('📥 DO Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'];

        return data
            .map<DeliveryOrderModel>((e) => DeliveryOrderModel.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed get DO list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getListDOMasuk: $e');
    }
  }

  Future<List<DeliveryOrderModel>> getListDOSudahConfirm({
    required String token,
    required String userId,
    String? search,
    int page = 1,
    int paginate = 10,
  }) async {
    try {
      // Rule:
      // - Jika masih ada DO status=4 -> tampilkan hanya status=4
      // - Jika tidak ada status=4 -> tampilkan status=5
      Future<List<DeliveryOrderModel>> fetchByStatus(String status) async {
        final Map<String, String> queryParams = {
          'filter_column_status': status,
          'filter_column_is_taken': 'true',
          'filter_column_taken_by': userId,
          'page': page.toString(),
          'paginate': paginate.toString(),
          // kebutuhan: cek status realisasi per DO
          // (t_surat_jalan_realisasi berisi time_out)
          'include': 'm_customer,t_surat_jalan_realisasi',
        };
        if (search != null && search.isNotEmpty) {
          queryParams['search'] = search;
          queryParams['searchfield'] = 'code,nopol';
        }
        final uri = Uri.parse(
          '$baseUrl/dynamic/t_surat_jalan',
        ).replace(queryParameters: queryParams);
        final response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode != 200) return [];
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'];
        return data
            .map<DeliveryOrderModel>((e) => DeliveryOrderModel.fromJson(e))
            .toList();
      }

      final status4 = await fetchByStatus('4');
      if (status4.isNotEmpty) return status4;

      return await fetchByStatus('5');
    } catch (e) {
      throw Exception('Error getListDOSudahConfirm: $e');
    }
  }

  Future<List<DeliveryOrderModel>> getListDOSudahReceived({
    required String token,
    required String userId,
    String? search,
    int page = 1,
    int paginate = 10,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'filter_column_status': '3',
        'filter_column_is_taken': 'true',
        'filter_column_taken_by': userId,
        'page': page.toString(),
        'paginate': paginate.toString(),
        'include': 'm_customer',
      };

      // 🔍 optional search
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
        queryParams['searchfield'] = 'code,nopol';
      }

      final uri = Uri.parse(
        '$baseUrl/dynamic/t_surat_jalan',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 DO sudah confirm URI: $uri');
      print('📥 DO sudah confirm Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'];

        return data
            .map<DeliveryOrderModel>((e) => DeliveryOrderModel.fromJson(e))
            .toList();
      } else {
        throw Exception(
          'Failed get DO sudah confirm list: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getListDOSudahConfirm: $e');
    }
  }

  Future<List<DeliveryOrderModel>> getTodayHistoryForComplaint({
    required String token,
    required String userId,
  }) async {
    final today = _dateOnly(DateTime.now());

    Future<List<DeliveryOrderModel>> fetch(String status) async {
      final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan').replace(
        queryParameters: {
          'where': 'date=$today',
          'filter_column_status': status,
          'filter_column_is_taken': 'true',
          'filter_column_taken_by': userId,
          'paginate': '200',
          'page': '1',
          'include': 'm_customer',
        },
      );
      if (kDebugMode) {
        debugPrint('[COMPLAINT_DO] GET $uri');
      }
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (kDebugMode) {
        debugPrint('[COMPLAINT_DO] response: ${response.statusCode}');
        debugPrint('[COMPLAINT_DO] body: ${response.body}');
      }
      if (response.statusCode != 200) return [];
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List data = jsonResponse['data'];
      return data
          .map<DeliveryOrderModel>((e) => DeliveryOrderModel.fromJson(e))
          .toList();
    }

    // Rule:
    // - Jika hari ini ada status 5 -> tampilkan hanya status 5
    // - Jika tidak ada status 5 -> tampilkan semua status 3 (hari ini)
    final status5 = await fetch('5');
    if (kDebugMode) {
      debugPrint(
        '[COMPLAINT_DO] picked_status=${status5.isNotEmpty ? "5" : "3"}',
      );
      debugPrint('[COMPLAINT_DO] count_status5=${status5.length}');
    }
    if (status5.isNotEmpty) return status5;
    final status3 = await fetch('3');
    if (kDebugMode) {
      debugPrint('[COMPLAINT_DO] count_status3=${status3.length}');
    }
    return status3;
  }

  Future<DeliveryOrderModel> getDetailDo({
    required String token,
    required String doId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan/$doId').replace(
        queryParameters: {
          'include':
              't_surat_jalan_d,t_sales_order,t_surat_jalan_d>m_item,m_customer,t_surat_jalan_realisasi',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 DO DETAIL URI: $uri');
      print('📥 DO DETAIL RESPONSE: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed get detail DO (${response.statusCode})');
      }

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final Map<String, dynamic> data = jsonResponse['data'];

      /// 🔥 langsung parse ROOT ke DeliveryOrderModel
      return DeliveryOrderModel.fromJson(data);
    } catch (e) {
      throw Exception('Error getDetailDo: $e');
    }
  }

  Future<void> confirmDo({
    required String token,
    required List<String> doIds,
    required String userId,
  }) async {
    try {
      for (String doId in doIds) {
        final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan/$doId');
        print('Confirming DO ID: $doId');
        final response = await http.put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({'is_taken': true, 'taken_by': userId}),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to confirm DO $doId: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error confirming DOs: $e');
    }
  }

  Future<Map<String, dynamic>> checkOpenTimeIn({required String token}) async {
    try {
      // Prefer delivery plan realisasi, fallback to surat jalan realisasi for backward compatibility.
      final uriPrimary = Uri.parse(
        '$baseUrl/fn/t_delivery_plan_realisasi/checkOpenTimeIn',
      );
      final uriFallback = Uri.parse(
        '$baseUrl/fn/t_surat_jalan_realisasi/checkOpenTimeIn',
      );

      final response = await http.get(
        uriPrimary,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Check Open Time In Response: $jsonResponse');
        return jsonResponse;
      }

      final fallbackResponse = await http.get(
        uriFallback,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (fallbackResponse.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(
          fallbackResponse.body,
        );
        print('Check Open Time In (Fallback) Response: $jsonResponse');
        return jsonResponse;
      } else {
        return {'has_open': true, 'total': 0, 'data': []};
      }
    } catch (e) {
      return {'has_open': true, 'total': 0, 'data': []};
    }
  }

  Future<Map<String, dynamic>> checkOpenTimeInSuratJalan({
    required String token,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/fn/t_surat_jalan_realisasi/checkOpenTimeIn',
    );
    if (kDebugMode) {
      debugPrint('[SJ_REALISASI] GET $uri');
    }
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (kDebugMode) {
        debugPrint('[SJ_REALISASI] response: ${response.statusCode}');
        debugPrint('[SJ_REALISASI] body: ${response.body}');
      }
      return jsonResponse;
    }
    if (kDebugMode) {
      debugPrint('[SJ_REALISASI] response: ${response.statusCode}');
      debugPrint('[SJ_REALISASI] body: ${response.body}');
    }
    return {'has_open': false, 'total': 0, 'data': []};
  }

  Future<String> checkIn({
    required String token,
    required String deliveryPlanId,
    required String userId,
    required String timeIn,
    required String latIn,
    required String longIn,
    required String addressIn,
    required File photo,
  }) async {
    try {
      return await upsertDeliveryPlanRealisasiCheckIn(
        token: token,
        deliveryPlanId: deliveryPlanId,
        userId: userId,
        timeIn: timeIn,
        latIn: latIn,
        longIn: longIn,
        addressIn: addressIn,
        photo: photo,
      );
    } catch (e) {
      throw Exception('Error checking in: $e');
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
    try {
      final uri = Uri.parse(
        '$baseUrl/dynamic/t_delivery_plan_realisasi/$realisasiId',
      );
      var request = http.MultipartRequest('PUT', uri);
      if (kDebugMode) {
        debugPrint('[DP_REALISASI] PUT $uri');
        debugPrint(
          '[DP_REALISASI] realisasi_id=$realisasiId delivery_plan_id=$deliveryPlanId user_id=$userId',
        );
        debugPrint(
          '[DP_REALISASI] time_out=$timeOut lat_out=$latOut long_out=$longOut durasi=$duration',
        );
        debugPrint('[DP_REALISASI] address_out=$addressOut');
        debugPrint('[DP_REALISASI] foto_out=${photo.path}');
      }

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['delivery_plan_id'] = deliveryPlanId;
      request.fields['user_id'] = userId;
      request.fields['time_out'] = timeOut;
      request.fields['lat_out'] = latOut;
      request.fields['long_out'] = longOut;
      request.fields['address_out'] = addressOut;
      request.fields['durasi'] = duration;

      request.files.add(
        await http.MultipartFile.fromPath('foto_out', photo.path),
      );

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (kDebugMode) {
        debugPrint('[DP_REALISASI] response: ${response.statusCode}');
        debugPrint('[DP_REALISASI] body: $responseBody');
      }

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'Failed to check out: ${response.statusCode} - $responseBody',
        );
      }
    } catch (e) {
      throw Exception('Error checking out: $e');
    }
  }

  Future<void> checkOutSuratJalanRealisasi({
    required String token,
    required String realisasiId,
    required String suratJalanId,
    required String userId,
    required String timeOut,
    required String latOut,
    required String longOut,
    required String addressOut,
    required String duration,
    String? note,
    required File photo,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/dynamic/t_surat_jalan_realisasi/$realisasiId',
    );
    if (kDebugMode) {
      debugPrint('[SJ_REALISASI] PUT $uri');
      debugPrint(
        '[SJ_REALISASI] payload: realisasi_id=$realisasiId t_surat_jalan_id=$suratJalanId user_id=$userId time_out=$timeOut lat_out=$latOut long_out=$longOut durasi=$duration',
      );
      debugPrint('[SJ_REALISASI] address_out=$addressOut');
      debugPrint('[SJ_REALISASI] foto_out=${photo.path}');
    }
    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['t_surat_jalan_id'] = suratJalanId;
    request.fields['user_id'] = userId;
    request.fields['time_out'] = timeOut;
    request.fields['lat_out'] = latOut;
    request.fields['long_out'] = longOut;
    request.fields['address_out'] = addressOut;
    request.fields['durasi'] = duration;
    if (note != null && note.trim().isNotEmpty) {
      request.fields['note'] = note.trim();
    }

    request.files.add(
      await http.MultipartFile.fromPath('foto_out', photo.path),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    if (kDebugMode) {
      debugPrint('[SJ_REALISASI] response: ${response.statusCode}');
      debugPrint('[SJ_REALISASI] body: $responseBody');
    }
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Failed to check out customer DO: ${response.statusCode} - $responseBody',
      );
    }
  }

  Future<bool> isDeliveryPlanCheckedOutToday({
    required String token,
    required String userId,
    required String deliveryPlanId,
  }) async {
    final rows = await fetchTodayDeliveryPlanRealisasi(
      token: token,
      userId: userId,
    );
    for (final r in rows) {
      if (r is! Map) continue;
      if (r['delivery_plan_id']?.toString() != deliveryPlanId) continue;
      final timeOut = r['time_out'];
      if (timeOut != null && timeOut.toString().isNotEmpty) return true;
    }
    return false;
  }

  Future<bool> hasOutstandingDoForDeliveryPlan({
    required String token,
    required String userId,
    required String deliveryPlanId,
  }) async {
    for (final status in const ['4', '5']) {
      final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan').replace(
        queryParameters: {
          'where': 'delivery_plan_id=$deliveryPlanId',
          'filter_column_status': status,
          'filter_column_is_taken': 'true',
          'filter_column_taken_by': userId,
          'paginate': '1',
          'page': '1',
        },
      );
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200) continue;
      final body = json.decode(response.body);
      final data = (body is Map<String, dynamic>)
          ? (body['data'] as List?)
          : null;
      if ((data ?? []).isNotEmpty) return true;
    }
    return false;
  }

  Future<bool> hasDoWithStatusForDeliveryPlan({
    required String token,
    required String userId,
    required String deliveryPlanId,
    required String status,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan').replace(
      queryParameters: {
        'where': 'delivery_plan_id=$deliveryPlanId',
        'filter_column_status': status,
        'filter_column_is_taken': 'true',
        'filter_column_taken_by': userId,
        'paginate': '1',
        'page': '1',
      },
    );
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) return false;
    final body = json.decode(response.body);
    final data = (body is Map<String, dynamic>)
        ? (body['data'] as List?)
        : null;
    return (data ?? []).isNotEmpty;
  }

  Future<void> updateDeliveryPlanStatus({
    required String token,
    required String deliveryPlanId,
    required int status,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/t_delivery_plan/$deliveryPlanId');
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update delivery plan status: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> updateDoStatus({
    required String token,
    required String doId,
    required int status,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan/$doId');
      print('Update DO Status URI: $uri');
      print('DO ID: $doId');
      print('Status: $status');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': status}),
      );

      print('Update Status Response Status: ${response.statusCode}');
      print('Update Status Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update DO status: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error updating DO status: $e');
    }
  }

  Future<List<TrackingModel>> getTodayTracking({required String token}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/fn/t_surat_jalan_realisasi/getTodayTracking',
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Today Tracking URI: $uri');
      print('📥 Today Tracking Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'];

        return data
            .map<TrackingModel>((e) => TrackingModel.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to get today tracking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getTodayTracking: $e');
    }
  }
}