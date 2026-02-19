import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../model/login_request.dart';
import '../model/login_response.dart';

class LoginViewModel {
  Future<LoginResponse> login(LoginRequest request) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginPath}');

    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': ApiConstants.basicAuthorization,
      },
      body: jsonEncode(request.toJson()),
    );

    print('LOGIN API STATUS: ${response.statusCode}');
    print('LOGIN API RESPONSE: ${response.body}');

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final Map<String, dynamic> decoded =
        jsonDecode(response.body) as Map<String, dynamic>;
    final loginResponse = LoginResponse.fromJson(decoded);

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        loginResponse.status) {
      return loginResponse;
    }

    throw Exception(
      loginResponse.message.isNotEmpty
          ? loginResponse.message
          : 'Login failed (${response.statusCode})',
    );
  }
}
