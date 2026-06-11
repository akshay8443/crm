import 'dart:convert';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/api_constants.dart';

class GoodsIssueRequestScreen extends StatefulWidget {
  const GoodsIssueRequestScreen({
    super.key,
    this.viewOnly = false,
    this.initialRows,
  });

  final bool viewOnly;
  final List<Map<String, dynamic>>? initialRows;

  @override
  State<GoodsIssueRequestScreen> createState() =>
      _GoodsIssueRequestScreenState();
}

class _GoodsIssueRequestScreenState extends State<GoodsIssueRequestScreen> {
  static const int _attachmentImageQuality = 70;
  static const double _attachmentMaxWidth = 1920;
  static const double _attachmentMaxHeight = 1920;
  static const String _noneOption = 'None';

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  final _numberController = TextEditingController(text: 'GI-000001');
  final _postingDateController = TextEditingController();
  final _teamController = TextEditingController();
  final _remarksController = TextEditingController();
  final _importantNoteController = TextEditingController();

  String? _employeeCode;
  String? _responsibleDepartment;
  String? _consumptionType;
  String? _serviceCallNo;
  String? _salesOrderNo;
  bool _isSubmitting = false;

  List<String> _teamOptions = const <String>[];
  List<String> _employeeOptions = const <String>[];
  final List<String> _departmentOptions = const <String>[
    'Engineering',
    'Support',
    'Supply Chain Mgmt',
    'R&D',
    'Accounts',
    'Pre Sales',
    'Production',
    'Support Production',
    'Sales',
    'Projects',
    'IT',
    'HR',
    'Audit',
    'Operation',
    'Admin',
  ];
  final List<String> _consumptionTypeOptions = const <String>[
    'Delivery Challan',
    'Consumption',
    'Issue To Employee',
  ];
  List<String> _serviceCallOptions = const <String>[];
  List<String> _salesOrderOptions = const <String>[];
  List<String> _itemOptions = const <String>[];
  List<String> _warehouseOptions = const <String>[];
  List<String> _binLocationOptions = const <String>[];
  List<String> _projectOptions = const <String>[];

  final List<XFile> _attachments = <XFile>[];
  final List<_GoodsIssueItemRow> _items = <_GoodsIssueItemRow>[
    _GoodsIssueItemRow(),
  ];

  bool get _isViewOnly => widget.viewOnly;

  @override
  void initState() {
    super.initState();
    _postingDateController.text = _formatDate(DateTime.now());
    if (_isViewOnly && widget.initialRows != null) {
      _applyInitialRows(widget.initialRows!);
    } else {
      _fetchNextGoodIssueNumber();
    }
    _fetchGoodsEmployees();
    _fetchGoodsItems();
    _fetchGoodsServiceCalls();
    _fetchGoodsSalesOrders();
    _fetchGoodsProjects();
    _fetchGoodsWarehouses();
    _fetchGoodsBinLocations();
  }

  @override
  void dispose() {
    _numberController.dispose();
    _postingDateController.dispose();
    _teamController.dispose();
    _remarksController.dispose();
    _importantNoteController.dispose();
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

  String _formatApiDateForDisplay(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return '';
    }
    final dateText = text
        .replaceFirst(RegExp(r'T.*$'), '')
        .replaceFirst(RegExp(r'\s+00:00:00$'), '')
        .replaceFirst(RegExp(r'\s+00$'), '');
    final parts = dateText.split('-');
    if (parts.length == 3) {
      return '${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}';
    }
    return dateText;
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

  String _cleanApiDate(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return '';
    }

    return text
        .replaceFirst(RegExp(r'\s+00:00:00$'), '')
        .replaceFirst(RegExp(r'\s+00$'), '');
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

  String _extractCode(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return '';
    }

    final separatorIndex = text.indexOf(' - ');
    if (separatorIndex <= 0) {
      return text;
    }

    return text.substring(0, separatorIndex).trim();
  }

  void _applyInitialRows(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) {
      return;
    }

