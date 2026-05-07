import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/error/exceptions.dart';
import '../../models/auth/login_response_model.dart';
import '../../models/auth/user_model.dart';
import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<LoginResponse> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final body = json.encode({'username': username, 'password': password});

    try {
      if (kDebugMode) {
        print('🔗 URL: $url');
        print('📦 Request body: $body');
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (kDebugMode) {
        print('📥 Response status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final loginResponse = LoginResponse.fromJson(responseData);

        final user = await fetchUserDetails(
          loginResponse.user.id,
          loginResponse.token,
        );

        return LoginResponse(
          status: loginResponse.status,
          message: loginResponse.message,
          user: user,
          token: loginResponse.token,
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw ServerException(errorData['message'] ?? 'Login failed');
      }
    } on SocketException {
      throw NetworkException('Tidak ada koneksi internet. Silakan periksa koneksi Anda dan coba lagi.');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Login error: $e');
      }
      rethrow;
    }
  }

  Future<User> fetchUserDetails(String userId, String token) async {
    final url = Uri.parse(
      '$baseUrl/dynamic/user_default/$userId?include=user_detail',
    );

    try {
      if (kDebugMode) {
        print('🔗 Fetching user details from: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('📥 User details response status: ${response.statusCode}');
        print('📥 User details response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final userData = responseData['data'];
          User user;
          if (userData is List) {
            if (userData.isNotEmpty) {
              user = User.fromJson(userData.first);
            } else {
              throw ServerException('User data is an empty list.');
            }
          }
          else if (userData is Map<String, dynamic>) {
            user = User.fromJson(userData);
          }
          else {
            throw ServerException('User data is not in the expected format.');
          }

          if (user.userMobile != true) {
            throw ServerException(
                'user anda tidak diijinkan menggunakan aplikasi ini');
          }

          return user;
        } else {
          throw ServerException(
            'Failed to fetch user details: ${responseData['message']}',
          );
        }
      } else {
        throw ServerException('Failed to fetch user details: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('Tidak ada koneksi internet. Silakan periksa koneksi Anda dan coba lagi.');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user details: $e');
      }
      rethrow;
    }
  }

  Future<bool> changePassword({
    required String userId,
    required String token,
    required String newPassword,
    required String currentPassword,
  }) async {
    final url = Uri.parse('$baseUrl/dynamic/user_default/$userId');
    final body = json.encode({
      'password': newPassword,
      // 'current_password': currentPassword,
    });

    try {
      if (kDebugMode) {
        print('🔗 Change password URL: $url');
        print('📦 Request body: $body');
      }

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (kDebugMode) {
        print('📥 Change password response status: ${response.statusCode}');
        print('📥 Change password response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        throw ServerException('Failed to change password: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('Tidak ada koneksi internet. Silakan periksa koneksi Anda dan coba lagi.');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error changing password: $e');
      }
      throw ServerException('Failed to change password: $e');
    }
  }
}
