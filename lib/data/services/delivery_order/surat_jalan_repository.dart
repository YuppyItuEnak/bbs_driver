import 'dart:convert';
import 'package:bbs_driver/core/constants/api_constants.dart';
import 'package:bbs_driver/data/models/delivery_order/surat_jalan_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SuratJalanRepository {
  Future<List<SuratJalanModel>> fetchSuratJalan({
    required String token,
    required String customerId,
    int status = 3,
  }) async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}/dynamic/t_surat_jalan?where=customer_id=$customerId&filter_column_status=$status',
    );
    if (kDebugMode) {
      print("URI: $uri");
    }

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Response: ${response.body}");
        }
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> jsonList = responseData['data'] ?? [];
        return jsonList
            .map(
              (json) => SuratJalanModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load surat jalan: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching surat jalan: $e');
    }
  }

  Future<SuratJalanModel> fetchSuratJalanDetail({
    required String token,
    required String id,
  }) async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final Uri uri = Uri.parse(
      '${ApiConstants.baseUrl}/dynamic/t_surat_jalan/$id?include=t_surat_jalan_d',
    );
    if (kDebugMode) {
      print("URI: $uri");
    }

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Response: ${response.body}");
        }
        final Map<String, dynamic> responseData = json.decode(response.body);
        return SuratJalanModel.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Failed to load surat jalan detail: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching surat jalan detail: $e');
    }
  }
}
