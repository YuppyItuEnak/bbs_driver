import 'dart:convert';
import 'dart:io';
import 'package:bbs_driver/core/constants/api_constants.dart';
import 'package:bbs_driver/data/models/reimburse/reimburse_add_model.dart';
import 'package:bbs_driver/data/models/reimburse/reimburse_check_model.dart';
import 'package:bbs_driver/data/models/reimburse/reimburse_detail_model.dart';
import 'package:bbs_driver/data/models/reimburse/reimburse_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ReimburseRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<ReimburseModel>> fetchReimburse({
    required String token,
    required String salesId,
    String? search,
    int page = 1,
    int paginate = 25,
  }) async {
    final queryParams = {
      'where': 'sales_id=$salesId',
      'selectfield': 'id,type,date,km_awal,km_akhir,code,status',
      'page': page.toString(),
      'paginate': paginate.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
      queryParams['searchfield'] = 'type';
    }

    final uri = Uri.parse(
      '$baseUrl/dynamic/t_reimburse',
    ).replace(queryParameters: queryParams);

    if (kDebugMode) {
      print("Fetching reimburse from: $uri");
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
        print("Response: ${response.body}");
      }

      final body = jsonDecode(response.body);
      final List data = body['data'];

      return data.map((e) => ReimburseModel.fromJson(e)).toList();
    } else {
      if (kDebugMode) {
        print("Error: ${response.statusCode} - ${response.body}");
      }
      throw Exception('Gagal mengambil data reimburse');
    }
  }

  Future<ReimburseDetailModel> fetchDetailReimburse({
    required String token,
    required String id,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/t_reimburse/$id');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("Detail Response: ${response.body}");
      final body = jsonDecode(response.body);
      return ReimburseDetailModel.fromJson(body['data']);
    } else {
      throw Exception('Gagal mengambil detail reimburse');
    }
  }

  Future<ReimburseModel> createReimburse({
    required String token,
    required ReimburseCreateModel data,
    File? fotoAwal,
    File? fotoAkhir,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/t_reimburse');
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    data.toJson().forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    // Add image files
    if (fotoAwal != null) {
      request.files.add(
        await http.MultipartFile.fromPath('foto_awal', fotoAwal.path),
      );
    }
    if (fotoAkhir != null) {
      request.files.add(
        await http.MultipartFile.fromPath('foto_akhir', fotoAkhir.path),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (kDebugMode) {
        print(
          'Failed to create reimburse: ${response.statusCode} - $responseBody',
        );
      }
      throw Exception('Gagal membuat reimburse');
    } else {
      if (kDebugMode) {
        print('Reimburse created successfully: $responseBody');
      }
      final body = jsonDecode(responseBody);
      return ReimburseModel.fromJson(body['data']);
    }
  }

  Future<void> updateReimburse({
    required String token,
    required String id,
    required ReimburseCreateModel data,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/t_reimburse/$id');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal update reimburse');
    }
  }

  Future<bool> requestApproval({
    required String token,
    required String reimburseId,
    required String userId,
  }) async {
    final uri = Uri.parse('$baseUrl/fn/t_reimburse_approval/requestApproval');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'reimburse_id': reimburseId, 'auth_user_id': userId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Reimburse approval requested successfully: ${response.body}');
      return true;
    } else {
      print(
        'Failed to request reimburse approval: ${response.statusCode} - ${response.body}',
      );
      throw Exception('Gagal mengajukan approval reimburse');
    }
  }

  Future<ReimburseCheckModel?> checkReimburseToday({
    required String token,
    required String salesId,
  }) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final queryParams = {
      'where': 'date=$today',
      'selectfield': 'id,km_awal,km_akhir',
      'filter_column_sales_id': salesId,
    };

    final uri = Uri.parse(
      '$baseUrl/dynamic/t_reimburse',
    ).replace(queryParameters: queryParams);

    if (kDebugMode) {
      print("Checking reimburse from: $uri");
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
        print("Response: ${response.body}");
      }

      final body = jsonDecode(response.body);
      final List data = body['data'];

      if (data.isNotEmpty) {
        return ReimburseCheckModel.fromJson(data[0]);
      } else {
        return null;
      }
    } else {
      if (kDebugMode) {
        print("Error: ${response.statusCode} - ${response.body}");
      }
      throw Exception('Gagal memeriksa data reimburse hari ini');
    }
  }
}
