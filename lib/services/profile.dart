import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sycx_flutter_app/services/api_client.dart';
import 'package:sycx_flutter_app/utils/secure_storage.dart';

class ProfileService {
  static final ApiClient _apiClient = ApiClient(httpClient: http.Client());

  static Future<bool> updateProfile(
      String userId, String username, String email, String profilePic) async {
    final token = await SecureStorage.getToken();
    final response = await _apiClient.put(
      '/update_profile',
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'user_id': userId,
        'username': username,
        'email': email,
        'profile_pic': profilePic
      },
      authRequired: true,
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteAccount(String userId) async {
    final token = await SecureStorage.getToken();
    final response = await _apiClient.delete(
      '/delete_account?user_id=$userId',
      headers: {'Authorization': 'Bearer $token'},
      authRequired: true,
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final token = await SecureStorage.getToken();
    final response = await _apiClient.get(
      '/user_profile?user_id=$userId',
      headers: {'Authorization': 'Bearer $token'},
      authRequired: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }
}
