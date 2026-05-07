import 'dart:convert';
import 'package:bbs_driver/data/models/general/m_gen_model.dart';
import 'package:bbs_driver/data/models/general/performance_target_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bbs_driver/core/constants/api_constants.dart';

class MGenRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<MGenModel>> fetchMGen(String where, String token) async {
    final queryParams = {'where': where, 'no_pagination': 'true'};

    final uri = Uri.parse(
      '$baseUrl/dynamic/m_gen',
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (kDebugMode) {
      print('MGenRepository fetchMGen URL: $uri');
    }
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (kDebugMode) {
        print(body);
      }
      final List data = body['data'];
      return data.map((e) => MGenModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data MGen');
    }
  }

  Future<PerformanceTargetDataModel> fetchVisitTargetComparison({
    required String token,
    required String salesId,
    required int year,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/fn/m_target/compareTargetVisitPerYear?sales_id=$salesId&year=$year',
    );

    if (kDebugMode) {
      print('MGenRepository fetchVisitTargetComparison URL: $uri');
    }

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(
          'MGenRepository fetchVisitTargetComparison Response: ${response.body}',
        );
      }
      final body = jsonDecode(response.body);
      if (kDebugMode) {
        print(body);
      }
      return PerformanceTargetDataModel.fromJson(body['data'] ?? body);
    } else {
      throw Exception('Gagal mengambil data visit target');
    }
  }

  Future<PerformanceTargetDataModel> fetchCustomerTargetComparison({
    required String token,
    required String salesId,
    required int year,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/fn/m_target/compareTargetCustomerPerYear?sales_id=$salesId&year=$year',
    );

    if (kDebugMode) {
      print('MGenRepository fetchCustomerTargetComparison URL: $uri');
    }

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(
          'MGenRepository fetchCustomerTargetComparison Response: ${response.body}',
        );
      }
      final body = jsonDecode(response.body);
      if (kDebugMode) {
        print(body);
      }
      return PerformanceTargetDataModel.fromJson(body['data'] ?? body);
    } else {
      throw Exception('Gagal mengambil data customer target');
    }
  }
}
