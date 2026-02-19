import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../model/service_call_request.dart';

class ServiceCallViewModel {
  Future<Map<String, dynamic>> createServiceCall(
    ServiceCallRequest request,
  ) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.createServiceCallPath}',
    );
    final payload = request.toJson();

    print('CREATE SERVICE CALL REQUEST: ${jsonEncode(payload)}');

    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': ApiConstants.basicAuthorization,
      },
      body: jsonEncode(payload),
    );

    print('CREATE SERVICE CALL STATUS: ${response.statusCode}');
    print('CREATE SERVICE CALL RESPONSE: ${response.body}');

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final dynamic decoded = jsonDecode(response.body);
    final Map<String, dynamic> responseData = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    }

    final String message = (responseData['message'] ?? '').toString();
    throw Exception(
      message.isNotEmpty
          ? message
          : 'Create service call failed (${response.statusCode})',
    );
  }
}
