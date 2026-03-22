import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/api_constants.dart';
import '../model/contract_data.dart';
import '../model/employee_data.dart';
import '../model/problem_sub_type_data.dart';
import '../model/problem_type_data.dart';
import '../model/project_data.dart';
import '../model/service_call_report_item.dart';
import '../model/service_call_request.dart';

class ServiceCallViewModel {
  Uri _buildNoCacheUri(String path) {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final params = Map<String, String>.from(uri.queryParameters);
    params['_ts'] = DateTime.now().millisecondsSinceEpoch.toString();
    return uri.replace(queryParameters: params);
  }

  Map<String, String> _getHeaders() {
    return <String, String>{
      'Accept': 'application/json',
      'Authorization': ApiConstants.basicAuthorization,
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    };
  }

  Future<List<ContractData>> fetchContractData() async {
    final uri = _buildNoCacheUri(ApiConstants.getContractDataPath);
    final headers = _getHeaders();

    print('GET CONTRACT DATA URL: $uri');
    print('GET CONTRACT DATA HEADERS: $headers');
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    print('GET CONTRACT DATA STATUS: ${response.statusCode}');
    print('GET CONTRACT DATA RESPONSE: ${response.body}');

    if (response.body.isEmpty) {
      throw Exception('Empty response from contract data API');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid contract data response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid contract data response format');
      }
      return rows
          .whereType<Map<String, dynamic>>()
          .map(ContractData.fromJson)
          .toList();
    }

