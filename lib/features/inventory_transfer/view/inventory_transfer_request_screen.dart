import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/session/user_session.dart';

class InventoryTransferRequestScreen extends StatefulWidget {
  const InventoryTransferRequestScreen({super.key});

  @override
  State<InventoryTransferRequestScreen> createState() =>
      _InventoryTransferRequestScreenState();
}

class _InventoryTransferRequestScreenState
    extends State<InventoryTransferRequestScreen> {
  static const String _noneOption = 'None';
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _byDepartmentController = TextEditingController();
  final TextEditingController _responsibleDepartmentController =
      TextEditingController();
  final TextEditingController _employeeCodeController = TextEditingController();
  final TextEditingController _teamController = TextEditingController();
  final TextEditingController _importantNoteController =
      TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  final TextEditingController _documentNoController = TextEditingController();
  final TextEditingController _postingDateController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _documentDateController = TextEditingController();
  final TextEditingController _opportunityNoController =
      TextEditingController();
  final TextEditingController _connectedTransferNoController =
      TextEditingController();

  final TextEditingController _demoStartDateController =
      TextEditingController();
  final TextEditingController _demoEndDateController = TextEditingController();
  final TextEditingController _expectedReturnDateController =
      TextEditingController();
  final TextEditingController _salesOrderNoController = TextEditingController();
  final TextEditingController _serviceCallNoController =
      TextEditingController();

  String? _businessPartner;
  String? _transferType;
  String _status = 'Open';
  String? _fromWarehouse;
  String? _toWarehouse;
  String? _salesOrderNo;
  String? _serviceCallNo;
  String? _employeeCode;
  String? _opportunityNo;
  String? _connectedTransferNo;
  bool _isSubmitting = false;

  List<String> _businessPartnerOptions = const <String>[];
  final List<String> _transferTypeOptions = <String>['Issue', 'Receive'];
  final List<String> _statusOptions = <String>['Open', 'Closed', 'Pending'];
  final List<String> _departmentOptions = <String>[
    'Engineering',
    'Support',
    'Supply Chain Mgmt',
    'R&D',
    'Accounts',
    'Pre Sales',
    'Production',
    'Sales',
    'Support Production',
    'Projects',
    'IT',
    'HR',
    'Audit',
    'Operation',
    'Admin',
  ];
  List<_WarehouseOption> _warehouseOptions = const <_WarehouseOption>[];
  Map<String, String> _warehouseLabelsByCode = const <String, String>{};
  List<_SalesOrderOption> _salesOrderOptions = const <_SalesOrderOption>[];
  Map<String, String> _salesOrderLabelsByNo = const <String, String>{};
  List<_ServiceCallOption> _serviceCallOptions = const <_ServiceCallOption>[];
  Map<String, String> _serviceCallLabelsById = const <String, String>{};
  List<_EmployeeOption> _employeeOptions = const <_EmployeeOption>[];
  Map<String, String> _employeeLabelsByCode = const <String, String>{};
  Map<String, String> _employeeTeamsByCode = const <String, String>{};
  List<_OpportunityOption> _opportunityOptions = const <_OpportunityOption>[];
  Map<String, String> _opportunityLabelsByNo = const <String, String>{};
  List<_ConnectedTransferOption> _connectedTransferOptions =
      const <_ConnectedTransferOption>[];
  Map<String, _ItemOption> _itemOptionsByCode = const <String, _ItemOption>{};
  Map<String, String> _connectedTransferLabelsByNo = const <String, String>{};
  List<_ItemOption> _itemOptions = const <_ItemOption>[];
  List<_ProjectOption> _projectOptions = const <_ProjectOption>[];
  Map<String, String> _projectLabelsByCode = const <String, String>{};

  final List<_InventoryItemRow> _items = <_InventoryItemRow>[
    _InventoryItemRow(),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _documentDateController.text = _formatDate(now);
    _postingDateController.text = _formatDate(now);
    _fetchNextInventoryTransferNumber();
    _fetchBusinessPartners();
    _fetchWarehouses();
    _fetchSalesOrders();
    _fetchServiceCalls();
    _fetchEmployees();
    _fetchOpportunities();
    _fetchConnectedTransfers();
    _fetchItems();
    _fetchProjects();
  }

  @override
  void dispose() {
    _byDepartmentController.dispose();
    _responsibleDepartmentController.dispose();
    _employeeCodeController.dispose();
    _teamController.dispose();
    _importantNoteController.dispose();
    _remarksController.dispose();

    _documentNoController.dispose();
    _postingDateController.dispose();
    _dueDateController.dispose();
    _documentDateController.dispose();
    _opportunityNoController.dispose();
    _connectedTransferNoController.dispose();

    _demoStartDateController.dispose();
    _demoEndDateController.dispose();
    _expectedReturnDateController.dispose();
    _salesOrderNoController.dispose();
    _serviceCallNoController.dispose();

    for (final row in _items) {
      row.dispose();
    }
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

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

  String _readValue(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      final value = row[key];
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  String _toApiDate(String input) {
    final value = input.trim();
    if (value.isEmpty) {
      return '';
    }

    final parts = value.split('/');
    if (parts.length == 3) {
      final day = parts[0].padLeft(2, '0');
      final month = parts[1].padLeft(2, '0');
      final year = parts[2];
      return '$year-$month-$day';
    }

    return value;
  }

  String _extractLeadingCode(String input) {
    final value = input.trim();
    if (value.isEmpty) {
      return '';
    }

    final separatorIndex = value.indexOf('-');
    if (separatorIndex <= 0) {
      return value;
    }

    return value.substring(0, separatorIndex).trim();
  }

  List<String> _withNoneStringOption(List<String> options) {
    final normalized = options
        .where((option) => option.trim().isNotEmpty)
        .where(
          (option) => option.trim().toLowerCase() != _noneOption.toLowerCase(),
        )
        .toList(growable: false);
    return <String>[_noneOption, ...normalized];
  }

  List<_PickerOption> _withNonePickerOption(List<_PickerOption> options) {
    return <_PickerOption>[
      const _PickerOption(value: _noneOption, label: _noneOption),
      ...options.where(
        (option) =>
            option.value.trim().toLowerCase() != _noneOption.toLowerCase(),
      ),
    ];
  }

  bool _isNoneOrEmpty(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ||
        normalized.toLowerCase() == _noneOption.toLowerCase();
  }

  String? _normalizeSelectedOption(String? value) {
    return _isNoneOrEmpty(value) ? null : value!.trim();
  }

  void _putIfNotBlank(Map<String, dynamic> target, String key, String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isNotEmpty) {
      target[key] = normalized;
    }
  }

  Future<void> _fetchNextInventoryTransferNumber() async {
    try {
      final uri = _buildNoCacheUri(
        ApiConstants.getNextInventoryTransferNumberPath,
      );
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get next inventory transfer number failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from next inventory transfer API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid next inventory transfer response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid next inventory transfer response format');
      }

      String nextNumber = '';
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        nextNumber = _readValue(row, <String>[
          'InventorytransferReqNo',
          'InventoryTransferReqNo',
          'InventoryTransferNumber',
          'DocNum',
        ]);
        if (nextNumber.isNotEmpty) {
          break;
        }
      }

      if (!mounted || nextNumber.isEmpty) {
        return;
      }

      _documentNoController.text = nextNumber;
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load document number')),
      );
    }
  }

  Future<void> _fetchBusinessPartners() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getInventoryBpMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get inventory BP master failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from inventory BP master API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid inventory BP master response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid inventory BP master response format');
      }

      final options = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final bpCode = _readValue(row, <String>['BPCode', 'CardCode', 'Code']);
        final bpName = _readValue(row, <String>['BPName', 'CardName', 'Name']);

        String label = '';
        if (bpCode.isNotEmpty && bpName.isNotEmpty) {
          label = '$bpCode-$bpName';
        } else if (bpCode.isNotEmpty) {
          label = bpCode;
        } else if (bpName.isNotEmpty) {
          label = bpName;
        }

        if (label.trim().isNotEmpty) {
          options.add(label.trim());
        }
      }

      if (!mounted) {
        return;
      }

      final sortedOptions = options.toList()..sort();
      setState(() {
        _businessPartnerOptions = sortedOptions;
        if (_businessPartner != null &&
            !_businessPartnerOptions.contains(_businessPartner)) {
          _businessPartner = null;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load business partner list')),
      );
    }
  }

  Future<void> _fetchWarehouses() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getInventoryWarehousePath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get inventory warehouse failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from inventory warehouse API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid inventory warehouse response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid inventory warehouse response format');
      }

      final optionsByCode = <String, _WarehouseOption>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final code = _readValue(row, <String>[
          'WarehouseCode',
          'WhsCode',
          'Code',
        ]);
        final name = _readValue(row, <String>[
          'WarehouseName',
          'WhsName',
          'Name',
        ]);
        final location = _readValue(row, <String>['Location', 'Loc', 'Branch']);

        if (code.isEmpty) {
          continue;
        }

        final parts = <String>[code];
        if (name.isNotEmpty) {
          parts.add(name);
        }
        if (location.isNotEmpty) {
          parts.add(location);
        }

        optionsByCode[code] = _WarehouseOption(
          code: code,
          label: parts.join('-'),
        );
      }

      if (!mounted) {
        return;
      }

      final sortedOptions = optionsByCode.values.toList()
        ..sort((a, b) => a.label.compareTo(b.label));
      setState(() {
        _warehouseOptions = sortedOptions;
        _warehouseLabelsByCode = Map<String, String>.unmodifiable(
          optionsByCode.map(
            (key, value) => MapEntry<String, String>(key, value.label),
          ),
        );
        if (_fromWarehouse != null &&
            !_warehouseOptions.any((option) => option.code == _fromWarehouse)) {
          _fromWarehouse = null;
        }
        if (_toWarehouse != null &&
            !_warehouseOptions.any((option) => option.code == _toWarehouse)) {
          _toWarehouse = null;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load warehouse list')),
      );
    }
  }

  Future<void> _fetchSalesOrders() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getInventorySalesOrderNoPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get inventory sales order failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from inventory sales order API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid inventory sales order response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid inventory sales order response format');
      }

      final optionsByNo = <String, _SalesOrderOption>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final soNo = _readValue(row, <String>['SONo', 'SoNo', 'DocNum']);
        final soDate = _readValue(row, <String>['SODate', 'DocDate', 'Date']);
        final bpName = _readValue(row, <String>[
          'BPName',
          'CustomerName',
          'CardName',
        ]);

        if (soNo.isEmpty) {
          continue;
        }

        final parts = <String>[soNo];
        if (soDate.isNotEmpty) {
          parts.add(soDate);
        }
        if (bpName.isNotEmpty) {
          parts.add(bpName);
        }

        optionsByNo[soNo] = _SalesOrderOption(
          soNo: soNo,
          label: parts.join('-'),
        );
      }

      if (!mounted) {
        return;
      }

      final sortedOptions = optionsByNo.values.toList()
        ..sort((a, b) => a.label.compareTo(b.label));
      setState(() {
        _salesOrderOptions = sortedOptions;
        _salesOrderLabelsByNo = Map<String, String>.unmodifiable(
          optionsByNo.map(
            (key, value) => MapEntry<String, String>(key, value.label),
          ),
        );
        if (_salesOrderNo != null &&
            !_salesOrderOptions.any((option) => option.soNo == _salesOrderNo)) {
          _salesOrderNo = null;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load sales order list')),
      );
    }
  }

  Future<void> _fetchServiceCalls() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getInventoryServiceCallNoPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get inventory service call failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from inventory service call API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid inventory service call response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid inventory service call response format');
      }

      final optionsById = <String, _ServiceCallOption>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final callId = _readValue(row, <String>['CallID', 'CallId', 'ID']);
        final bpCode = _readValue(row, <String>['BPCode', 'CardCode', 'Code']);
        final bpName = _readValue(row, <String>['BPName', 'CardName', 'Name']);

        if (callId.isEmpty) {
          continue;
        }

        final parts = <String>[callId];
        if (bpCode.isNotEmpty) {
          parts.add(bpCode);
        }
        if (bpName.isNotEmpty) {
          parts.add(bpName);
        }

        optionsById[callId] = _ServiceCallOption(
          callId: callId,
          label: parts.join('-'),
        );
      }

      if (!mounted) {
        return;
      }

      final sortedOptions = optionsById.values.toList()
        ..sort((a, b) => a.label.compareTo(b.label));
      setState(() {
        _serviceCallOptions = sortedOptions;
        _serviceCallLabelsById = Map<String, String>.unmodifiable(
          optionsById.map(
            (key, value) => MapEntry<String, String>(key, value.label),
          ),
        );
        if (_serviceCallNo != null &&
            !_serviceCallOptions.any(
              (option) => option.callId == _serviceCallNo,
            )) {
          _serviceCallNo = null;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load service call list')),
      );
    }
  }

  Future<void> _fetchEmployees() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getInventoryEmployeeCodePath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get inventory employee failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from inventory employee API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid inventory employee response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid inventory employee response format');
      }

      final optionsByCode = <String, _EmployeeOption>{};
      final teamsByCode = <String, String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final employeeCode = _readValue(row, <String>[
          'EmployeeCode',
          'EmpCode',
          'Code',
        ]);
        final firstName = _readValue(row, <String>['FirstName', 'firstName']);
        final middleName = _readValue(row, <String>[
          'MiddleName',
          'middleName',
        ]);
        final lastName = _readValue(row, <String>['LastName', 'lastName']);

        if (employeeCode.isEmpty) {
          continue;
        }

        final fullNameParts = <String>[
          if (firstName.isNotEmpty) firstName,
          if (middleName.isNotEmpty) middleName,
          if (lastName.isNotEmpty) lastName,
        ];

        String label = employeeCode;
        if (fullNameParts.isNotEmpty) {
          label = '$employeeCode - ${fullNameParts.join(' ')}';
        }
        final team = _readValue(row, <String>[
          'Team',
          'TeamName',
          'TeamCode',
          'GroupName',
          'Department',
          'DeptName',
        ]);

        optionsByCode[employeeCode] = _EmployeeOption(
          code: employeeCode,
          label: label,
        );
        if (team.isNotEmpty) {
          teamsByCode[employeeCode] = team;
        }
      }

      if (!mounted) {
        return;
      }

      final sortedOptions = optionsByCode.values.toList()
        ..sort((a, b) => a.label.compareTo(b.label));
      setState(() {
        _employeeOptions = sortedOptions;
        _employeeLabelsByCode = Map<String, String>.unmodifiable(
          optionsByCode.map(
            (key, value) => MapEntry<String, String>(key, value.label),
          ),
        );
        _employeeTeamsByCode = Map<String, String>.unmodifiable(teamsByCode);
        if (_employeeCode != null &&
            !_employeeOptions.any((option) => option.code == _employeeCode)) {
          _employeeCode = null;
          _employeeCodeController.text = '';
          _teamController.clear();
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load employee list')),
      );
    }
  }

  Future<void> _fetchOpportunities() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getInventoryOpportunityNoPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get inventory opportunity failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from inventory opportunity API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid inventory opportunity response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid inventory opportunity response format');
      }

      final optionsByNo = <String, _OpportunityOption>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final opportunityNo = _readValue(row, <String>[
          'OpportunityNo',
          'OppNo',
          'DocNum',
        ]);
        final opportunityName = _readValue(row, <String>[
          'OpportunityName',
          'OppName',
          'Name',
        ]);
        final bpCode = _readValue(row, <String>['BPCode', 'CardCode', 'Code']);

        if (opportunityNo.isEmpty) {
          continue;
        }

        final parts = <String>[opportunityNo];
        if (opportunityName.isNotEmpty) {
          parts.add(opportunityName);
        }
        if (bpCode.isNotEmpty) {
          parts.add(bpCode);
        }

        optionsByNo[opportunityNo] = _OpportunityOption(
          opportunityNo: opportunityNo,
          label: parts.join('-'),
        );
      }

      if (!mounted) {
        return;
      }

      final sortedOptions = optionsByNo.values.toList()
        ..sort((a, b) => a.label.compareTo(b.label));
      setState(() {
        _opportunityOptions = sortedOptions;
        _opportunityLabelsByNo = Map<String, String>.unmodifiable(
          optionsByNo.map(
            (key, value) => MapEntry<String, String>(key, value.label),
          ),
        );
        if (_opportunityNo != null &&
            !_opportunityOptions.any(
              (option) => option.opportunityNo == _opportunityNo,
            )) {
          _opportunityNo = null;
          _opportunityNoController.text = '';
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load opportunity list')),
      );
    }
  }

  Future<void> _fetchConnectedTransfers() async {
    try {
      final uri = _buildNoCacheUri(
        ApiConstants.getInventoryConnectedTransferNoPath,
      );
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get inventory connected transfer failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from inventory connected transfer API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception(
            'Invalid inventory connected transfer response format',
          );
        }
        rows = nested;
      } else {
        throw Exception('Invalid inventory connected transfer response format');
      }

      final optionsByNo = <String, _ConnectedTransferOption>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final transferNo = _readValue(row, <String>[
          'TransferNo',
          'InventoryTransferNo',
          'DocNum',
        ]);
        final customerVendorName = _readValue(row, <String>[
          'CustomerVendorName',
          'CustomerName',
          'VendorName',
          'CardName',
        ]);
        final transferType = _readValue(row, <String>['TransferType', 'Type']);

        if (transferNo.isEmpty) {
          continue;
        }

        final parts = <String>[transferNo];
        if (customerVendorName.isNotEmpty) {
          parts.add(customerVendorName);
        }
        if (transferType.isNotEmpty) {
          parts.add(transferType);
        }

        optionsByNo[transferNo] = _ConnectedTransferOption(
          transferNo: transferNo,
          label: parts.join('-'),
        );
      }

      if (!mounted) {
        return;
      }

      final sortedOptions = optionsByNo.values.toList()
        ..sort((a, b) => a.label.compareTo(b.label));
      setState(() {
        _connectedTransferOptions = sortedOptions;
        _connectedTransferLabelsByNo = Map<String, String>.unmodifiable(
          optionsByNo.map(
            (key, value) => MapEntry<String, String>(key, value.label),
          ),
        );
        if (_connectedTransferNo != null &&
            !_connectedTransferOptions.any(
              (option) => option.transferNo == _connectedTransferNo,
            )) {
          _connectedTransferNo = null;
          _connectedTransferNoController.text = '';
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load connected transfer list')),
      );
    }
  }

  Future<void> _fetchItems() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getInventoryItemMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get inventory item failed (${response.statusCode})');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from inventory item API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid inventory item response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid inventory item response format');
      }

      final optionsByCode = <String, _ItemOption>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final itemCode = _readValue(row, <String>[
          'ItemCode',
          'Code',
          'ItemNo',
        ]);
        final itemDescription = _readValue(row, <String>[
          'ItemDescription',
          'Description',
          'ItemName',
          'Name',
        ]);

        if (itemCode.isEmpty) {
          continue;
        }

        optionsByCode[itemCode] = _ItemOption(
          itemCode: itemCode,
          description: itemDescription,
        );
      }

      if (!mounted) {
        return;
      }

      final sortedOptions = optionsByCode.values.toList()
        ..sort((a, b) => a.itemCode.compareTo(b.itemCode));
      setState(() {
        _itemOptions = sortedOptions;
        _itemOptionsByCode = Map<String, _ItemOption>.unmodifiable(
          optionsByCode,
        );
        for (final row in _items) {
          final selectedCode = row.itemCodeController.text.trim();
          if (selectedCode.isNotEmpty &&
              !_itemOptionsByCode.containsKey(selectedCode)) {
            row.itemCodeController.text = '';
            row.descriptionController.text = '';
          }
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to load item list')));
    }
  }

  Future<void> _fetchProjects() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getInventoryProjectMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get inventory project failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from inventory project API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid inventory project response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid inventory project response format');
      }

      final optionsByCode = <String, _ProjectOption>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final projectCode = _readValue(row, <String>[
          'ProjectCode',
          'PrjCode',
          'Code',
        ]);
        final projectName = _readValue(row, <String>[
          'ProjectName',
          'PrjName',
          'Name',
        ]);

        if (projectCode.isEmpty) {
          continue;
        }

        String label = projectCode;
        if (projectName.isNotEmpty) {
          label = '$projectCode-$projectName';
        }

        optionsByCode[projectCode] = _ProjectOption(
          projectCode: projectCode,
          label: label,
        );
      }

      if (!mounted) {
        return;
      }

      final sortedOptions = optionsByCode.values.toList()
        ..sort((a, b) => a.label.compareTo(b.label));
      setState(() {
        _projectOptions = sortedOptions;
        _projectLabelsByCode = Map<String, String>.unmodifiable(
          optionsByCode.map(
            (key, value) => MapEntry<String, String>(key, value.label),
          ),
        );
        for (final row in _items) {
          final selectedCode = row.projectController.text.trim();
          if (selectedCode.isNotEmpty &&
              !_projectOptions.any(
                (option) => option.projectCode == selectedCode,
              )) {
            row.projectController.text = '';
          }
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load project list')),
      );
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    controller.text = _formatDate(picked);
  }

  void _addItemRow() {
    setState(() {
      final row = _InventoryItemRow();
      row.fromWhsController.text = _fromWarehouse ?? '';
      row.toWhsController.text = _toWarehouse ?? '';
      _items.add(row);
    });
  }

  void _removeItemRow(int index) {
    if (_items.length == 1) return;
    setState(() {
      final row = _items.removeAt(index);
      row.dispose();
    });
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  void _applyHeaderWarehousesToRows() {
    for (final row in _items) {
      row.fromWhsController.text = _fromWarehouse ?? '';
      row.toWhsController.text = _toWarehouse ?? '';
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = <String, dynamic>{
      'DocumentNo': _documentNoController.text.trim(),
      'PostingDate': _toApiDate(_postingDateController.text),
      'DueDate': _toApiDate(_dueDateController.text),
      'DocumentDate': _toApiDate(_documentDateController.text),
      'APKUSERID': UserSession.loggedInEmail,
      'Lines': _items
          .map((row) {
            final line = <String, dynamic>{
              'Description': row.descriptionController.text.trim(),
              'SerialNo': row.serialNoController.text.trim(),
              'Quantity':
                  double.tryParse(row.quantityController.text.trim()) ?? 0,
              'CheckedBy': row.checkedByController.text.trim(),
              'CheckedDate': _toApiDate(row.checkedDateController.text),
              'NextCheck': _toApiDate(row.nextCheckController.text),
              'Remarks': row.remarksController.text.trim(),
            };
            _putIfNotBlank(line, 'ItemCode', row.itemCodeController.text);
            _putIfNotBlank(line, 'FromWhs', row.fromWhsController.text);
            _putIfNotBlank(line, 'ToWhs', row.toWhsController.text);
            _putIfNotBlank(line, 'Project', row.projectController.text);
            if (row.previousDateController.text.trim().isNotEmpty) {
              line['PreviousDate'] = _toApiDate(
                row.previousDateController.text,
              );
            }
            return line;
          })
          .toList(growable: false),
    };
    _putIfNotBlank(payload, 'TransferType', _transferType);
    _putIfNotBlank(payload, 'FromWarehouse', _fromWarehouse);
    _putIfNotBlank(payload, 'ToWarehouse', _toWarehouse);
    _putIfNotBlank(
      payload,
      'DemoStartDate',
      _toApiDate(_demoStartDateController.text),
    );
    _putIfNotBlank(
      payload,
      'DemoEndDate',
      _toApiDate(_demoEndDateController.text),
    );
    _putIfNotBlank(
      payload,
      'ExpectedReturnDate',
      _toApiDate(_expectedReturnDateController.text),
    );
    _putIfNotBlank(payload, 'SalesOrderNo', _salesOrderNo);
    _putIfNotBlank(payload, 'ServiceCallNo', _serviceCallNo);
    _putIfNotBlank(payload, 'ByDepartment', _byDepartmentController.text);
    _putIfNotBlank(
      payload,
      'ResponsibleDepartment',
      _responsibleDepartmentController.text,
    );
    _putIfNotBlank(payload, 'EmployeeCode', _employeeCode);
    _putIfNotBlank(payload, 'Team', _teamController.text);
    _putIfNotBlank(payload, 'Status', _status);
    _putIfNotBlank(payload, 'ImportantNote', _importantNoteController.text);
    _putIfNotBlank(payload, 'Remarks', _remarksController.text);
    _putIfNotBlank(payload, 'OpportunityNo', _opportunityNo);
    _putIfNotBlank(payload, 'ConnectedTransferNo', _connectedTransferNo);
    _putIfNotBlank(
      payload,
      'Businesspartner',
      _extractLeadingCode(_businessPartner ?? ''),
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.createInventoryTransferRequestPath}',
      );
      final response = await http
          .post(
            uri,
            headers: <String, String>{
              ..._getHeaders(),
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Submit failed (${response.statusCode})');
      }

      String message = 'Inventory Transfer Request submitted successfully';
      final body = response.body.trim();
      if (body.isNotEmpty) {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          final serverMessage = decoded['message']?.toString().trim();
          if (serverMessage != null && serverMessage.isNotEmpty) {
            message = serverMessage;
          }

          final serverDocNo = _readValue(decoded, <String>[
            'DocumentNo',
            'InventorytransferReqNo',
            'InventoryTransferReqNo',
            'DocNo',
            'DocNum',
          ]);
          if (serverDocNo.isNotEmpty) {
            _documentNoController.text = serverDocNo;
          }
        }
      }

      final documentNo = _documentNoController.text.trim();
      if (documentNo.isNotEmpty &&
          !message.toLowerCase().contains(documentNo.toLowerCase())) {
        message = '$message\nDocument No: $documentNo';
      }

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Success'),
            content: Text(message),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Submit failed: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  int get _screenChildCount => 8 + _items.length;

  Widget _buildScreenChild(int index) {
    if (index == 0) {
      return _buildTransferDetailsSection();
    }
    if (index == 1 ||
        index == 3 ||
        index == 5 ||
        index == _screenChildCount - 1) {
      return const SizedBox(height: 10);
    }
    if (index == 2) {
      return _buildDepartmentNotesSection();
    }
    if (index == 4) {
      return _buildDocumentDetailsSection();
    }
    if (index == 6) {
      return _buildItemsHeaderCard();
    }

    final itemIndex = index - 7;
    if (itemIndex >= 0 && itemIndex < _items.length) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: RepaintBoundary(child: _itemRowCard(itemIndex)),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTransferDetailsSection() {
    return RepaintBoundary(
      child: _sectionCard(
        title: 'Transfer Details',
        child: Column(
          children: [
            _dropdownField(
              label: 'Business Partner',
              value: _businessPartner,
              onTap: () async {
                final selected = await _showOptionPicker(
                  title: 'Business Partner',
                  options: _withNonePickerOption(
                    _businessPartnerOptions
                        .map(
                          (option) =>
                              _PickerOption(value: option, label: option),
                        )
                        .toList(growable: false),
                  ),
                );
                if (selected == null) return;
                setState(
                  () => _businessPartner = _normalizeSelectedOption(selected),
                );
              },
            ),
            _dropdownField(
              label: 'Transfer Type',
              value: _transferType,
              options: _transferTypeOptions,
              onChanged: (value) {
                setState(() => _transferType = value);
              },
            ),
            _warehouseDropdownField(
              label: 'From Warehouse',
              value: _fromWarehouse,
              options: _warehouseOptions,
              onChanged: (value) => setState(() {
                _fromWarehouse = value;
                _applyHeaderWarehousesToRows();
              }),
              requiredField: true,
            ),
            _warehouseDropdownField(
              label: 'To Warehouse',
              value: _toWarehouse,
              options: _warehouseOptions,
              onChanged: (value) => setState(() {
                _toWarehouse = value;
                _applyHeaderWarehousesToRows();
              }),
              requiredField: true,
            ),
            _dateField(
              label: 'Demo Start Date',
              controller: _demoStartDateController,
            ),
            _dateField(
              label: 'Demo End Date',
              controller: _demoEndDateController,
            ),
            _dateField(
              label: 'Expected Return Date',
              controller: _expectedReturnDateController,
            ),
            _salesOrderDropdownField(
              label: 'Sales Order No',
              value: _salesOrderNo,
              options: _salesOrderOptions,
              onChanged: (value) => setState(() {
                _salesOrderNo = value;
                _salesOrderNoController.text = value ?? '';
              }),
            ),
            _serviceCallDropdownField(
              label: 'Service Call No',
              value: _serviceCallNo,
              options: _serviceCallOptions,
              onChanged: (value) => setState(() {
                _serviceCallNo = value;
                _serviceCallNoController.text = value ?? '';
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentNotesSection() {
    return RepaintBoundary(
      child: _sectionCard(
        title: 'Department & Notes',
        child: Column(
          children: [
            _dropdownField(
              label: 'By Department',
              value: _byDepartmentController.text.isEmpty
                  ? null
                  : _byDepartmentController.text,
              options: _departmentOptions,
              onChanged: (value) => setState(() {
                _byDepartmentController.text = value ?? '';
              }),
            ),
            _dropdownField(
              label: 'Responsible Department',
              value: _responsibleDepartmentController.text.isEmpty
                  ? null
                  : _responsibleDepartmentController.text,
              options: _departmentOptions,
              onChanged: (value) => setState(() {
                _responsibleDepartmentController.text = value ?? '';
              }),
            ),
            _employeeDropdownField(
              label: 'Employee Code',
              value: _employeeCode,
              options: _employeeOptions,
              onChanged: (value) => setState(() {
                _employeeCode = value;
                _employeeCodeController.text = value ?? '';
                _teamController.text = value == null
                    ? ''
                    : (_employeeTeamsByCode[value] ?? '');
              }),
            ),
            _textField(label: 'Team', controller: _teamController),
            _dropdownField(
              label: 'Status',
              value: _status,
              options: _statusOptions,
              onChanged: (value) {
                setState(() => _status = value ?? '');
              },
            ),
            _textField(
              label: 'Important Note',
              controller: _importantNoteController,
              maxLines: 3,
            ),
            _textField(
              label: 'Remarks',
              controller: _remarksController,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentDetailsSection() {
    return RepaintBoundary(
      child: _sectionCard(
        title: 'Document Details',
        child: Column(
          children: [
            _textField(
              label: 'Document No',
              controller: _documentNoController,
              readOnly: true,
            ),
            _dateField(
              label: 'Posting Date',
              controller: _postingDateController,
            ),
            _dateField(label: 'Due Date', controller: _dueDateController),
            _dateField(
              label: 'Document Date',
              controller: _documentDateController,
            ),
            _opportunityDropdownField(
              label: 'Opportunity No',
              value: _opportunityNo,
              options: _opportunityOptions,
              onChanged: (value) => setState(() {
                _opportunityNo = value;
                _opportunityNoController.text = value ?? '';
              }),
            ),
            _connectedTransferDropdownField(
              label: 'Connected Transfer No',
              value: _connectedTransferNo,
              options: _connectedTransferOptions,
              onChanged: (value) => setState(() {
                _connectedTransferNo = value;
                _connectedTransferNoController.text = value ?? '';
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsHeaderCard() {
    return RepaintBoundary(
      child: _sectionCard(
        title: 'Items',
        child: Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _addItemRow,
            icon: const Icon(Icons.add),
            label: const Text('Add Row'),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Transfer Request'),
        actions: [
          TextButton(
            onPressed: _onCancel,
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _isSubmitting ? null : _onSubmit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _screenChildCount,
            itemBuilder: (context, index) => _buildScreenChild(index),
          ),
        ),
      ),
    );
  }

  Widget _itemRowCard(int index) {
    final row = _items[index];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Row ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (_items.length > 1)
                IconButton(
                  onPressed: () => _removeItemRow(index),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove row',
                ),
            ],
          ),
          _itemDropdownField(
            label: 'Item Code',
            value: row.itemCodeController.text.trim().isEmpty
                ? null
                : row.itemCodeController.text.trim(),
            options: _itemOptions,
            onChanged: (value) {
              final item = value == null ? null : _itemOptionsByCode[value];
              setState(() {
                row.itemCodeController.text = value ?? '';
                row.descriptionController.text = item?.description ?? '';
              });
            },
          ),
          _textField(
            label: 'Description',
            controller: row.descriptionController,
            maxLines: 2,
            readOnly: true,
          ),
          _textField(label: 'Serial No', controller: row.serialNoController),
          _textField(
            label: 'Quantity',
            controller: row.quantityController,
            keyboardType: TextInputType.number,
          ),
          _warehouseDropdownField(
            label: 'From Whs',
            value: row.fromWhsController.text.trim().isEmpty
                ? null
                : row.fromWhsController.text.trim(),
            options: _warehouseOptions,
            onChanged: (value) => setState(() {
              row.fromWhsController.text = value ?? '';
            }),
          ),
          _warehouseDropdownField(
            label: 'To Whs',
            value: row.toWhsController.text.trim().isEmpty
                ? null
                : row.toWhsController.text.trim(),
            options: _warehouseOptions,
            onChanged: (value) => setState(() {
              row.toWhsController.text = value ?? '';
            }),
          ),
          _projectDropdownField(
            label: 'Project',
            value: row.projectController.text.trim().isEmpty
                ? null
                : row.projectController.text.trim(),
            options: _projectOptions,
            onChanged: (value) => setState(() {
              row.projectController.text = value ?? '';
            }),
          ),
          _textField(label: 'Checked By', controller: row.checkedByController),
          _dateField(
            label: 'Checked Date',
            controller: row.checkedDateController,
          ),
          _dateField(
            label: 'Previous Date',
            controller: row.previousDateController,
          ),
          _dateField(label: 'Next Check', controller: row.nextCheckController),
          _textField(label: 'Remarks', controller: row.remarksController),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    List<String> options = const <String>[],
    Future<void> Function()? onTap,
    ValueChanged<String?>? onChanged,
    bool requiredField = false,
  }) {
    if (onTap != null) {
      return _pickerField(
        label: label,
        value: value,
        displayText: value,
        onTap: onTap,
        requiredField: requiredField,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: _isNoneOrEmpty(value) ? null : value,
        isExpanded: true,
        items: _withNoneStringOption(options)
            .map(
              (option) => DropdownMenuItem<String>(
                value: option,
                child: _dropdownLabel(option),
              ),
            )
            .toList(growable: false),
        onChanged: (selected) =>
            onChanged?.call(selected == _noneOption ? null : selected),
        validator: requiredField
            ? (selected) =>
                  (selected == null ||
                      selected.isEmpty ||
                      selected == _noneOption)
                  ? 'Please select $label'
                  : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _warehouseDropdownField({
    required String label,
    required String? value,
    required List<_WarehouseOption> options,
    required ValueChanged<String?> onChanged,
    bool requiredField = false,
  }) {
    return _pickerField(
      label: label,
      value: value,
      displayText: value == null ? null : _warehouseLabelsByCode[value],
      requiredField: requiredField,
      onTap: () async {
        final selected = await _showOptionPicker(
          title: label,
          options: _withNonePickerOption(
            options
                .map(
                  (option) =>
                      _PickerOption(value: option.code, label: option.label),
                )
                .toList(growable: false),
          ),
        );
        if (selected != null) {
          onChanged(_normalizeSelectedOption(selected));
        }
      },
    );
  }

  Widget _salesOrderDropdownField({
    required String label,
    required String? value,
    required List<_SalesOrderOption> options,
    required ValueChanged<String?> onChanged,
    bool allowNone = true,
  }) {
    return _pickerField(
      label: label,
      value: value,
      displayText: value == null ? null : _salesOrderLabelsByNo[value],
      onTap: () async {
        final selected = await _showOptionPicker(
          title: label,
          options: allowNone
              ? _withNonePickerOption(
                  options
                      .map(
                        (option) => _PickerOption(
                          value: option.soNo,
                          label: option.label,
                        ),
                      )
                      .toList(growable: false),
                )
              : options
                    .map(
                      (option) => _PickerOption(
                        value: option.soNo,
                        label: option.label,
                      ),
                    )
                    .toList(growable: false),
        );
        if (selected != null) {
          onChanged(_normalizeSelectedOption(selected));
        }
      },
    );
  }

  Widget _serviceCallDropdownField({
    required String label,
    required String? value,
    required List<_ServiceCallOption> options,
    required ValueChanged<String?> onChanged,
    bool allowNone = true,
  }) {
    return _pickerField(
      label: label,
      value: value,
      displayText: value == null ? null : _serviceCallLabelsById[value],
      onTap: () async {
        final selected = await _showOptionPicker(
          title: label,
          options: allowNone
              ? _withNonePickerOption(
                  options
                      .map(
                        (option) => _PickerOption(
                          value: option.callId,
                          label: option.label,
                        ),
                      )
                      .toList(growable: false),
                )
              : options
                    .map(
                      (option) => _PickerOption(
                        value: option.callId,
                        label: option.label,
                      ),
                    )
                    .toList(growable: false),
        );
        if (selected != null) {
          onChanged(_normalizeSelectedOption(selected));
        }
      },
    );
  }

  Widget _employeeDropdownField({
    required String label,
    required String? value,
    required List<_EmployeeOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return _pickerField(
      label: label,
      value: value,
      displayText: value == null ? null : _employeeLabelsByCode[value],
      onTap: () async {
        final selected = await _showOptionPicker(
          title: label,
          options: _withNonePickerOption(
            options
                .map(
                  (option) =>
                      _PickerOption(value: option.code, label: option.label),
                )
                .toList(growable: false),
          ),
        );
        if (selected != null) {
          onChanged(_normalizeSelectedOption(selected));
        }
      },
    );
  }

  Widget _opportunityDropdownField({
    required String label,
    required String? value,
    required List<_OpportunityOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return _pickerField(
      label: label,
      value: value,
      displayText: value == null ? null : _opportunityLabelsByNo[value],
      onTap: () async {
        final selected = await _showOptionPicker(
          title: label,
          options: _withNonePickerOption(
            options
                .map(
                  (option) => _PickerOption(
                    value: option.opportunityNo,
                    label: option.label,
                  ),
                )
                .toList(growable: false),
          ),
        );
        if (selected != null) {
          onChanged(_normalizeSelectedOption(selected));
        }
      },
    );
  }

  Widget _connectedTransferDropdownField({
    required String label,
    required String? value,
    required List<_ConnectedTransferOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return _pickerField(
      label: label,
      value: value,
      displayText: value == null ? null : _connectedTransferLabelsByNo[value],
      onTap: () async {
        final selected = await _showOptionPicker(
          title: label,
          options: _withNonePickerOption(
            options
                .map(
                  (option) => _PickerOption(
                    value: option.transferNo,
                    label: option.label,
                  ),
                )
                .toList(growable: false),
          ),
        );
        if (selected != null) {
          onChanged(_normalizeSelectedOption(selected));
        }
      },
    );
  }

  Widget _itemDropdownField({
    required String label,
    required String? value,
    required List<_ItemOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return _pickerField(
      label: label,
      value: value,
      displayText: value,
      onTap: () async {
        final selected = await _showOptionPicker(
          title: label,
          options: _withNonePickerOption(
            options
                .map(
                  (option) => _PickerOption(
                    value: option.itemCode,
                    label: option.itemCode,
                    subtitle: option.description,
                  ),
                )
                .toList(growable: false),
          ),
        );
        if (selected != null) {
          onChanged(_normalizeSelectedOption(selected));
        }
      },
    );
  }

  Widget _projectDropdownField({
    required String label,
    required String? value,
    required List<_ProjectOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return _pickerField(
      label: label,
      value: value,
      displayText: value == null ? null : _projectLabelsByCode[value],
      onTap: () async {
        final selected = await _showOptionPicker(
          title: label,
          options: _withNonePickerOption(
            options
                .map(
                  (option) => _PickerOption(
                    value: option.projectCode,
                    label: option.label,
                  ),
                )
                .toList(growable: false),
          ),
        );
        if (selected != null) {
          onChanged(_normalizeSelectedOption(selected));
        }
      },
    );
  }

  Widget _pickerField({
    required String label,
    required String? value,
    required Future<void> Function() onTap,
    String? displayText,
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FormField<String>(
        initialValue: value,
        validator: requiredField
            ? (selected) => (selected == null || selected.isEmpty)
                  ? 'Please select $label'
                  : null
            : null,
        builder: (field) {
          final text = displayText?.trim() ?? '';
          final hasValue = text.isNotEmpty;
          return InkWell(
            onTap: () async {
              await onTap();
              field.didChange(value);
            },
            child: InputDecorator(
              isEmpty: !hasValue,
              decoration: InputDecoration(
                labelText: label,
                hintText: hasValue ? null : 'Select $label',
                border: const OutlineInputBorder(),
                isDense: true,
                errorText: field.errorText,
                suffixIcon: const Icon(Icons.search),
              ),
              child: hasValue
                  ? Text(text, maxLines: 1, overflow: TextOverflow.ellipsis)
                  : const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }

  Future<String?> _showOptionPicker({
    required String title,
    required List<_PickerOption> options,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = options
                .where((option) {
                  final searchText =
                      '${option.label} ${option.subtitle ?? ''} ${option.value}'
                          .toLowerCase();
                  return searchText.contains(query.toLowerCase());
                })
                .toList(growable: false);

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: TextField(
                        autofocus: true,
                        onChanged: (value) =>
                            setModalState(() => query = value),
                        decoration: InputDecoration(
                          labelText: title,
                          hintText: 'Search',
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final option = filtered[index];
                          return ListTile(
                            title: Text(
                              option.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle:
                                option.subtitle == null ||
                                    option.subtitle!.trim().isEmpty
                                ? null
                                : Text(
                                    option.subtitle!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            onTap: () =>
                                Navigator.of(sheetContext).pop(option.value),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dropdownLabel(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }

  Widget _dateField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _pickDate(controller),
        decoration: InputDecoration(
          labelText: label,
          hintText: 'dd/mm/yyyy',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.text.trim().isNotEmpty)
                IconButton(
                  tooltip: 'Clear date',
                  onPressed: () {
                    setState(controller.clear);
                  },
                  icon: const Icon(Icons.close),
                ),
              const Icon(Icons.calendar_today_outlined),
              const SizedBox(width: 8),
            ],
          ),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}

class _InventoryItemRow {
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController serialNoController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController fromWhsController = TextEditingController();
  final TextEditingController toWhsController = TextEditingController();
  final TextEditingController projectController = TextEditingController();
  final TextEditingController checkedByController = TextEditingController();
  final TextEditingController checkedDateController = TextEditingController();
  final TextEditingController previousDateController = TextEditingController();
  final TextEditingController nextCheckController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  void dispose() {
    itemCodeController.dispose();
    descriptionController.dispose();
    serialNoController.dispose();
    quantityController.dispose();
    fromWhsController.dispose();
    toWhsController.dispose();
    projectController.dispose();
    checkedByController.dispose();
    checkedDateController.dispose();
    previousDateController.dispose();
    nextCheckController.dispose();
    remarksController.dispose();
  }
}

class _PickerOption {
  const _PickerOption({
    required this.value,
    required this.label,
    this.subtitle,
  });

  final String value;
  final String label;
  final String? subtitle;
}

class _WarehouseOption {
  const _WarehouseOption({required this.code, required this.label});

  final String code;
  final String label;
}

class _SalesOrderOption {
  const _SalesOrderOption({required this.soNo, required this.label});

  final String soNo;
  final String label;
}

class _ServiceCallOption {
  const _ServiceCallOption({required this.callId, required this.label});

  final String callId;
  final String label;
}

class _EmployeeOption {
  const _EmployeeOption({required this.code, required this.label});

  final String code;
  final String label;
}

class _OpportunityOption {
  const _OpportunityOption({required this.opportunityNo, required this.label});

  final String opportunityNo;
  final String label;
}

class _ConnectedTransferOption {
  const _ConnectedTransferOption({
    required this.transferNo,
    required this.label,
  });

  final String transferNo;
  final String label;
}

class _ItemOption {
  const _ItemOption({required this.itemCode, required this.description});

  final String itemCode;
  final String description;
}

class _ProjectOption {
  const _ProjectOption({required this.projectCode, required this.label});

  final String projectCode;
  final String label;
}
