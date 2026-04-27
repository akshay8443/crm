import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';

class InventoryTransferRequestScreen extends StatefulWidget {
  const InventoryTransferRequestScreen({super.key});

  @override
  State<InventoryTransferRequestScreen> createState() =>
      _InventoryTransferRequestScreenState();
}

class _InventoryTransferRequestScreenState
    extends State<InventoryTransferRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _byDepartmentController = TextEditingController();
  final TextEditingController _responsibleDepartmentController =
      TextEditingController();
  final TextEditingController _employeeCodeController = TextEditingController();
  final TextEditingController _teamController = TextEditingController();
  final TextEditingController _importantNoteController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  final TextEditingController _documentNoController = TextEditingController();
  final TextEditingController _postingDateController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _documentDateController = TextEditingController();
  final TextEditingController _opportunityNoController = TextEditingController();
  final TextEditingController _connectedTransferNoController =
      TextEditingController();

  final TextEditingController _demoStartDateController =
      TextEditingController();
  final TextEditingController _demoEndDateController = TextEditingController();
  final TextEditingController _expectedReturnDateController =
      TextEditingController();
  final TextEditingController _salesOrderNoController = TextEditingController();
  final TextEditingController _serviceCallNoController = TextEditingController();

  String? _businessPartner;
  String _transferType = 'Issue';
  String _status = 'Open';
  String? _fromWarehouse;
  String? _toWarehouse;
  String? _salesOrderNo;
  String? _serviceCallNo;
  String? _employeeCode;
  String? _opportunityNo;
  String? _connectedTransferNo;

  List<String> _businessPartnerOptions = const <String>[];
  final List<String> _transferTypeOptions = <String>[
    'Issue',
    'Receive',
  ];
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
  List<_SalesOrderOption> _salesOrderOptions = const <_SalesOrderOption>[];
  List<_ServiceCallOption> _serviceCallOptions = const <_ServiceCallOption>[];
  List<_EmployeeOption> _employeeOptions = const <_EmployeeOption>[];
  List<_OpportunityOption> _opportunityOptions =
      const <_OpportunityOption>[];
  List<_ConnectedTransferOption> _connectedTransferOptions =
      const <_ConnectedTransferOption>[];
  List<_ItemOption> _itemOptions = const <_ItemOption>[];
  List<_ProjectOption> _projectOptions = const <_ProjectOption>[];

  final List<_InventoryItemRow> _items = <_InventoryItemRow>[_InventoryItemRow()];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _documentDateController.text = _formatDate(now);
    _postingDateController.text = _formatDate(now);
    _status = 'Open';
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
        const SnackBar(
          content: Text('Unable to load business partner list'),
        ),
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
        final location = _readValue(row, <String>[
          'Location',
          'Loc',
          'Branch',
        ]);

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

        optionsByCode[employeeCode] = _EmployeeOption(
          code: employeeCode,
          label: label,
        );
      }

      if (!mounted) {
        return;
      }

      final sortedOptions = optionsByCode.values.toList()
        ..sort((a, b) => a.label.compareTo(b.label));
      setState(() {
        _employeeOptions = sortedOptions;
        if (_employeeCode != null &&
            !_employeeOptions.any((option) => option.code == _employeeCode)) {
          _employeeCode = null;
          _employeeCodeController.text = '';
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
        final transferType = _readValue(row, <String>[
          'TransferType',
          'Type',
        ]);

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
        for (final row in _items) {
          final selectedCode = row.itemCodeController.text.trim();
          final matched = _itemOptions.where(
            (option) => option.itemCode == selectedCode,
          );
          if (selectedCode.isNotEmpty && matched.isEmpty) {
            row.itemCodeController.text = '';
            row.descriptionController.text = '';
          }
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load item list')),
      );
    }
  }

  Future<void> _fetchProjects() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getInventoryProjectMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get inventory project failed (${response.statusCode})');
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
        for (final row in _items) {
          final selectedCode = row.projectController.text.trim();
          final matched = _projectOptions.where(
            (option) => option.projectCode == selectedCode,
          );
          if (selectedCode.isNotEmpty && matched.isEmpty) {
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
    if (mounted) setState(() {});
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

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inventory Transfer Request submitted')),
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
              onPressed: _onSubmit,
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _sectionCard(
                title: 'Transfer Details',
                child: Column(
                  children: [
                    _dropdownField(
                      label: 'Business Partner',
                      value: _businessPartner,
                      options: _businessPartnerOptions,
                      onChanged: (value) =>
                          setState(() => _businessPartner = value),
                    ),
                    _dropdownField(
                      label: 'Transfer Type',
                      value: _transferType,
                      options: _transferTypeOptions,
                      onChanged: (value) {
                        if (value == null) return;
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
              const SizedBox(height: 10),
              _sectionCard(
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
                      }),
                    ),
                    _textField(
                      label: 'Team',
                      controller: _teamController,
                    ),
                    _dropdownField(
                      label: 'Status',
                      value: _status,
                      options: _statusOptions,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _status = value);
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
              const SizedBox(height: 10),
              _sectionCard(
                title: 'Document Details',
                child: Column(
                  children: [
                    _textField(
                      label: 'Document No',
                      controller: _documentNoController,
                    ),
                    _dateField(
                      label: 'Posting Date',
                      controller: _postingDateController,
                    ),
                    _dateField(
                      label: 'Due Date',
                      controller: _dueDateController,
                    ),
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
              const SizedBox(height: 10),
              _sectionCard(
                title: 'Items',
                child: Column(
                  children: [
                    for (int i = 0; i < _items.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _itemRowCard(i),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: _addItemRow,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Row'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
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
              final selected = _itemOptions.where(
                (option) => option.itemCode == value,
              );
              final item = selected.isEmpty ? null : selected.first;
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
    required List<String> options,
    required ValueChanged<String?> onChanged,
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: options
            .map((option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ))
            .toList(),
        onChanged: onChanged,
        validator: requiredField
            ? (selected) =>
                (selected == null || selected.isEmpty) ? 'Please select $label' : null
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option.code,
                child: Text(option.label),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: requiredField
            ? (selected) => (selected == null || selected.isEmpty)
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

  Widget _salesOrderDropdownField({
    required String label,
    required String? value,
    required List<_SalesOrderOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option.soNo,
                child: Text(option.label),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _serviceCallDropdownField({
    required String label,
    required String? value,
    required List<_ServiceCallOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option.callId,
                child: Text(option.label),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _employeeDropdownField({
    required String label,
    required String? value,
    required List<_EmployeeOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option.code,
                child: Text(option.label),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _opportunityDropdownField({
    required String label,
    required String? value,
    required List<_OpportunityOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option.opportunityNo,
                child: Text(option.label),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _connectedTransferDropdownField({
    required String label,
    required String? value,
    required List<_ConnectedTransferOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option.transferNo,
                child: Text(option.label),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _itemDropdownField({
    required String label,
    required String? value,
    required List<_ItemOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option.itemCode,
                child: Text(option.itemCode),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _projectDropdownField({
    required String label,
    required String? value,
    required List<_ProjectOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option.projectCode,
                child: Text(option.label),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
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
          suffixIcon: const Icon(Icons.calendar_today_outlined),
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

class _WarehouseOption {
  const _WarehouseOption({
    required this.code,
    required this.label,
  });

  final String code;
  final String label;
}

class _SalesOrderOption {
  const _SalesOrderOption({
    required this.soNo,
    required this.label,
  });

  final String soNo;
  final String label;
}

class _ServiceCallOption {
  const _ServiceCallOption({
    required this.callId,
    required this.label,
  });

  final String callId;
  final String label;
}

class _EmployeeOption {
  const _EmployeeOption({
    required this.code,
    required this.label,
  });

  final String code;
  final String label;
}

class _OpportunityOption {
  const _OpportunityOption({
    required this.opportunityNo,
    required this.label,
  });

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
  const _ItemOption({
    required this.itemCode,
    required this.description,
  });

  final String itemCode;
  final String description;
}

class _ProjectOption {
  const _ProjectOption({
    required this.projectCode,
    required this.label,
  });

  final String projectCode;
  final String label;
}
