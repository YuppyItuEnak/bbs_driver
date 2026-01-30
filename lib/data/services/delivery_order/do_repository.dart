import 'dart:convert';

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
          'include': 't_surat_jalan_d,t_sales_order,t_surat_jalan_d>m_item',
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
}
