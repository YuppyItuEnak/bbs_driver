import 'dart:convert';
import 'dart:io';

import 'package:bbs_driver/core/constants/api_constants.dart';
import 'package:bbs_driver/data/models/complaint/complaint_add_model.dart';
import 'package:bbs_driver/data/models/complaint/complaint_detail_model.dart';
import 'package:bbs_driver/data/models/complaint/complaint_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ComplainRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<String?> uploadFile({
    required String token,
    required File file,
  }) async {
    final url = Uri.parse('$baseUrl/dynamic/upload_file');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('path_file', file.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(responseBody);
        if (responseData['status'] == 'success') {
          return responseData['data']?['path_file'] as String?;
        }
        throw Exception('Upload failed: ${responseData['message']}');
      }
      throw Exception('Failed to upload file: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('uploadFile error: $e');
      }
      rethrow;
    }
  }

  Future<List<ComplaintModel>> fetchListComplaint({
    required String token,
    required String salesId,
    required String unitBusinessId,
    String? search,
    int page = 1,
    int paginate = 10,
  }) async {
    final query = {
      "filter_column_sales_id": salesId,
      "filter_column_unit_bussiness_id": unitBusinessId,
      "page": page.toString(),
      "paginate": paginate.toString(),
      "selectfield": "id,customer,ref_type,status,date",
    };

    if (search != null && search.isNotEmpty) {
      query["search"] = search;
      query["searchfield"] = "customer,code";
    }

    final uri = Uri.parse(
      '$baseUrl/dynamic/t_complain',
    ).replace(queryParameters: query);

    if (kDebugMode) {
      debugPrint('[COMPLAIN_LIST] GET $uri');
    }
    final res = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (kDebugMode) {
      debugPrint('[COMPLAIN_LIST] status=${res.statusCode}');
      debugPrint('[COMPLAIN_LIST] body=${res.body}');
    }
    final body = jsonDecode(res.body);
    final List list = body['data'];

    return list.map((e) => ComplaintModel.fromJson(e)).toList();
  }

  Future<ComplainDetailModel> getDetailComplaint({
    required String token,
    required String id,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/t_complain/$id').replace(
      queryParameters: {
        'include': 't_complain_d,m_unit_bussiness,m_customer,t_complain_d>m_item',
      },
    );

    if (kDebugMode) {
      debugPrint('[COMPLAIN_DETAIL] GET $uri');
    }
    final res = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (kDebugMode) {
      debugPrint('[COMPLAIN_DETAIL] status=${res.statusCode}');
      debugPrint('[COMPLAIN_DETAIL] body=${res.body}');
    }
    final body = jsonDecode(res.body);
    return ComplainDetailModel.fromJson(body['data']);
  }

  Future<void> createComplaint({
    required String token,
    required ComplainCreateModel data,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/t_complain');

    final res = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data.toJson()),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Gagal membuat complain");
    }
  }

  Future<void> createComplaintWithDetails({
    required String token,
    required ComplainCreateModel data,
  }) async {
    // Upload any picked images and convert them into imageUrl strings.
    for (final item in data.items) {
      if (item.imageFiles.isEmpty) continue;

      final urls = <String>[];
      for (final file in item.imageFiles) {
        final url = await uploadFile(token: token, file: file);
        if (url != null && url.isNotEmpty) urls.add(url);
      }

      if (urls.isNotEmpty) {
        item.imageUrls = [...item.imageUrls, ...urls];
      }
    }

    final uri = Uri.parse('$baseUrl/dynamic/t_complain/with-details');

    if (kDebugMode) {
      debugPrint('[COMPLAIN] POST $uri');
      debugPrint('[COMPLAIN] payload=${jsonEncode(data.toJson())}');
    }
    final res = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data.toJson()),
    );

    if (kDebugMode) {
      debugPrint('[COMPLAIN] status=${res.statusCode}');
      debugPrint('[COMPLAIN] body=${res.body}');
    }
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Gagal membuat complain");
    }
  }

  Future<void> updateComplaintWithDetails({
    required String token,
    required String id,
    required ComplainCreateModel data,
  }) async {
    // Upload any newly picked images and convert them into imageUrl strings.
    for (final item in data.items) {
      if (item.imageFiles.isEmpty) continue;

      final urls = <String>[];
      for (final file in item.imageFiles) {
        final url = await uploadFile(token: token, file: file);
        if (url != null && url.isNotEmpty) urls.add(url);
      }

      if (urls.isNotEmpty) {
        item.imageUrls = [...item.imageUrls, ...urls];
      }
    }

    final uri = Uri.parse('$baseUrl/dynamic/t_complain/with-details/$id');

    if (kDebugMode) {
      debugPrint('[COMPLAIN] PUT $uri');
      debugPrint('[COMPLAIN] payload=${jsonEncode(data.toJson())}');
    }
    final res = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data.toJson()),
    );

    if (kDebugMode) {
      debugPrint('[COMPLAIN] status=${res.statusCode}');
      debugPrint('[COMPLAIN] body=${res.body}');
    }
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Gagal update complain");
    }
  }

  Future<void> updateComplaint({
    required String token,
    required String id,
    required ComplainCreateModel data,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/t_complain/$id');

    final res = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception("Gagal update complain");
    }
  }
}