    throw Exception('Get contract data failed (${response.statusCode})');
  }

  Future<List<ProjectData>> fetchProjectData() async {
    final uri = _buildNoCacheUri(ApiConstants.getProjectDataPath);
    final headers = _getHeaders();

    print('GET PROJECT DATA URL: $uri');
    print('GET PROJECT DATA HEADERS: $headers');
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    print('GET PROJECT DATA STATUS: ${response.statusCode}');
    print('GET PROJECT DATA RESPONSE: ${response.body}');

    if (response.body.isEmpty) {
      throw Exception('Empty response from project data API');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid project data response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid project data response format');
      }
      return rows
          .whereType<Map<String, dynamic>>()
          .map(ProjectData.fromJson)
          .toList();
    }

    throw Exception('Get project data failed (${response.statusCode})');
  }

  Future<List<EmployeeData>> fetchEmployeeData() async {
    final uri = _buildNoCacheUri(ApiConstants.getEmployeeDataPath);
    final headers = _getHeaders();

    print('GET EMPLOYEE DATA URL: $uri');
    print('GET EMPLOYEE DATA HEADERS: $headers');
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    print('GET EMPLOYEE DATA STATUS: ${response.statusCode}');
    print('GET EMPLOYEE DATA RESPONSE: ${response.body}');

    if (response.body.isEmpty) {
      throw Exception('Empty response from employee data API');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid employee data response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid employee data response format');
      }
      return rows
          .whereType<Map<String, dynamic>>()
          .map(EmployeeData.fromJson)
          .toList();
    }

    throw Exception('Get employee data failed (${response.statusCode})');
  }

  Future<List<ProblemTypeData>> fetchProblemTypeData() async {
    final uri = _buildNoCacheUri(ApiConstants.getProblemTypeDataPath);
    final headers = _getHeaders();

    print('GET PROBLEM TYPE DATA URL: $uri');
    print('GET PROBLEM TYPE DATA HEADERS: $headers');
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    print('GET PROBLEM TYPE DATA STATUS: ${response.statusCode}');
    print('GET PROBLEM TYPE DATA RESPONSE: ${response.body}');

    if (response.body.isEmpty) {
      throw Exception('Empty response from problem type data API');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid problem type data response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid problem type data response format');
      }
      return rows
          .whereType<Map<String, dynamic>>()
          .map(ProblemTypeData.fromJson)
          .toList();
    }

    throw Exception('Get problem type data failed (${response.statusCode})');
  }

  Future<List<ProblemSubTypeData>> fetchProblemSubTypeData() async {
    final uri = _buildNoCacheUri(ApiConstants.getProblemSubTypeDataPath);
    final headers = _getHeaders();

    print('GET PROBLEM SUB TYPE DATA URL: $uri');
    print('GET PROBLEM SUB TYPE DATA HEADERS: $headers');
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    print('GET PROBLEM SUB TYPE DATA STATUS: ${response.statusCode}');
    print('GET PROBLEM SUB TYPE DATA RESPONSE: ${response.body}');

    if (response.body.isEmpty) {
      throw Exception('Empty response from problem sub type data API');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid problem sub type data response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid problem sub type data response format');
      }
      return rows
          .whereType<Map<String, dynamic>>()
          .map(ProblemSubTypeData.fromJson)
          .toList();
    }

    throw Exception('Get problem sub type data failed (${response.statusCode})');
  }

  Future<String> fetchNextServiceNo() async {
    final uri = _buildNoCacheUri(ApiConstants.getNextServiceNoPath);
    final headers = _getHeaders();

    print('GET NEXT SERVICE NO URL: $uri');
    print('GET NEXT SERVICE NO HEADERS: $headers');
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    print('GET NEXT SERVICE NO STATUS: ${response.statusCode}');
    print('GET NEXT SERVICE NO RESPONSE: ${response.body}');

    if (response.body.isEmpty) {
      throw Exception('Empty response from next service no API');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is List && decoded.isNotEmpty) {
        final row = decoded.first;
        if (row is Map<String, dynamic>) {
          final serviceNo = (row['ServiceNo'] ?? '').toString().trim();
          if (serviceNo.isNotEmpty) return serviceNo;
        }
      }
      throw Exception('Invalid next service no response format');
    }

    throw Exception('Get next service no failed (${response.statusCode})');
  }

  Future<List<ServiceCallReportItem>> fetchAllServiceCalls() async {
    final uri = _buildNoCacheUri(ApiConstants.getAllServiceCallPath);
    final headers = _getHeaders();

    print('GET ALL SERVICE CALLS URL: $uri');
    print('GET ALL SERVICE CALLS HEADERS: $headers');
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    print('GET ALL SERVICE CALLS STATUS: ${response.statusCode}');
    print('GET ALL SERVICE CALLS RESPONSE: ${response.body}');

    if (response.body.isEmpty) {
      throw Exception('Empty response from get all service calls API');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(ServiceCallReportItem.fromJson)
            .toList();
      }
      throw Exception('Invalid get all service calls response format');
    }

    throw Exception('Get all service calls failed (${response.statusCode})');
  }

  Future<Map<String, dynamic>> fetchSpecficServiceCall(String serviceNo) async {
    final baseUri = _buildNoCacheUri(ApiConstants.getSpecficServiceCallPath);
    final query = Map<String, String>.from(baseUri.queryParameters);
    query['ServiceNo'] = serviceNo.trim();
    final uri = baseUri.replace(queryParameters: query);
    final headers = _getHeaders();

    print('GET SPECIFIC SERVICE CALL URL: $uri');
    print('GET SPECIFIC SERVICE CALL HEADERS: $headers');
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    print('GET SPECIFIC SERVICE CALL STATUS: ${response.statusCode}');
    print('GET SPECIFIC SERVICE CALL RESPONSE: ${response.body}');

    if (response.body.isEmpty) {
      throw Exception('Empty response from specific service call API');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map<String, dynamic>) return first;
      }
      throw Exception('Invalid specific service call response format');
    }

    throw Exception('Get specific service call failed (${response.statusCode})');
  }

  Future<Map<String, dynamic>> updateServiceCallStatus({
    required String serviceNo,
    required String currentStatus,
  }) async {
    final normalizedServiceNo = serviceNo.trim();
    final normalizedStatus = currentStatus.trim();
    if (normalizedServiceNo.isEmpty) {
      throw Exception('ServiceNo is required for status update');
    }
    if (normalizedStatus.isEmpty) {
      throw Exception('CurrentStatus is required for status update');
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.updateServiceCallStatusPath}',
    );
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': ApiConstants.basicAuthorization,
    };

    final payloadAttempts = <Map<String, dynamic>>[
      <String, dynamic>{
        'ServiceCallNo': normalizedServiceNo,
        'CurrentStatus': normalizedStatus,
      },
      <String, dynamic>{
        'ServiceNo': normalizedServiceNo,
        'CurrentStatus': normalizedStatus,
      },
      <String, dynamic>{
        'serviceNo': normalizedServiceNo,
        'currentStatus': normalizedStatus,
      },
    ];

    String? lastError;
    int? lastStatusCode;

    for (final payload in payloadAttempts) {
      print('UPDATE STATUS URL: $uri');
      print('UPDATE STATUS HEADERS: $headers');
      print('UPDATE STATUS REQUEST: ${jsonEncode(payload)}');

      final response = await http
          .post(uri, headers: headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: 20));

      print('UPDATE STATUS RESPONSE CODE: ${response.statusCode}');
      print('UPDATE STATUS RESPONSE BODY: ${response.body}');

      lastStatusCode = response.statusCode;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.trim().isEmpty) {
          return <String, dynamic>{'message': 'Status updated successfully'};
        }
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
        return <String, dynamic>{'data': decoded};
      }

      if (response.body.trim().isNotEmpty) {
        try {
          final dynamic decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final message = (decoded['message'] ?? decoded['error'] ?? '')
                .toString()
                .trim();
            if (message.isNotEmpty) {
              lastError = message;
            }
          } else {
            lastError = response.body.trim();
          }
        } catch (_) {
          lastError = response.body.trim();
        }
      }
    }

    throw Exception(
      lastError ??
          'Update service call status failed (${lastStatusCode ?? 'unknown'})',
    );
  }

  Future<List<Map<String, dynamic>>> fetchServiceAttachments(
    String serviceNo,
  ) async {
    final baseUri = _buildNoCacheUri(ApiConstants.getAttachmentsPath);
    final query = Map<String, String>.from(baseUri.queryParameters);
    query['serviceNo'] = serviceNo.trim();
    final uri = baseUri.replace(queryParameters: query);
    final headers = _getHeaders();

    print('GET ATTACHMENTS URL: $uri');
    print('GET ATTACHMENTS HEADERS: $headers');
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    print('GET ATTACHMENTS STATUS: ${response.statusCode}');
    print('GET ATTACHMENTS RESPONSE: ${response.body}');

    if (response.body.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final dynamic decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().toList();
      }
      if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is List) {
          return nested.whereType<Map<String, dynamic>>().toList();
        }
      }
      return <Map<String, dynamic>>[];
    }

    throw Exception('Get attachments failed (${response.statusCode})');
  }

  Future<Map<String, dynamic>> createServiceCall(
    ServiceCallRequest request,
  ) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.createServiceCallPath}',
    );
    final payload = <String, dynamic>{
      'customerCode': request.customerCode,
      'customerName': request.customerName,
      'phone': request.phone,
      'email': request.email,
      'contractNo': request.contractNo,
      'itemCode': request.itemCode,
      'serialNumber': request.serialNumber,
      'mfrSerialno': request.mfrSerialno,
      'currentStatus': request.currentStatus,
      'priority': request.priority,
      'assignedTech': request.assignedTech,
      'serviceType': request.serviceType,
      'serviceNo': request.serviceNo.trim(),
      'createdDate': request.createdDate,
      'closedDate': request.closedDate,
      'originType': request.originType,
      'problemType': request.problemType,
      'problemSubType': request.problemSubType,
      'callType': request.callType,
      'jobSheet': request.jobSheet,
      'tourClaim': request.tourClaim,
      'subjects': request.subjects,
      'tourStartDate': request.tourStartDate,
      'tourEndDate': request.tourEndDate,
      'tourLocation': request.tourLocation,
      'repairAssesmentType': request.repairAssesmentType,
      'projectCode': request.projectCode,
      'chargeable': request.chargeable,
      'remarks': request.remarks,
      'expenseAmount': request.expenseAmount,
    };
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': ApiConstants.basicAuthorization,
    };

    print('CREATE SERVICE CALL URL: $uri');
    print('CREATE SERVICE CALL HEADERS: $headers');
    print('CREATE SERVICE CALL VERSION: payload-v2');
    print('CREATE SERVICE CALL REQUEST KEYS: ${payload.keys.toList()}');
    print('CREATE SERVICE CALL REQUEST: ${jsonEncode(payload)}');

    final response = await http.post(
      uri,
      headers: headers,
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

  Future<Map<String, dynamic>> uploadServiceAttachments({
    required String serviceNo,
    required String customerCode,
    required List<XFile> files,
  }) async {
    final normalizedServiceNo = serviceNo.trim();
    final normalizedCustomerCode = customerCode.trim();
    if (normalizedServiceNo.isEmpty) {
      throw Exception('ServiceNo is required for attachment upload');
    }
    if (normalizedCustomerCode.isEmpty) {
      throw Exception('CustomerCode is required for attachment upload');
    }
    if (files.isEmpty) {
      return <String, dynamic>{'message': 'No attachments selected'};
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.uploadImagePath}');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = ApiConstants.basicAuthorization
      ..fields['ServiceNo'] = normalizedServiceNo
      ..fields['CustomerCode'] = normalizedCustomerCode;

    for (final file in files) {
      final resolvedName = file.name.trim().isNotEmpty
          ? file.name.trim()
          : _fallbackFileName(file.path);
      if (!kIsWeb && file.path.trim().isNotEmpty) {
        final localFile = File(file.path);
        if (!await localFile.exists()) {
          throw Exception('Attachment not found: $resolvedName');
        }
        final sizeInBytes = await localFile.length();
        if (sizeInBytes <= 0) {
          throw Exception('Attachment is empty: $resolvedName');
        }
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            filename: resolvedName,
          ),
        );
        continue;
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Attachment is empty: $resolvedName');
      }
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: resolvedName),
      );
    }

    print('UPLOAD IMAGE URL: $uri');
    print('UPLOAD IMAGE FIELDS: ${request.fields}');
    print('UPLOAD IMAGE FILE COUNT: ${request.files.length}');

    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 180));
    final responseBody = await streamedResponse.stream.bytesToString();

    print('UPLOAD IMAGE STATUS: ${streamedResponse.statusCode}');
    print('UPLOAD IMAGE RESPONSE: $responseBody');

    Map<String, dynamic> responseData = <String, dynamic>{};
    if (responseBody.isNotEmpty) {
      final dynamic decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        responseData = decoded;
      } else {
        responseData = <String, dynamic>{'data': decoded};
      }
    }

    if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
      return responseData;
    }

    final message = (responseData['message'] ?? responseBody).toString().trim();
    throw Exception(
      message.isNotEmpty
          ? message
          : 'Attachment upload failed (${streamedResponse.statusCode})',
    );
  }

  String _fallbackFileName(String path) {
    final normalized = path.trim();
    if (normalized.isEmpty) return 'attachment.jpg';
    final segments = normalized.split('/');
    final last = segments.isEmpty ? normalized : segments.last;
    final cleaned = last.trim();
    if (cleaned.isEmpty) return 'attachment.jpg';
    return cleaned;
  }
}
