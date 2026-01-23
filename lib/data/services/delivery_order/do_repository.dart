import 'dart:convert';

import 'package:bbs_driver/core/constants/api_constants.dart';
import 'package:bbs_driver/data/models/delivery_order/delivery_order_model.dart';
import 'package:http/http.dart' as http;

class DoRepository {
  final String baseUrl = ApiConstants.baseUrl;
  Future<List<DeliveryOrderModel>> getListDOMasuk({
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan').replace(
        queryParameters: {
          'filter_column_status': '2', // posted
          'filter_column_si_used': 'false',
          'filter_column_is_taken': 'false',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // kalau pakai token:
          'Authorization': 'Bearer $token',
        },
      );

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
    required String userId
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/dynamic/t_surat_jalan').replace(
        queryParameters: {
          'filter_column_status': '2', // posted
          'filter_column_si_used': 'false',
          'filter_column_is_taken': 'true',
          'filter_column_taken_by': userId,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // kalau pakai token:
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 DO sudah confirm Response body: ${response.body}');

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
      throw Exception('Error getListDOSudahConfirm: $e');
    }
  }
}