    final first = rows.first;
    _numberController.text = _readValue(first, <String>[
      'DocNo',
      'GoodIssueNo',
      'GoodsIssueNo',
    ]);
    _postingDateController.text = _formatApiDateForDisplay(
      _readValue(first, <String>['PostingDate', 'DocDate']),
    );
    _employeeCode = _readValue(first, <String>['Employee', 'EmployeeCode']);
    _teamController.text = _employeeCode ?? '';
    _responsibleDepartment = _readValue(first, <String>['Dept', 'Department']);
    _consumptionType = _readValue(first, <String>[
      'ConsumptionType',
      'Type',
    ]);
    _serviceCallNo = _readValue(first, <String>['ServiceCallNo']);
    _salesOrderNo = _readValue(first, <String>['SalesOrderNo']);
    _remarksController.text = _readValue(first, <String>['Remarks']);
    _importantNoteController.text = _readValue(first, <String>[
      'ImportantNote',
    ]);

    for (final item in _items) {
      item.dispose();
    }
    _items
      ..clear()
      ..addAll(
        rows.map((row) {
          final item = _GoodsIssueItemRow();
          item.itemCodeController.text = _readValue(row, <String>['ItemCode']);
          item.descriptionController.text = _readValue(row, <String>[
            'ItemDesc',
            'ItemDescription',
          ]);
          item.quantityController.text = _readValue(row, <String>[
            'Qty',
            'Quantity',
          ]);
          item.warehouseController.text = _readValue(row, <String>[
            'Warehouse',
            'WhsCode',
          ]);
          item.binLocationController.text = _readValue(row, <String>[
            'Bin',
            'BinLocation',
          ]);
          item.projectController.text = _readValue(row, <String>[
            'Project',
            'ProjectCode',
          ]);
          return item;
        }),
      );
    if (_items.isEmpty) {
      _items.add(_GoodsIssueItemRow());
    }
  }

  Future<void> _fetchNextGoodIssueNumber() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getNextGoodIssueNumberPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get next good issue number failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from next good issue number API');
      }

      final dynamic decoded = jsonDecode(response.body);
      String number = '';

      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map<String, dynamic>) {
          number = _readValue(first, <String>[
            'GoodIsssueNo',
            'GoodIssueNo',
            'GoodsIssueNo',
            'DocNo',
            'DocNum',
            'Number',
          ]);
        } else if (first != null) {
          number = first.toString().trim();
        }
      } else if (decoded is Map<String, dynamic>) {
        number = _readValue(decoded, <String>[
          'GoodIsssueNo',
          'GoodIssueNo',
          'GoodsIssueNo',
          'DocNo',
          'DocNum',
          'Number',
          'data',
          'result',
          'value',
        ]);
      } else if (decoded is String || decoded is num) {
        number = decoded.toString().trim();
      }

      if (!mounted || number.isEmpty) {
        return;
      }

      setState(() {
        _numberController.text = number;
      });
    } catch (_) {
      // Keep fallback number if API fails.
    }
  }

  Future<void> _fetchGoodsEmployees() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getGoodsEmployeePath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get goods employee failed (${response.statusCode})');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from goods employee API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid goods employee response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid goods employee response format');
      }

      final labelsByCode = <String, String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final employeeCode = _readValue(row, <String>[
          'EmployeeCode',
          'EmpCode',
          'Code',
          'EmployeeNo',
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
        final label = fullNameParts.isEmpty
            ? employeeCode
            : '$employeeCode - ${fullNameParts.join(' ')}';

        labelsByCode[employeeCode] = label;
      }

      final options = labelsByCode.values.toList()
        ..sort((a, b) => a.compareTo(b));
      if (!mounted) {
        return;
      }

      setState(() {
        _employeeOptions = options;
        _teamOptions = options;
        if (_employeeCode != null &&
            !_employeeOptions.contains(_employeeCode)) {
          _employeeCode = null;
        }
        final selectedTeam = _teamController.text.trim();
        if (selectedTeam.isNotEmpty && !_teamOptions.contains(selectedTeam)) {
          _teamController.clear();
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load goods employee list')),
      );
    }
  }

  Future<void> _fetchGoodsItems() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getGoodsItemPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get goods item failed (${response.statusCode})');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from goods item API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid goods item response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid goods item response format');
      }

      final labelsByCode = <String, String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final itemCode = _readValue(row, <String>[
          'ItemCode',
          'ItemNo',
          'Code',
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

        labelsByCode[itemCode] = itemDescription.isEmpty
            ? itemCode
            : '$itemCode - $itemDescription';
      }

      final options = labelsByCode.values.toList()
        ..sort((a, b) => a.compareTo(b));
      if (!mounted) {
        return;
      }

      setState(() {
        _itemOptions = options;
        for (final row in _items) {
          final selectedItem = row.itemCodeController.text.trim();
          if (selectedItem.isNotEmpty && !_itemOptions.contains(selectedItem)) {
            row.itemCodeController.clear();
            row.descriptionController.clear();
          }
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load goods item list')),
      );
    }
  }

  Future<void> _fetchGoodsServiceCalls() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getGoodsServiceCallPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get goods service call failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from goods service call API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid goods service call response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid goods service call response format');
      }

      final labelsByCallId = <String, String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final callId = _readValue(row, <String>[
          'callID',
          'CallID',
          'CallId',
          'ServiceCallNo',
        ]);
        final bpName = _readValue(row, <String>[
          'BPNAME',
          'BPName',
          'BpName',
          'CustomerName',
        ]);

        if (callId.isEmpty) {
          continue;
        }

        labelsByCallId[callId] = bpName.isEmpty ? callId : '$callId - $bpName';
      }

      final options = labelsByCallId.values.toList()
        ..sort((a, b) => a.compareTo(b));
      if (!mounted) {
        return;
      }

      setState(() {
        _serviceCallOptions = options;
        if (_serviceCallNo != null &&
            !_serviceCallOptions.contains(_serviceCallNo)) {
          _serviceCallNo = null;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load goods service call list')),
      );
    }
  }

  Future<void> _fetchGoodsSalesOrders() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getGoodsSalesOrderPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get goods sales order failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from goods sales order API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid goods sales order response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid goods sales order response format');
      }

      final labelsBySoNo = <String, String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final soNo = _readValue(row, <String>[
          'SoNo',
          'SONo',
          'SalesOrderNo',
          'DocNum',
        ]);
        final customer = _readValue(row, <String>[
          'Customer',
          'CustomerName',
          'BPNAME',
          'BPName',
        ]);
        final soDate = _cleanApiDate(
          _readValue(row, <String>['SODate', 'SoDate', 'DocDate']),
        );

        if (soNo.isEmpty) {
          continue;
        }

        final labelParts = <String>[
          soNo,
          if (customer.isNotEmpty) customer,
          if (soDate.isNotEmpty) soDate,
        ];
        labelsBySoNo[soNo] = labelParts.join(' - ');
      }

      final options = labelsBySoNo.values.toList()
        ..sort((a, b) => a.compareTo(b));
      if (!mounted) {
        return;
      }

      setState(() {
        _salesOrderOptions = options;
        if (_salesOrderNo != null &&
            !_salesOrderOptions.contains(_salesOrderNo)) {
          _salesOrderNo = null;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load goods sales order list')),
      );
    }
  }

  Future<void> _fetchGoodsProjects() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getGoodsProjectMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get goods project failed (${response.statusCode})');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from goods project API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid goods project response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid goods project response format');
      }

      final labelsByCode = <String, String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final projectCode = _readValue(row, <String>[
          'Projectcode',
          'ProjectCode',
          'PrjCode',
          'ProjectNo',
          'Code',
        ]);
        final projectName = _readValue(row, <String>[
          'ProjectName',
          'PrjName',
          'Name',
          'Description',
          'ProjectDesc',
        ]);

        if (projectCode.isEmpty) {
          continue;
        }

        labelsByCode[projectCode] = projectName.isEmpty
            ? projectCode
            : '$projectCode - $projectName';
      }

      final options = labelsByCode.values.toList()
        ..sort((a, b) => a.compareTo(b));
      if (!mounted) {
        return;
      }

      setState(() {
        _projectOptions = options;
        for (final row in _items) {
          final selectedProject = row.projectController.text.trim();
          if (selectedProject.isNotEmpty &&
              !_projectOptions.contains(selectedProject)) {
            row.projectController.clear();
          }
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load goods project list')),
      );
    }
  }

  Future<void> _fetchGoodsWarehouses() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getGoodsWarehouseMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get goods warehouse failed (${response.statusCode})');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from goods warehouse API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid goods warehouse response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid goods warehouse response format');
      }

      final labelsByCode = <String, String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final warehouseCode = _readValue(row, <String>[
          'WarehouseCode',
          'WhsCode',
          'Code',
        ]);
        final warehouseName = _readValue(row, <String>[
          'warehouseName',
          'WarehouseName',
          'WhsName',
          'Name',
        ]);
        final location = _readValue(row, <String>['Location', 'location']);

        if (warehouseCode.isEmpty) {
          continue;
        }

        final labelParts = <String>[
          warehouseCode,
          if (warehouseName.isNotEmpty) warehouseName,
          if (location.isNotEmpty) location,
        ];
        labelsByCode[warehouseCode] = labelParts.join(' - ');
      }

      final options = labelsByCode.values.toList()
        ..sort((a, b) => a.compareTo(b));
      if (!mounted) {
        return;
      }

      setState(() {
        _warehouseOptions = options;
        for (final row in _items) {
          final selectedWarehouse = row.warehouseController.text.trim();
          if (selectedWarehouse.isNotEmpty &&
              !_warehouseOptions.contains(selectedWarehouse)) {
            row.warehouseController.clear();
          }
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load goods warehouse list')),
      );
    }
  }

  Future<void> _fetchGoodsBinLocations() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getGoodsBinLocationPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get goods bin location failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from goods bin location API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid goods bin location response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid goods bin location response format');
      }

      final labelsByLocation = <String, String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final binLocation = _readValue(row, <String>[
          'BinLocation',
          'BinCode',
          'Code',
        ]);
        final description = _readValue(row, <String>[
          'Description',
          'BinDescription',
          'Name',
        ]);

        if (binLocation.isEmpty) {
          continue;
        }

        labelsByLocation[binLocation] = description.isEmpty
            ? binLocation
            : '$binLocation - $description';
      }

      final options = labelsByLocation.values.toList()
        ..sort((a, b) => a.compareTo(b));
      if (!mounted) {
        return;
      }

      setState(() {
        _binLocationOptions = options;
        for (final row in _items) {
          final selectedBinLocation = row.binLocationController.text.trim();
          if (selectedBinLocation.isNotEmpty &&
              !_binLocationOptions.contains(selectedBinLocation)) {
            row.binLocationController.clear();
          }
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load goods bin location list')),
      );
    }
  }

  Future<void> _pickPostingDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() => _postingDateController.text = _formatDate(picked));
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final linePayload = _items
        .map(
          (row) => <String, dynamic>{
            'ItemCode': _extractCode(row.itemCodeController.text),
            'ItemDesc': row.descriptionController.text.trim(),
            'Qty': double.tryParse(row.quantityController.text.trim()) ?? 0,
            'Warehouse': _extractCode(row.warehouseController.text),
            'Bin': _extractCode(row.binLocationController.text),
            'Project': _extractCode(row.projectController.text),
          },
        )
        .toList(growable: false);

    final payload = <String, dynamic>{
      'DocNo': _numberController.text.trim(),
      'DocDate': _toApiDate(_postingDateController.text),
      'PostingDate': _toApiDate(_postingDateController.text),
      'Employee': _extractCode(_employeeCode ?? ''),
      'Dept': _responsibleDepartment ?? '',
      'ConsumptionType': _consumptionType ?? '',
      'ServiceCallNo': _extractCode(_serviceCallNo ?? ''),
      'SalesOrderNo': _extractCode(_salesOrderNo ?? ''),
      'Remarks': _remarksController.text.trim(),
      'ImportantNote': _importantNoteController.text.trim(),
      'Lines': linePayload,
    };

    setState(() => _isSubmitting = true);
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.createGoodIssuePath}',
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
        throw Exception('Create good issue failed (${response.statusCode})');
      }

      String message = 'Good Issue Created Successfully';
      final body = response.body.trim();
      if (body.isNotEmpty) {
        final dynamic decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          final serverMessage = decoded['message']?.toString().trim();
          if (serverMessage != null && serverMessage.isNotEmpty) {
            message = serverMessage;
          }

          final serverDocNo = _readValue(decoded, <String>[
            'DocNo',
            'DocumentNo',
            'GoodIsssueNo',
            'GoodIssueNo',
            'GoodsIssueNo',
          ]);
          if (serverDocNo.isNotEmpty) {
            _numberController.text = serverDocNo;
          }
        }
      }

      final docNo = _numberController.text.trim();
      await _uploadGoodIssueAttachments(docNo);
      if (_attachments.isNotEmpty) {
        message = '$message\nAttachments uploaded: ${_attachments.length}';
      }

      if (!mounted) {
        return;
      }
      await _showSubmitSuccessDialog(message);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar('Unable to submit good issue. $error');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _uploadGoodIssueAttachments(String docNo) async {
    final normalizedDocNo = docNo.trim();
    if (_attachments.isEmpty || normalizedDocNo.isEmpty) {
      return;
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.uploadGoodIssueFilePath}',
    );
    final preparedFiles = <Map<String, dynamic>>[];
    for (final file in _attachments) {
      final fileName = _resolvedAttachmentFileName(file);
      final fileLength = await file.length();
      if (fileLength <= 0) {
        throw Exception('Attachment is empty: $fileName');
      }
      preparedFiles.add(<String, dynamic>{
        'name': fileName,
        'file': file,
        'length': fileLength,
      });
    }

    Future<http.StreamedResponse> sendWithFieldName(String fieldName) async {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(<String, String>{
          'Authorization': ApiConstants.basicAuthorization,
          'Accept': 'application/json',
        })
        ..fields['DocNo'] = normalizedDocNo;

      for (final item in preparedFiles) {
        final file = item['file'] as XFile;
        request.files.add(
          http.MultipartFile(
            fieldName,
            file.openRead(),
            item['length'] as int,
            filename: item['name'] as String,
          ),
        );
      }

      return request.send().timeout(const Duration(seconds: 180));
    }

    final fieldNames = <String>['', 'file', 'files', 'File', 'Image'];
    int? lastStatusCode;
    String lastResponseBody = '';
    Object? lastError;

    for (final fieldName in fieldNames) {
      try {
        final streamedResponse = await sendWithFieldName(fieldName);
        final responseBody = await streamedResponse.stream.bytesToString();
        lastStatusCode = streamedResponse.statusCode;
        lastResponseBody = responseBody;

        if (streamedResponse.statusCode >= 200 &&
            streamedResponse.statusCode < 300) {
          return;
        }
      } catch (error) {
        lastError = error;
      }
    }

    if (lastResponseBody.trim().isNotEmpty) {
      throw Exception(lastResponseBody.trim());
    }
    if (lastError != null) {
      throw Exception(lastError.toString());
    }
    throw Exception(
      'Attachment upload failed (${lastStatusCode ?? 'unknown'})',
    );
  }

  String _resolvedAttachmentFileName(XFile file) {
    final directName = file.name.trim();
    final path = file.path.trim();
    final normalizedPath = path.replaceAll('\\', '/');
    final pathName = normalizedPath.isEmpty
        ? ''
        : normalizedPath.split('/').last.trim();
    final candidate = directName.isNotEmpty ? directName : pathName;
    if (candidate.isEmpty) {
      return 'attachment.jpg';
    }
    final hasExtension = RegExp(r'\.[A-Za-z0-9]{2,5}$').hasMatch(candidate);
    return hasExtension ? candidate : '$candidate.jpg';
  }

  Future<void> _showSubmitSuccessDialog(String message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.maybePop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _addItemRow() {
    if (_isViewOnly) return;
    setState(() => _items.add(_GoodsIssueItemRow()));
  }

  void _removeItemRow(int index) {
    if (_isViewOnly) return;
    if (_items.length <= 1) return;
    final row = _items.removeAt(index);
    row.dispose();
    setState(() {});
  }

  Future<void> _openUploadOptions() async {
    if (_isViewOnly) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickFromCamera();
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose From Gallery'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    try {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux)) {
        _showSnackBar('Camera is not supported on this platform');
        return;
      }
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: _attachmentImageQuality,
        maxWidth: _attachmentMaxWidth,
        maxHeight: _attachmentMaxHeight,
      );
      if (!mounted || photo == null) return;
      setState(() => _attachments.add(photo));
    } on MissingPluginException {
      _showSnackBar('Image picker plugin not loaded');
    } on PlatformException catch (error) {
      _showSnackBar('Unable to open camera (${error.code})');
    } catch (error) {
      _showSnackBar('Unable to open camera. $error');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final files = await _imagePicker.pickMultiImage(
        imageQuality: _attachmentImageQuality,
        maxWidth: _attachmentMaxWidth,
        maxHeight: _attachmentMaxHeight,
      );
      if (!mounted || files.isEmpty) return;
      setState(() => _attachments.addAll(files));
    } on MissingPluginException {
      _showSnackBar('Image picker plugin not loaded');
    } on PlatformException catch (error) {
      _showSnackBar('Unable to open gallery (${error.code})');
    } catch (error) {
      _showSnackBar('Unable to open gallery. $error');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> _showOptionPicker({
    required String title,
    required List<String> options,
  }) async {
    var query = '';
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = options
                .where((option) {
                  return option.toLowerCase().contains(query.toLowerCase());
                })
                .toList(growable: false);

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.72,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (value) =>
                            setSheetState(() => query = value),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(child: Text('No options found'))
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final option = filtered[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(option),
                                    onTap: () => Navigator.pop(context, option),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<String> _withNoneOption(List<String> options) {
    return <String>[_noneOption, ...options];
  }

  String? _normalizeSelectedOption(String? value) {
    if (value == null || value == _noneOption || value.trim().isEmpty) {
      return null;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(
        title: Text(_isViewOnly ? 'Goods Issue Details' : 'Goods Issue Request'),
        actions: [
          TextButton(
            onPressed: () => Navigator.maybePop(context),
            child: Text(
              _isViewOnly ? 'Back' : 'Cancel',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          if (!_isViewOnly)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                onPressed: _isSubmitting ? null : _onSubmit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save & Submit'),
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
              _buildGeneralDetailsCard(),
              const SizedBox(height: 12),
              _buildServiceDetailsCard(),
              const SizedBox(height: 12),
              _buildAttachmentsCard(),
              const SizedBox(height: 12),
              _buildItemsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralDetailsCard() {
    return _sectionCard(
      title: 'General Details',
      child: Column(
        children: [
          _textField(
            label: 'Number',
            controller: _numberController,
            readOnly: true,
          ),
          _dateField(),
          _stringPickerField(
            label: 'Team',
            value: _teamController.text.trim().isEmpty
                ? null
                : _teamController.text.trim(),
            options: _teamOptions,
            onChanged: (value) => setState(() {
              _teamController.text = value ?? '';
            }),
            enabled: !_isViewOnly,
          ),
          _stringPickerField(
            label: 'Employee Code',
            value: _employeeCode,
            options: _employeeOptions,
            onChanged: (value) => setState(() => _employeeCode = value),
            requiredField: true,
            enabled: !_isViewOnly,
          ),
          _stringPickerField(
            label: 'Responsible Department',
            value: _responsibleDepartment,
            options: _departmentOptions,
            onChanged: (value) {
              setState(() => _responsibleDepartment = value);
            },
            requiredField: true,
            enabled: !_isViewOnly,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard() {
    return _sectionCard(
      title: 'Service Details',
      child: Column(
        children: [
          _stringPickerField(
            label: 'Consumption Type',
            value: _consumptionType,
            options: _consumptionTypeOptions,
            onChanged: (value) => setState(() => _consumptionType = value),
            requiredField: true,
            enabled: !_isViewOnly,
          ),
          _stringPickerField(
            label: 'Service Call No',
            value: _serviceCallNo,
            options: _serviceCallOptions,
            onChanged: (value) => setState(() => _serviceCallNo = value),
            enabled: !_isViewOnly,
          ),
          _stringPickerField(
            label: 'Sales Order No',
            value: _salesOrderNo,
            options: _salesOrderOptions,
            onChanged: (value) => setState(() => _salesOrderNo = value),
            enabled: !_isViewOnly,
          ),
          _textField(
            label: 'Remarks',
            controller: _remarksController,
            maxLines: 3,
            readOnly: _isViewOnly,
          ),
          _textField(
            label: 'Important Note',
            controller: _importantNoteController,
            maxLines: 3,
            readOnly: _isViewOnly,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsCard() {
    return _sectionCard(
      title: 'Attachments',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isViewOnly)
            OutlinedButton.icon(
              onPressed: _openUploadOptions,
              icon: const Icon(Icons.attach_file),
              label: const Text('Choose Files'),
            ),
          if (_isViewOnly && _attachments.isEmpty)
            const Text('No attachments available'),
          if (_attachments.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${_attachments.length} file(s) selected',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 86,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _attachments.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final file = _attachments[index];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 86,
                          height: 86,
                          child: _xFileImage(
                            file,
                            fit: BoxFit.cover,
                            cacheWidth: 172,
                            cacheHeight: 172,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: _isViewOnly
                              ? null
                              : () =>
                                    setState(() => _attachments.removeAt(index)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return _sectionCard(
      title: 'Items',
      trailing: _isViewOnly
          ? null
          : IconButton(
              onPressed: _addItemRow,
              icon: const Icon(Icons.add),
              tooltip: 'Add row',
            ),
      child: Column(
        children: [
          for (var index = 0; index < _items.length; index++) ...[
            _itemRowCard(index),
            if (index != _items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _itemRowCard(int index) {
    final row = _items[index];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDE2EA)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '#${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (!_isViewOnly && _items.length > 1)
                IconButton(
                  onPressed: () => _removeItemRow(index),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove row',
                ),
            ],
          ),
          _itemPickerField(row),
          _textField(
            label: 'Description',
            controller: row.descriptionController,
            maxLines: 2,
            readOnly: true,
          ),
          _textField(
            label: 'Quantity',
            controller: row.quantityController,
            keyboardType: TextInputType.number,
            requiredField: true,
            readOnly: _isViewOnly,
          ),
          _stringPickerField(
            label: 'Warehouse',
            value: row.warehouseController.text.trim().isEmpty
                ? null
                : row.warehouseController.text.trim(),
            options: _warehouseOptions,
            onChanged: (value) => setState(() {
              row.warehouseController.text = value ?? '';
            }),
            requiredField: true,
            enabled: !_isViewOnly,
          ),
          _stringPickerField(
            label: 'Bin Location',
            value: row.binLocationController.text.trim().isEmpty
                ? null
                : row.binLocationController.text.trim(),
            options: _binLocationOptions,
            onChanged: (value) => setState(() {
              row.binLocationController.text = value ?? '';
            }),
            enabled: !_isViewOnly,
          ),
          _stringPickerField(
            label: 'Project',
            value: row.projectController.text.trim().isEmpty
                ? null
                : row.projectController.text.trim(),
            options: _projectOptions,
            onChanged: (value) => setState(() {
              row.projectController.text = value ?? '';
            }),
            enabled: !_isViewOnly,
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDE2EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
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
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        enabled: !(_isViewOnly && !readOnly),
        validator: requiredField
            ? (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter $label'
                  : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          filled: true,
          fillColor: readOnly ? const Color(0xFFF6F7F9) : Colors.white,
        ),
      ),
    );
  }

  Widget _dateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: _postingDateController,
        readOnly: true,
        onTap: _isViewOnly ? null : _pickPostingDate,
        decoration: const InputDecoration(
          labelText: 'Posting Date',
          border: OutlineInputBorder(),
          isDense: true,
          suffixIcon: Icon(Icons.calendar_today_outlined),
        ),
      ),
    );
  }

  Widget _stringPickerField({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    bool requiredField = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FormField<String>(
        initialValue: value,
        validator: requiredField
            ? (_) => (value == null || value.trim().isEmpty)
                  ? 'Please select $label'
                  : null
            : null,
        builder: (field) {
          final text = value?.trim() ?? '';
          return InkWell(
            onTap: enabled
                ? () async {
              final selected = await _showOptionPicker(
                title: label,
                options: _withNoneOption(options),
              );
              if (selected != null) {
                onChanged(_normalizeSelectedOption(selected));
                field.didChange(_normalizeSelectedOption(selected));
              }
            }
                : null,
            child: InputDecorator(
              isEmpty: text.isEmpty,
              decoration: InputDecoration(
                labelText: label,
                hintText: 'Select $label',
                border: const OutlineInputBorder(),
                isDense: true,
                errorText: field.errorText,
                suffixIcon: enabled ? const Icon(Icons.arrow_drop_down) : null,
                filled: true,
                fillColor: enabled ? Colors.white : const Color(0xFFF6F7F9),
              ),
              child: Text(
                text.isEmpty ? ' ' : text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _itemPickerField(_GoodsIssueItemRow row) {
    final value = row.itemCodeController.text.trim();
    return _stringPickerField(
      label: 'Item Code',
      value: value.isEmpty ? null : value,
      options: _itemOptions,
      onChanged: (selected) {
        setState(() {
          row.itemCodeController.text = selected ?? '';
          row.descriptionController.text = selected == null
              ? ''
              : selected.split(' - ').skip(1).join(' - ');
        });
      },
      requiredField: true,
      enabled: !_isViewOnly,
    );
  }

  Widget _xFileImage(
    XFile file, {
    required BoxFit fit,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return const Center(child: Icon(Icons.image_not_supported_outlined));
        }
        return Image.memory(
          bytes,
          fit: fit,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
        );
      },
    );
  }
}

class _GoodsIssueItemRow {
  final itemCodeController = TextEditingController();
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController();
  final warehouseController = TextEditingController();
  final binLocationController = TextEditingController();
  final projectController = TextEditingController();

  void dispose() {
    itemCodeController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    warehouseController.dispose();
    binLocationController.dispose();
    projectController.dispose();
  }
}
