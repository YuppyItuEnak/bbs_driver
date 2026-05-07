import 'dart:convert';

import 'package:bbs_driver/core/constants/api_constants.dart';
import 'package:bbs_driver/data/models/complaint/complaint_add_model.dart';
import 'package:bbs_driver/data/models/complaint/complaint_detail_model.dart';
import 'package:bbs_driver/data/models/complaint/complaint_model.dart';
import 'package:http/http.dart' as http;

class ComplainRepository {
  final String baseUrl = ApiConstants.baseUrl;
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

    final res = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    final body = jsonDecode(res.body);
    final List list = body['data'];

    return list.map((e) => ComplaintModel.fromJson(e)).toList();
  }

  Future<ComplainDetailModel> getDetailComplaint({
    required String token,
    required String id,
  }) async {
    final uri = Uri.parse('$baseUrl/dynamic/t_complain/$id');

    final res = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

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
