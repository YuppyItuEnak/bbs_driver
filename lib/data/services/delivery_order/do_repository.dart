import 'dart:convert';
import 'dart:io';

import 'package:bbs_driver/core/constants/api_constants.dart';
import 'package:bbs_driver/data/models/delivery_order/delivery_order_detail.dart';
import 'package:bbs_driver/data/models/delivery_order/delivery_order_model.dart';
import 'package:http/http.dart' as http;

class DoRepository {
  final String baseUrl = ApiConstants.baseUrl;
  Future<List<DeliveryOrderModel>> getListDOMasuk({
    required String token,
    String? search,
    int page = 1,
    int paginate = 10,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'filter_column_status': '2', // posted
        'filter_column_si_used': 'false',
        'filter_column_is_taken': 'false',
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
      final Map<String, String> queryParams = {
        'filter_column_status': '2', // posted
        'filter_column_si_used': 'false',
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

  Future<DeliveryOrderModel> getDetailDo({
    required String token,
    required String doId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan/$doId').replace(
        queryParameters: {
          'include':
              't_surat_jalan_d,t_sales_order,t_surat_jalan_d>m_item,m_customer',
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
      final uri = Uri.parse(
        '$baseUrl/fn/t_surat_jalan_realisasi/checkOpenTimeIn',
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Check Open Time In Response: $jsonResponse');
        return jsonResponse;
      } else {
        return {'has_open': true, 'total': 0, 'data': []};
      }
    } catch (e) {
      return {'has_open': true, 'total': 0, 'data': []};
    }
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
    try {
      final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan_realisasi');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['t_surat_jalan_id'] = doId;
      request.fields['time_in'] = timeIn;
      request.fields['lat_in'] = latIn;
      request.fields['long_in'] = longIn;
      request.fields['address_in'] = addressIn;

      request.files.add(
        await http.MultipartFile.fromPath('foto_in', photo.path),
      );

      var response = await request.send();

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to check in: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking in: $e');
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
    try {
      // Use checkInId (the t_surat_jalan_realisasi record id) for the API endpoint
      final uri = Uri.parse(
        '$baseUrl/dynamic/t_surat_jalan_realisasi/$checkInId',
      );
      var request = http.MultipartRequest('PUT', uri);
      print('Check Out URI: $uri');
      print('Check In ID: $checkInId');
      print('DO ID: $doId');

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['t_surat_jalan_id'] = doId;
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
      print('Check Out Response Status: ${response.statusCode}');
      print('Check Out Response Body: $responseBody');

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'Failed to check out: ${response.statusCode} - $responseBody',
        );
      }
    } catch (e) {
      throw Exception('Error checking out: $e');
    }
  }
}
