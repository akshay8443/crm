import 'dart:convert';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/session/user_session.dart';
import 'purchase_request_static_data.dart';

class PurchaseRequestScreen extends StatefulWidget {
  const PurchaseRequestScreen({
    super.key,
    this.initialDocNo,
    this.initialHeaderData,
  });

  final String? initialDocNo;
  final PurchaseRequestHeaderData? initialHeaderData;

  @override
  State<PurchaseRequestScreen> createState() => _PurchaseRequestScreenState();
}

class _PurchaseRequestScreenState extends State<PurchaseRequestScreen> {
  static const int _attachmentImageQuality = 70;
  static const double _attachmentMaxWidth = 1920;
  static const double _attachmentMaxHeight = 1920;
  static const String _noneOption = 'None';

  final ImagePicker _imagePicker = ImagePicker();
  final List<_PurchaseItem> items = [_PurchaseItem()];
  final List<XFile> _attachments = [];

  final _requesterNameController = TextEditingController(text: 'Manu');
  final _ownerNameController = TextEditingController();
  final _reqDepartmentController = TextEditingController();
  final _reqToController = TextEditingController();

  final _docNoController = TextEditingController(text: 'PR-000028');
  final _docDateController = TextEditingController();
  final _requiredDateController = TextEditingController();
  final _validUntilController = TextEditingController();
  final _amendmentDateController = TextEditingController();
  final _remarksController = TextEditingController();
  final _importantNoteController = TextEditingController();
  final _explanationController = TextEditingController();
  final _shipToController = TextEditingController();
  final _serviceCallController = TextEditingController();
  final _salesOrderController = TextEditingController();

  String? _requirementType;
  String? _responsibleDepartment;
  String? _natureOfProcurement;
  String? _privateClient;
  String? _priority;
  String? _requesterName;
  String? _ownerName;
  String? _requisitionToDepartment;
  String? _requisitionTo;
  List<String> _purchaseEmployeeOptions = const [];
  List<_CodeNameOption> _purchaseItemOptions = const [];
  List<_CodeNameOption> _warehouseOptions = const [];
  List<_CodeNameOption> _projectOptions = const [];
  List<_SalesOrderOption> _salesOrderOptions = const [];
  List<_ServiceCallOption> _serviceCallOptions = const [];
  bool _isSubmitting = false;
  bool _isLoadingExistingRequest = false;

  bool get _isViewDetailsMode {
    final initialDocNo = widget.initialDocNo?.trim() ?? '';
    return initialDocNo.isNotEmpty;
  }

  List<String> _withNoneOption(List<String> options) {
    final normalized = options
        .where((option) => option.trim().isNotEmpty)
        .where(
          (option) => option.trim().toLowerCase() != _noneOption.toLowerCase(),
        )
        .toList(growable: false);
    return <String>[_noneOption, ...normalized];
  }

  bool _isNoneOrEmpty(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ||
        normalized.toLowerCase() == _noneOption.toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _docDateController.text =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final initialDocNo = widget.initialDocNo?.trim() ?? '';
    if (initialDocNo.isNotEmpty) {
      _docNoController.text = initialDocNo;
      _fetchPurchaseRequestDetails(initialDocNo);
    } else {
      _fetchNextPurchaseRequestNo();
    }
    _applyInitialHeaderData(widget.initialHeaderData);
    _fetchPurchaseEmployees();
    _fetchPurchaseItems();
    _fetchPurchaseWarehouses();
    _fetchPurchaseProjects();
    _fetchPurchaseSalesOrders();
    _fetchPurchaseServiceCalls();
  }

  @override
  void dispose() {
    for (final item in items) {
      item.dispose();
    }
    _requesterNameController.dispose();
    _ownerNameController.dispose();
    _reqDepartmentController.dispose();
    _reqToController.dispose();
    _docNoController.dispose();
    _docDateController.dispose();
    _requiredDateController.dispose();
    _validUntilController.dispose();
    _amendmentDateController.dispose();
    _remarksController.dispose();
    _importantNoteController.dispose();
    _explanationController.dispose();
    _shipToController.dispose();
    _serviceCallController.dispose();
    _salesOrderController.dispose();
    super.dispose();
  }

  Uri _buildNoCacheUri(String path) {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final params = Map<String, String>.from(uri.queryParameters);
    params['_ts'] = DateTime.now().millisecondsSinceEpoch.toString();
    return uri.replace(queryParameters: params);
  }

  Uri _buildNoCacheUriWithQuery(String path, Map<String, String> query) {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final params = <String, String>{
      ...uri.queryParameters,
      ...query,
      '_ts': DateTime.now().millisecondsSinceEpoch.toString(),
    };
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

  Future<void> _fetchNextPurchaseRequestNo() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getNextPurchaseRequestPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get next purchase request no failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from next purchase request no API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final String docNo;
      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is! Map<String, dynamic>) {
          throw Exception('Invalid next purchase request no response format');
        }
        docNo = _readValue(first, <String>[
          'PurchaserequestNo',
          'PurchaseRequestNo',
          'DocNo',
        ]);
      } else if (decoded is Map<String, dynamic>) {
        docNo = _readValue(decoded, <String>[
          'PurchaserequestNo',
          'PurchaseRequestNo',
          'DocNo',
        ]);
      } else {
        throw Exception('Invalid next purchase request no response format');
      }

      if (docNo.isEmpty || !mounted) return;
      setState(() {
        _docNoController.text = docNo;
      });
    } catch (_) {
      // Keep existing doc no fallback if API fails.
    }
  }

  Future<void> _fetchPurchaseEmployees() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getPurchaseEmployeePath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get purchase employee failed (${response.statusCode})',
        );
      }

      if (response.body.isEmpty) {
        throw Exception('Empty response from purchase employee API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid purchase employee response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid purchase employee response format');
      }

      final options = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }
        final employeeCode = _readValue(row, <String>[
          'EmployeeCode',
          'EmpCode',
          'Code',
          'EmployeeId',
          'EmployeeNo',
          'EmpNo',
        ]);
        final firstName = _readValue(row, <String>['FirstName', 'firstName']);
        final middleName = _readValue(row, <String>[
          'MiddleName',
          'middleName',
        ]);
        final lastName = _readValue(row, <String>['LastName', 'lastName']);

        final fullName = [
          firstName,
          middleName,
          lastName,
        ].where((part) => part.isNotEmpty).join(' ');
        final label = employeeCode.isNotEmpty
            ? '$employeeCode - $fullName'
            : fullName;
        if (label.trim().isNotEmpty) {
          options.add(label.trim());
        }
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _purchaseEmployeeOptions = options.toList();
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

  Future<void> _fetchPurchaseItems() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getPurchaseItemPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get purchase item failed (${response.statusCode})');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from purchase item API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid purchase item response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid purchase item response format');
      }

      final options = <_CodeNameOption>[];
      final unique = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }
        final code = _readValue(row, <String>[
          'ItemCode',
          'ItemNo',
          'ItemID',
          'ItemId',
        ]);
        final description = _readValue(row, <String>[
          'ItemDescription',
          'Description',
          'ItemName',
          'Name',
          'ItemDesc',
        ]);
        final key = '${code.toLowerCase()}|${description.toLowerCase()}';
        if (code.isEmpty || unique.contains(key)) {
          continue;
        }
        unique.add(key);
        options.add(_CodeNameOption(code: code, name: description));
      }

      if (!mounted) return;
      setState(() {
        _purchaseItemOptions = options;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load purchase item list')),
      );
    }
  }

  Future<void> _fetchPurchaseWarehouses() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getPurchaseWarehousePath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get purchase warehouse failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from purchase warehouse API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid purchase warehouse response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid purchase warehouse response format');
      }

      final options = <_CodeNameOption>[];
      final unique = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }
        final code = _readValue(row, <String>[
          'WarehouseCode',
          'WhsCode',
          'Code',
          'Warehouse',
        ]);
        final name = _readValue(row, <String>[
          'WarehouseName',
          'WhsName',
          'Name',
          'Description',
        ]);
        final key = '${code.toLowerCase()}|${name.toLowerCase()}';
        if (code.isEmpty || unique.contains(key)) {
          continue;
        }
        unique.add(key);
        options.add(_CodeNameOption(code: code, name: name));
      }

      if (!mounted) return;
      setState(() {
        _warehouseOptions = options;
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

  Future<void> _fetchPurchaseProjects() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getPurchaseProjectPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get purchase project failed (${response.statusCode})');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from purchase project API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid purchase project response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid purchase project response format');
      }

      final options = <_CodeNameOption>[];
      final unique = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }
        final code = _readValue(row, <String>[
          'Projectcode',
          'ProjectCode',
          'Code',
          'ProjectNo',
        ]);
        final name = _readValue(row, <String>[
          'ProjectName',
          'Name',
          'Description',
          'ProjectDesc',
        ]);
        final key = '${code.toLowerCase()}|${name.toLowerCase()}';
        if (code.isEmpty || unique.contains(key)) {
          continue;
        }
        unique.add(key);
        options.add(_CodeNameOption(code: code, name: name));
      }

      if (!mounted) return;
      setState(() {
        _projectOptions = options;
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

  Future<void> _fetchPurchaseSalesOrders() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getPurchaseSalesOrderNoPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get purchase sales order failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from purchase sales order API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid purchase sales order response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid purchase sales order response format');
      }

      final options = <_SalesOrderOption>[];
      final unique = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) continue;
        final soNo = _readValue(row, <String>['SONo', 'SoNo', 'SO', 'OrderNo']);
        final customer = _readValue(row, <String>[
          'Customer',
          'CardName',
          'CustomerName',
          'Name',
        ]);
        final projectCode = _readValue(row, <String>[
          'ProjectCode',
          'Projectcode',
          'PrjCode',
          'Project',
          'ProjectNo',
        ]);
        final soDate = _readValue(row, <String>[
          'SODate',
          'SoDate',
          'DocDate',
          'Date',
        ]);
        final formattedSoDate = _formatDisplayDate(soDate);

        if (soNo.isEmpty) continue;
        final key =
            '${soNo.toLowerCase()}|${customer.toLowerCase()}|${formattedSoDate.toLowerCase()}';
        if (unique.contains(key)) continue;
        unique.add(key);
        options.add(
          _SalesOrderOption(
            soNo: soNo,
            customer: customer,
            soDate: formattedSoDate,
            projectCode: projectCode,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _salesOrderOptions = options;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load sales order list')),
      );
    }
  }

  Future<void> _fetchPurchaseServiceCalls() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getPurchaseServiceCallNoPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get purchase service call no failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from purchase service call no API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid purchase service call response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid purchase service call response format');
      }

      final options = <_ServiceCallOption>[];
      final unique = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) continue;
        final serviceCallNo = _readValue(row, <String>[
          'ServicecallNo',
          'ServiceCallNo',
          'serviceCallNo',
          'ServiceNo',
        ]);
        final businessPartner = _readValue(row, <String>[
          'BusinessPartner',
          'BUsinessPartner',
          'businessPartner',
          'BPName',
          'Customer',
          'CardName',
        ]);
        final serviceCallDate = _formatDisplayDate(
          _readValue(row, <String>[
            'ServiceCallDate',
            'CallDate',
            'CreatedDate',
            'DocDate',
            'Date',
          ]),
        );
        final projectCode = _readValue(row, <String>[
          'ProjectCode',
          'Projectcode',
          'PrjCode',
          'Project',
          'ProjectNo',
        ]);
        if (serviceCallNo.isEmpty) continue;
        final key =
            '${serviceCallNo.toLowerCase()}|${businessPartner.toLowerCase()}|${serviceCallDate.toLowerCase()}';
        if (unique.contains(key)) continue;
        unique.add(key);
        options.add(
          _ServiceCallOption(
            serviceCallNo: serviceCallNo,
            businessPartner: businessPartner,
            serviceCallDate: serviceCallDate,
            projectCode: projectCode,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _serviceCallOptions = options;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load service call list')),
      );
    }
  }

  Future<void> _fetchPurchaseRequestDetails(String docNo) async {
    final normalizedDocNo = docNo.trim();
    if (normalizedDocNo.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingExistingRequest = true;
    });

    try {
      final uri = _buildNoCacheUriWithQuery(
        ApiConstants.getSpecificPurchaseRequestPath,
        <String, String>{'DocNo': normalizedDocNo},
      );
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 25));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get specific purchase request failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from purchase request details API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid purchase request detail response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid purchase request detail response format');
      }

      final detailRows = rows.whereType<Map<String, dynamic>>().toList();
      if (detailRows.isEmpty) {
        throw Exception('Purchase request detail not found');
      }
      final normalizedRows = _normalizedPurchaseRequestDetailRows(detailRows);

      if (!mounted) return;
      setState(() {
        _applyPurchaseRequestDetails(normalizedRows);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load purchase request details'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingExistingRequest = false;
        });
      }
    }
  }

  Future<void> _openItemPicker(_PurchaseItem item) async {
    if (_purchaseItemOptions.isEmpty) {
      await _fetchPurchaseItems();
    }
    if (!mounted) return;
    final selected = await _openCodeNamePicker(
      options: _purchaseItemOptions,
      searchHint: 'Search ItemCode / Description',
      emptyText: 'No item found',
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      item.itemCode = selected.code;
      item.itemCodeController.text = selected.code;
      item.descriptionController.text = selected.name;
    });
  }

  Future<void> _openWarehousePicker(_PurchaseItem item) async {
    if (_warehouseOptions.isEmpty) {
      await _fetchPurchaseWarehouses();
    }
    if (!mounted) return;

    final selected = await _openCodeNamePicker(
      options: _warehouseOptions,
      searchHint: 'Search WarehouseCode / Name',
      emptyText: 'No warehouse found',
    );
    if (!mounted || selected == null) return;

    setState(() {
      item.warehouse = selected.code;
      item.warehouseCodeController.text = selected.code;
    });
  }

  Future<void> _openProjectPicker(_PurchaseItem item) async {
    if (_projectOptions.isEmpty) {
      await _fetchPurchaseProjects();
    }
    if (!mounted) return;

    final selected = await _openCodeNamePicker(
      options: _projectOptions,
      searchHint: 'Search ProjectCode / Name',
      emptyText: 'No project found',
    );
    if (!mounted || selected == null) return;

    setState(() {
      item.projectCode = selected.code;
      item.projectCodeController.text = selected.code;
    });
  }

  Future<void> _openSalesOrderPicker() async {
    if (_salesOrderOptions.isEmpty) {
      await _fetchPurchaseSalesOrders();
    }
    if (!mounted) return;

    final options = <_SalesOrderOption>[
      const _SalesOrderOption(
        soNo: _noneOption,
        customer: '',
        soDate: '',
        projectCode: '',
      ),
      ..._salesOrderOptions,
    ];

    final selected = await showModalBottomSheet<_SalesOrderOption>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        var query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = options.where((option) {
              final q = query.trim().toLowerCase();
              if (q.isEmpty) return true;
              return option.soNo.toLowerCase().contains(q) ||
                  option.customer.toLowerCase().contains(q) ||
                  option.soDate.toLowerCase().contains(q) ||
                  option.displayLabel.toLowerCase().contains(q);
            }).toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 12,
                ),
                child: SizedBox(
                  height: 420,
                  child: Column(
                    children: [
                      TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search SONo / Customer / SODate',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFFFBFBFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD7DCE4),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            query = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(child: Text('No sales order found'))
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final option = filtered[index];
                                  final isNoneOption =
                                      option.soNo.trim().toLowerCase() ==
                                      _noneOption.toLowerCase();
                                  return ListTile(
                                    dense: true,
                                    title: Text(option.soNo),
                                    subtitle: isNoneOption
                                        ? null
                                        : Text(
                                            [
                                              if (option.customer.isNotEmpty)
                                                option.customer,
                                              if (option.soDate.isNotEmpty)
                                                'Date: ${option.soDate}',
                                            ].join(' • '),
                                          ),
                                    onTap: () =>
                                        Navigator.pop(sheetContext, option),
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

    if (!mounted || selected == null) return;
    setState(() {
      _salesOrderController.text = _isNoneOrEmpty(selected.soNo)
          ? ''
          : selected.displayLabel;
    });
  }

  Future<void> _openServiceCallPicker() async {
    if (_serviceCallOptions.isEmpty) {
      await _fetchPurchaseServiceCalls();
    }
    if (!mounted) return;

    final selected = await _openServiceCallPickerBottomSheet(
      options: <_ServiceCallOption>[
        const _ServiceCallOption(
          serviceCallNo: _noneOption,
          businessPartner: '',
          serviceCallDate: '',
          projectCode: '',
        ),
        ..._serviceCallOptions,
      ],
      searchHint: 'Search ServiceCallNo / BusinessPartner / Date',
      emptyText: 'No service call found',
    );
    if (!mounted || selected == null) return;

    setState(() {
      _serviceCallController.text = _isNoneOrEmpty(selected.serviceCallNo)
          ? ''
          : selected.displayLabel;
    });
  }

  Future<_ServiceCallOption?> _openServiceCallPickerBottomSheet({
    required List<_ServiceCallOption> options,
    required String searchHint,
    required String emptyText,
  }) async {
    return showModalBottomSheet<_ServiceCallOption>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        var query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = options.where((option) {
              final q = query.trim().toLowerCase();
              if (q.isEmpty) return true;
              return option.serviceCallNo.toLowerCase().contains(q) ||
                  option.businessPartner.toLowerCase().contains(q) ||
                  option.serviceCallDate.toLowerCase().contains(q) ||
                  option.displayLabel.toLowerCase().contains(q);
            }).toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 12,
                ),
                child: SizedBox(
                  height: 420,
                  child: Column(
                    children: [
                      TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: searchHint,
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFFFBFBFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD7DCE4),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            query = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(child: Text(emptyText))
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final option = filtered[index];
                                  final isNoneOption =
                                      option.serviceCallNo
                                          .trim()
                                          .toLowerCase() ==
                                      _noneOption.toLowerCase();
                                  return ListTile(
                                    dense: true,
                                    title: Text(option.serviceCallNo),
                                    subtitle: isNoneOption
                                        ? null
                                        : Text(
                                            [
                                              if (option
                                                  .businessPartner.isNotEmpty)
                                                option.businessPartner,
                                              if (option
                                                  .serviceCallDate.isNotEmpty)
                                                'Date: ${option.serviceCallDate}',
                                            ].join(' • '),
                                          ),
                                    onTap: () =>
                                        Navigator.pop(sheetContext, option),
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

  Future<_CodeNameOption?> _openCodeNamePicker({
    required List<_CodeNameOption> options,
    required String searchHint,
    required String emptyText,
  }) async {
    return showModalBottomSheet<_CodeNameOption>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        var query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = options.where((option) {
              final q = query.trim().toLowerCase();
              if (q.isEmpty) return true;
              return option.code.toLowerCase().contains(q) ||
                  option.name.toLowerCase().contains(q) ||
                  option.displayLabel.toLowerCase().contains(q);
            }).toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 12,
                ),
                child: SizedBox(
                  height: 420,
                  child: Column(
                    children: [
                      TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: searchHint,
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFFFBFBFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD7DCE4),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            query = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(child: Text(emptyText))
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final option = filtered[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(option.displayLabel),
                                    onTap: () =>
                                        Navigator.pop(sheetContext, option),
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

  String _readValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        final normalized = value.toString().trim();
        if (normalized.isNotEmpty) {
          return normalized;
        }
      }
    }
    return '';
  }

  void _applyInitialHeaderData(PurchaseRequestHeaderData? data) {
    if (data == null) {
      return;
    }

    if ((data.docDate ?? '').trim().isNotEmpty) {
      _docDateController.text = data.docDate!.trim();
    }
    if ((data.requester ?? '').trim().isNotEmpty) {
      _requesterName = data.requester!.trim();
      _requesterNameController.text = data.requester!.trim();
    }
    if ((data.priority ?? '').trim().isNotEmpty) {
      _priority = data.priority!.trim().toUpperCase();
    }
    if ((data.department ?? '').trim().isNotEmpty) {
      _responsibleDepartment = data.department!.trim();
    }
    if ((data.remarks ?? '').trim().isNotEmpty) {
      _remarksController.text = data.remarks!.trim();
    }
  }

  void _applyPurchaseRequestDetails(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) {
      return;
    }

    final header = rows.first;
    _docNoController.text = _readValue(header, <String>['DocNo']);

    _docDateController.text = _formatDisplayDate(
      _readValue(header, <String>['DocDate']),
    );
    _requiredDateController.text = _formatDisplayDate(
      _readValue(header, <String>['RequiredDate']),
    );
    _validUntilController.text = _formatDisplayDate(
      _readValue(header, <String>['ValidUntil']),
    );
    _amendmentDateController.text = _formatDisplayDate(
      _readValue(header, <String>['AmendmentDate']),
    );

    _requesterName = _readValue(header, <String>['Requester']);
    _requesterNameController.text = _requesterName ?? '';

    _ownerName = _readValue(header, <String>['Owner']);
    _ownerNameController.text = _ownerName ?? '';

    _requisitionToDepartment = _readValue(header, <String>[
      'ReqToDept',
      'RequisitionToDepartment',
    ]);
    _reqDepartmentController.text = _requisitionToDepartment ?? '';

    _requisitionTo = _readValue(header, <String>['ReqTo']);
    _reqToController.text = _requisitionTo ?? '';

    _requirementType = _readValue(header, <String>[
      'RequirementType',
    ]).toUpperCase();
    _explanationController.text = _readValue(header, <String>[
      'ReplacementExplanation',
    ]);

    final serviceCallNo = _readValue(header, <String>['ServiceCallNo']);
    final salesOrderNo = _readValue(header, <String>['SalesOrderNo']);
    _serviceCallController.text = serviceCallNo;
    _salesOrderController.text = salesOrderNo;

    _responsibleDepartment = _readValue(header, <String>[
      'ResponsibleDept',
      'Department',
    ]);
    _priority = _readValue(header, <String>['Priority']).toUpperCase();
    _natureOfProcurement = _readValue(header, <String>[
      'NatureOfProcurement',
    ]);
    _privateClient = _readValue(header, <String>['PrivateClient']).toUpperCase();

    _shipToController.text = _readValue(header, <String>['ShipTo']);
    _remarksController.text = _readValue(header, <String>['Remarks']);
    _importantNoteController.text = _readValue(header, <String>[
      'ImportantNote',
    ]);

    for (final item in items) {
      item.dispose();
    }
    items
      ..clear()
      ..addAll(
        rows.map((row) {
          final item = _PurchaseItem();
          final itemCode = _readValue(row, <String>['ItemCode']);
          final warehouse = _readValue(row, <String>['Warehouse']);
          final projectCode = _readValue(row, <String>['ProjectCode']);
          final qty = _readValue(row, <String>['Qty']);

          item.itemCode = itemCode;
          item.warehouse = warehouse;
          item.projectCode = projectCode;
          item.itemCodeController.text = itemCode;
          item.descriptionController.text = _readValue(row, <String>[
            'ItemDescription',
          ]);
          item.detailsController.text = _readValue(row, <String>[
            'ItemDetails',
          ]);
          item.qtyController.text = qty;
          item.warehouseCodeController.text = warehouse;
          item.projectCodeController.text = projectCode;
          return item;
        }),
      );

    if (items.isEmpty) {
      items.add(_PurchaseItem());
    }
  }

  List<Map<String, dynamic>> _normalizedPurchaseRequestDetailRows(
    List<Map<String, dynamic>> rows,
  ) {
    final seen = <String>{};
    final normalized = <Map<String, dynamic>>[];

    for (final row in rows) {
      final lineIdentity = _readValue(row, const <String>[
        'LineNum',
        'LineNo',
        'RowNo',
        'VisOrder',
      ]);

      final fallbackIdentity = <String>[
        _readValue(row, const <String>['ItemCode']).toLowerCase(),
        _readValue(row, const <String>['ItemDescription']).toLowerCase(),
        _readValue(row, const <String>['ItemDetails']).toLowerCase(),
        _readValue(row, const <String>['Qty']).toLowerCase(),
        _readValue(row, const <String>['Warehouse']).toLowerCase(),
        _readValue(row, const <String>['ProjectCode']).toLowerCase(),
      ].join('|');

      final dedupeKey = lineIdentity.isNotEmpty
          ? 'line:${lineIdentity.toLowerCase()}'
          : 'fallback:$fallbackIdentity';

      if (seen.add(dedupeKey)) {
        normalized.add(row);
      }
    }

    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061633),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          'Purchase Request',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: _isViewDetailsMode
            ? null
            : [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: OutlinedButton(
                    onPressed: () => Navigator.maybePop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _validateAndSubmit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1E69F2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save & Submit'),
                  ),
                ),
              ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 12 : 16,
                14,
                isMobile ? 12 : 16,
                14 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  if (_isLoadingExistingRequest) ...[
                    const LinearProgressIndicator(minHeight: 3),
                    const SizedBox(height: 12),
                  ],
                  if (isMobile) ...[
                    _buildRequesterDetailsCard(),
                    const SizedBox(height: 12),
                    _buildServiceDetailsCard(),
                    const SizedBox(height: 12),
                    _buildDocumentInfoCard(),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildRequesterDetailsCard()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildServiceDetailsCard()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDocumentInfoCard()),
                      ],
                    ),
                  const SizedBox(height: 14),
                  _buildItemsCard(isMobile),
                  const SizedBox(height: 14),
                  _buildAttachmentsCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _validateAndSubmit() async {
    final errors = <String>[];

    if (_requesterNameController.text.trim().isEmpty) {
      errors.add('Requester is required');
    }
    if (_ownerNameController.text.trim().isEmpty) {
      errors.add('Owner is required');
    }
    if (_reqToController.text.trim().isEmpty) {
      errors.add('Requisition To is required');
    }
    if ((_responsibleDepartment ?? '').trim().isEmpty) {
      errors.add('Department is required');
    }
    if (_requiredDateController.text.trim().isEmpty) {
      errors.add('Required Date is required');
    }

    for (int i = 0; i < items.length; i++) {
      final row = items[i];
      final rowNo = i + 1;

      if (row.itemCodeController.text.trim().isEmpty) {
        errors.add('Row $rowNo: Item is required');
      }

      final qty = double.tryParse(row.qtyController.text.trim());
      if (qty == null || qty <= 0) {
        errors.add('Row $rowNo: Qty must be > 0');
      }

      if (row.warehouseCodeController.text.trim().isEmpty) {
        errors.add('Row $rowNo: Warehouse required');
      }

      if (row.projectCodeController.text.trim().isEmpty) {
        errors.add('Row $rowNo: Project required');
      }
    }

    final selectedProjectCodes = items
        .map((row) => row.projectCodeController.text.trim())
        .where((value) => value.isNotEmpty)
        .toSet();

    final hasMatchingServiceCall = selectedProjectCodes.any(
      (projectCode) => _serviceCallOptions.any(
        (option) =>
            option.projectCode.trim().isNotEmpty &&
            option.projectCode.trim().toLowerCase() ==
                projectCode.toLowerCase(),
      ),
    );
    if (hasMatchingServiceCall && _serviceCallController.text.trim().isEmpty) {
      errors.add(
        'Service Call is required when a matching service call exists for the selected project',
      );
    }

    final hasMatchingSalesOrder = selectedProjectCodes.any(
      (projectCode) => _salesOrderOptions.any(
        (option) =>
            option.projectCode.trim().isNotEmpty &&
            option.projectCode.trim().toLowerCase() ==
                projectCode.toLowerCase(),
      ),
    );
    if (hasMatchingSalesOrder && _salesOrderController.text.trim().isEmpty) {
      errors.add(
        'Sales Order is required when a matching sales order exists for the selected project',
      );
    }

    if (errors.isNotEmpty) {
      await _showValidationErrors(errors);
      return;
    }

    await _submitPurchaseRequest();
  }

  Future<void> _showValidationErrors(List<String> errors) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 14,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please fix these errors',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: errors.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (_, index) => Text(
                      '• ${errors[index]}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('OK'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitPurchaseRequest() async {
    final payload = <String, dynamic>{
      'DocNo': _docNoController.text.trim(),
      'DocDate': _toApiDate(_docDateController.text.trim()),
      'RequiredDate': _toApiDate(_requiredDateController.text.trim()),
      'ValidUntil': _toApiDate(_validUntilController.text.trim()),
      'AmendmentDate': _toApiDate(_amendmentDateController.text.trim()),
      'Requester': _requesterNameController.text.trim(),
      'APKUSERID': UserSession.loggedInEmail,
      'Owner': _ownerNameController.text.trim(),
      'ReqToDept': _requisitionToDepartment ?? '',
      'RequisitionToDepartment': _requisitionToDepartment ?? '',
      'Department': _responsibleDepartment ?? _requisitionToDepartment ?? '',
      'ReqTo': _reqToController.text.trim(),
      'RequirementType': (_requirementType ?? '').toUpperCase(),
      'ReplacementExplanation': _explanationController.text.trim().isEmpty
          ? 'NA'
          : _explanationController.text.trim(),
      'ServiceCallNo': _extractLeadingCode(_serviceCallController.text.trim()),
      'SalesOrderNo': _extractLeadingCode(_salesOrderController.text.trim()),
      'ResponsibleDept': _responsibleDepartment ?? '',
      'Priority': (_priority ?? '').toUpperCase(),
      'NatureOfProcurement': _natureOfProcurement ?? '',
      'PrivateClient': (_privateClient ?? '').toUpperCase(),
      'ShipTo': _shipToController.text.trim(),
      'Remarks': _remarksController.text.trim(),
      'ImportantNote': _importantNoteController.text.trim(),
      'Lines': items
          .map(
            (row) => <String, dynamic>{
              'ItemCode': row.itemCodeController.text.trim(),
              'ItemDescription': row.descriptionController.text.trim(),
              'ItemDetails': row.detailsController.text.trim(),
              'Qty': double.tryParse(row.qtyController.text.trim()) ?? 0,
              'Warehouse': row.warehouseCodeController.text.trim(),
              'ProjectCode': row.projectCodeController.text.trim(),
            },
          )
          .toList(),
    };

    setState(() {
      _isSubmitting = true;
    });
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.createPurchaseRequestPath}',
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

      final body = response.body;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Submit failed (${response.statusCode})');
      }

      String message = 'Purchase Request submitted successfully';
      if (body.isNotEmpty) {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          final serverMessage = decoded['message']?.toString().trim();
          if (serverMessage != null && serverMessage.isNotEmpty) {
            message = serverMessage;
          }

          final serverDocNo = _readValue(decoded, <String>[
            'DocNo',
            'DocNum',
            'PurchaserequestNo',
            'PurchaseRequestNo',
          ]);
          if (serverDocNo.isNotEmpty) {
            _docNoController.text = serverDocNo;
          }
        }
      }

      final purchaseRequestNo = _docNoController.text.trim();
      if (purchaseRequestNo.isNotEmpty &&
          !message.toLowerCase().contains(purchaseRequestNo.toLowerCase())) {
        message = '$message\nPurchase Request No: $purchaseRequestNo';
      }

      await _uploadPurchaseRequestAttachments(_docNoController.text.trim());

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

  Future<void> _uploadPurchaseRequestAttachments(String docNo) async {
    if (_attachments.isEmpty || docNo.isEmpty) {
      return;
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.uploadPurchaseRequestFilePath}',
    );

    for (final file in _attachments) {
      final fileName = _resolvedAttachmentFileName(file);
      final fileLength = await file.length();
      if (fileLength <= 0) {
        throw Exception('Attachment is empty: $fileName');
      }

      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(<String, String>{
          'Authorization': ApiConstants.basicAuthorization,
          'Accept': 'application/json',
        })
        ..fields['DocNo'] = docNo
        ..files.add(
          http.MultipartFile(
            'file',
            file.openRead(),
            fileLength,
            filename: fileName,
          ),
        );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = response.body.trim();
        throw Exception(
          message.isNotEmpty
              ? message
              : 'Attachment upload failed (${response.statusCode})',
        );
      }
    }
  }

  String _resolvedAttachmentFileName(XFile file) {
    final directName = file.name.trim();
    final path = file.path.trim();
    final pathName = path.isEmpty ? '' : path.split('/').last.trim();
    final candidate = directName.isNotEmpty ? directName : pathName;
    if (candidate.isEmpty) {
      return 'attachment.jpg';
    }
    final hasExtension = RegExp(r'\.[A-Za-z0-9]{2,5}$').hasMatch(candidate);
    return hasExtension ? candidate : '$candidate.jpg';
  }

  String _extractLeadingCode(String input) {
    final value = input.trim();
    if (value.isEmpty) return '';
    final separatorIndex = value.indexOf(' - ');
    if (separatorIndex <= 0) return value;
    return value.substring(0, separatorIndex).trim();
  }

  String _toApiDate(String value) {
    final text = value.trim();
    if (text.isEmpty) return '';
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
      return text;
    }
    final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(text);
    if (match == null) return text;
    final day = match.group(1)!;
    final month = match.group(2)!;
    final year = match.group(3)!;
    return '$year-$month-$day';
  }

  String _formatDisplayDate(String value) {
    final text = _stripTimeFromDateText(value.trim());
    if (text.isEmpty) return '';

    final epochMatch = RegExp(r'^/Date\((\d+)\)/$').firstMatch(text);
    if (epochMatch != null) {
      final epochMillis = int.tryParse(epochMatch.group(1)!);
      if (epochMillis != null) {
        final parsed = DateTime.fromMillisecondsSinceEpoch(epochMillis);
        final day = parsed.day.toString().padLeft(2, '0');
        final month = parsed.month.toString().padLeft(2, '0');
        return '$day/$month/${parsed.year}';
      }
    }

    final parsed = DateTime.tryParse(text);
    if (parsed != null) {
      final day = parsed.day.toString().padLeft(2, '0');
      final month = parsed.month.toString().padLeft(2, '0');
      return '$day/$month/${parsed.year}';
    }

    final slashMatch = RegExp(
      r'^(\d{1,2})/(\d{1,2})/(\d{4})$',
    ).firstMatch(text);
    if (slashMatch != null) {
      final day = slashMatch.group(1)!.padLeft(2, '0');
      final month = slashMatch.group(2)!.padLeft(2, '0');
      final year = slashMatch.group(3)!;
      return '$day/$month/$year';
    }

    final dashMatch = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(text);
    if (dashMatch != null) {
      final year = dashMatch.group(1)!;
      final month = dashMatch.group(2)!.padLeft(2, '0');
      final day = dashMatch.group(3)!.padLeft(2, '0');
      return '$day/$month/$year';
    }

    final ddMmYyyyDashMatch = RegExp(
      r'^(\d{1,2})-(\d{1,2})-(\d{4})$',
    ).firstMatch(text);
    if (ddMmYyyyDashMatch != null) {
      final day = ddMmYyyyDashMatch.group(1)!.padLeft(2, '0');
      final month = ddMmYyyyDashMatch.group(2)!.padLeft(2, '0');
      final year = ddMmYyyyDashMatch.group(3)!;
      return '$day/$month/$year';
    }

    final yyyyMmDdSlashMatch = RegExp(
      r'^(\d{4})/(\d{1,2})/(\d{1,2})$',
    ).firstMatch(text);
    if (yyyyMmDdSlashMatch != null) {
      final year = yyyyMmDdSlashMatch.group(1)!;
      final month = yyyyMmDdSlashMatch.group(2)!.padLeft(2, '0');
      final day = yyyyMmDdSlashMatch.group(3)!.padLeft(2, '0');
      return '$day/$month/$year';
    }

    return text;
  }

  String _stripTimeFromDateText(String value) {
    if (value.isEmpty) return value;

    final leadingDate = RegExp(
      r'^(\d{1,2}/\d{1,2}/\d{4}|\d{4}-\d{1,2}-\d{1,2}|\d{1,2}-\d{1,2}-\d{4}|\d{4}/\d{1,2}/\d{1,2})',
    ).firstMatch(value);
    if (leadingDate != null) {
      return leadingDate.group(1)!;
    }

    final tIndex = value.indexOf('T');
    if (tIndex > 0) {
      final beforeT = value.substring(0, tIndex).trim();
      if (RegExp(r'^\d{4}-\d{1,2}-\d{1,2}$').hasMatch(beforeT)) {
        return beforeT;
      }
    }

    return value;
  }

  Future<void> _openUploadOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.camera_alt_outlined),
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera is not supported on this platform'),
          ),
        );
        return;
      }

      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: _attachmentImageQuality,
        maxWidth: _attachmentMaxWidth,
        maxHeight: _attachmentMaxHeight,
      );
      if (!mounted || photo == null) {
        return;
      }

      setState(() {
        _attachments.add(photo);
      });
    } on MissingPluginException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image picker plugin not loaded. Please reinstall and run again.',
          ),
        ),
      );
    } on PlatformException catch (e) {
      if (!mounted) {
        return;
      }
      final code = e.code.toLowerCase();
      if (code.contains('permission')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied. Please allow camera access.'),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open camera (${e.code})')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to open camera. $e')));
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final files = await _imagePicker.pickMultiImage(
        imageQuality: _attachmentImageQuality,
        maxWidth: _attachmentMaxWidth,
        maxHeight: _attachmentMaxHeight,
      );
      if (!mounted || files.isEmpty) {
        return;
      }

      setState(() {
        _attachments.addAll(files);
      });
    } on MissingPluginException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image picker plugin not loaded. Please reinstall and run again.',
          ),
        ),
      );
    } on PlatformException catch (e) {
      if (!mounted) {
        return;
      }
      final code = e.code.toLowerCase();
      if (code.contains('permission')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permission denied. Please allow photos/media library access.',
            ),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open gallery (${e.code})')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to pick files from gallery. $e')),
      );
    }
  }

  Widget _buildRequesterDetailsCard() {
    return _sectionCard(
      title: 'Requester Details',
      child: Column(
        children: [
          _dropdownField(
            label: 'Requester Name',
            value: _requesterName,
            items: _purchaseEmployeeOptions,
            onChanged: (value) => setState(() {
              _requesterName = value;
              _requesterNameController.text = value ?? '';
            }),
            hint: 'Search Requester Name',
          ),
          const SizedBox(height: 10),
          _dropdownField(
            label: 'Owner Name',
            value: _ownerName,
            items: _purchaseEmployeeOptions,
            onChanged: (value) => setState(() {
              _ownerName = value;
              _ownerNameController.text = value ?? '';
            }),
            hint: 'Search Owner Name',
          ),
          const SizedBox(height: 10),
          _dropdownField(
            label: 'Requisition To Department',
            value: _requisitionToDepartment,
            items: kDepartmentOptions,
            onChanged: (value) => setState(() {
              _requisitionToDepartment = value;
              _reqDepartmentController.text = value ?? '';
            }),
            hint: 'Search Department',
          ),
          const SizedBox(height: 10),
          _dropdownField(
            label: 'Requisition To',
            value: _requisitionTo,
            items: _purchaseEmployeeOptions,
            onChanged: (value) => setState(() {
              _requisitionTo = value;
              _reqToController.text = value ?? '';
            }),
            hint: 'Search Requester Name',
          ),
          const SizedBox(height: 10),
          _dropdownField(
            label: 'Requirement Type',
            value: _requirementType,
            items: const ['NEW REQUIREMENT', 'REPLACEMENT'],
            onChanged: (value) =>
                setState(() => _requirementType = value?.toUpperCase()),
            hint: 'Search Requirement Type',
          ),
          const SizedBox(height: 10),
          _labelField(
            'Explanation for Replacement',
            _explanationController,
            maxLines: 3,
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
          TextField(
            controller: _serviceCallController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Service Call No',
              hintText: 'Search ServiceCallNo / BP / Date',
              filled: true,
              fillColor: const Color(0xFFFBFBFC),
              suffixIcon: const Icon(Icons.arrow_drop_down),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
              ),
            ),
            onTap: _openServiceCallPicker,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _salesOrderController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Sales Order No',
              hintText: 'Search Sales Order',
              filled: true,
              fillColor: const Color(0xFFFBFBFC),
              suffixIcon: const Icon(Icons.arrow_drop_down),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
              ),
            ),
            onTap: _openSalesOrderPicker,
          ),
          const SizedBox(height: 10),
          _dropdownField(
            label: 'Responsible Department',
            value: _responsibleDepartment,
            items: kResponsibleDepartmentOptions,
            onChanged: (value) =>
                setState(() => _responsibleDepartment = value),
            hint: 'Select Department',
          ),
          const SizedBox(height: 10),
          _dropdownField(
            label: 'Priority',
            value: _priority,
            items: const ['HIGH', 'LOW', 'MEDIUM', 'URGENT'],
            onChanged: (value) =>
                setState(() => _priority = value?.toUpperCase()),
            hint: 'Search Priority',
          ),
          const SizedBox(height: 10),
          _dropdownField(
            label: 'Nature of Procurement',
            value: _natureOfProcurement,
            items: const [
              'Existing Project',
              'AddOn Project',
              'CAMC',
              'Repair',
              'Internal Office Use',
              'Upgradation',
            ],
            onChanged: (value) => setState(() => _natureOfProcurement = value),
            hint: 'Search Nature',
          ),
          const SizedBox(height: 10),
          _dropdownField(
            label: 'Private Client',
            value: _privateClient,
            items: const ['YES', 'NO'],
            onChanged: (value) =>
                setState(() => _privateClient = value?.toUpperCase()),
            hint: 'Search Option',
          ),
          const SizedBox(height: 10),
          _labelField('Ship To', _shipToController),
        ],
      ),
    );
  }

  Widget _buildDocumentInfoCard() {
    return _sectionCard(
      title: 'Document Info',
      child: Column(
        children: [
          _labelField('Doc No', _docNoController, readOnly: true),
          const SizedBox(height: 10),
          _labelField('Doc Date', _docDateController, readOnly: true),
          const SizedBox(height: 10),
          _dateField('Required Date', _requiredDateController),
          const SizedBox(height: 10),
          _dateField('Valid Until', _validUntilController),
          const SizedBox(height: 10),
          _dateField('Amendment Date', _amendmentDateController),
          const SizedBox(height: 10),
          _labelField('Remarks', _remarksController, maxLines: 3),
          const SizedBox(height: 10),
          _labelField('Important Note', _importantNoteController, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildItemsCard(bool isMobile) {
    final headerStyle = TextStyle(
      fontSize: isMobile ? 11 : 12,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF6C7684),
    );
    const tableMinWidth = 1360.0;

    return _sectionCard(
      title: 'Items',
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: tableMinWidth),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3F7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text('#', style: headerStyle),
                        ),
                        SizedBox(
                          width: 250,
                          child: Text('ITEMCODE', style: headerStyle),
                        ),
                        SizedBox(
                          width: 330,
                          child: Text('ITEM DESCRIPTION', style: headerStyle),
                        ),
                        SizedBox(
                          width: 300,
                          child: Text('ITEM DETAILS', style: headerStyle),
                        ),
                        SizedBox(
                          width: 170,
                          child: Text('QTY', style: headerStyle),
                        ),
                        SizedBox(
                          width: 240,
                          child: Text('WAREHOUSE', style: headerStyle),
                        ),
                        SizedBox(
                          width: 220,
                          child: Text('PROJECTCODE', style: headerStyle),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text('ACT', style: headerStyle),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...List.generate(
                    items.length,
                    (index) => _itemRow(index + 1, items[index], isMobile),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsCard() {
    return _sectionCard(
      title: 'Attachments',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _isViewDetailsMode ? null : _openUploadOptions,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 130),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFCFE),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFC8CED9),
              style: BorderStyle.solid,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isViewDetailsMode
                      ? 'Attachments are view only'
                      : 'Take Photo / Choose From Gallery',
                  style: TextStyle(
                    color: Color(0xFF6A7685),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isViewDetailsMode
                      ? 'Upload is disabled in view details'
                      : 'Click here to upload files',
                  style: TextStyle(
                    color: _isViewDetailsMode
                        ? const Color(0xFF6A7685)
                        : const Color(0xFF2D66C6),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${_attachments.length} file(s) selected',
                    style: const TextStyle(
                      color: Color(0xFF2B3A4A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _attachments.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final file = _attachments[index];
                        return GestureDetector(
                          onTap: () => _openAttachmentPreview(file),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 96,
                                  height: 96,
                                  child: _xFileImage(
                                    file,
                                    fit: BoxFit.cover,
                                    cacheWidth: 192,
                                    cacheHeight: 192,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: _isViewDetailsMode
                                    ? const SizedBox.shrink()
                                    : InkWell(
                                        onTap: () {
                                          setState(() {
                                            _attachments.removeAt(index);
                                          });
                                        },
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
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAttachmentPreview(XFile file) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: 420,
              height: 420,
              child: _xFileImage(
                file,
                fit: BoxFit.contain,
                cacheWidth: 840,
                cacheHeight: 840,
              ),
            ),
          ),
        );
      },
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

  Widget _itemRow(int index, _PurchaseItem item, bool isMobile) {
    final rowTextStyle = TextStyle(
      color: const Color(0xFF2A3038),
      fontSize: isMobile ? 12 : 14,
    );
    final isReadOnly = _isViewDetailsMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text('$index', style: rowTextStyle)),
          SizedBox(
            width: 250,
            child: TextField(
              controller: item.itemCodeController,
              readOnly: true,
              style: rowTextStyle,
              decoration: _itemInputDecoration(
                hintText: 'Search ItemCode',
                suffixIcon: isReadOnly
                    ? null
                    : const Icon(Icons.arrow_drop_down),
              ),
              onTap: isReadOnly ? null : () => _openItemPicker(item),
            ),
          ),
          SizedBox(
            width: 330,
            child: TextField(
              controller: item.descriptionController,
              readOnly: true,
              style: rowTextStyle,
              decoration: _itemInputDecoration(),
            ),
          ),
          SizedBox(
            width: 300,
            child: TextField(
              controller: item.detailsController,
              readOnly: isReadOnly,
              style: rowTextStyle,
              decoration: _itemInputDecoration(),
            ),
          ),
          SizedBox(
            width: 170,
            child: TextField(
              controller: item.qtyController,
              readOnly: isReadOnly,
              keyboardType: TextInputType.number,
              style: rowTextStyle,
              decoration: _itemInputDecoration(),
            ),
          ),
          SizedBox(
            width: 240,
            child: TextField(
              controller: item.warehouseCodeController,
              readOnly: true,
              style: rowTextStyle,
              decoration: _itemInputDecoration(
                hintText: 'Search Warehouse',
                suffixIcon: isReadOnly
                    ? null
                    : const Icon(Icons.arrow_drop_down),
              ),
              onTap: isReadOnly ? null : () => _openWarehousePicker(item),
            ),
          ),
          SizedBox(
            width: 220,
            child: TextField(
              controller: item.projectCodeController,
              readOnly: true,
              style: rowTextStyle,
              decoration: _itemInputDecoration(
                hintText: 'Search Project',
                suffixIcon: isReadOnly
                    ? null
                    : const Icon(Icons.arrow_drop_down),
              ),
              onTap: isReadOnly ? null : () => _openProjectPicker(item),
            ),
          ),
          SizedBox(
            width: 90,
            child: isReadOnly
                ? const SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: _addItemRow,
                        child: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      InkWell(
                        onTap: () => _removeItemRow(item),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  InputDecoration _itemInputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      isDense: true,
      hintText: hintText,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFBFBFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
      ),
    );
  }

  void _addItemRow() {
    setState(() {
      items.add(_PurchaseItem());
    });
  }

  void _removeItemRow(_PurchaseItem item) {
    if (items.length == 1) {
      return;
    }
    setState(() {
      items.remove(item);
      item.dispose();
    });
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDE2EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 23,
              color: Color(0xFF2B3A4A),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _labelField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFBFBFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
        ),
      ),
    );
  }

  Widget _dateField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
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
                icon: const Icon(Icons.close, size: 18),
              ),
            const Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 8),
          ],
        ),
        filled: true,
        fillColor: const Color(0xFFFBFBFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
        ),
      ),
      onTap: () async {
        final initialDate = _parsePurchaseDate(controller.text.trim());
        final now = DateTime.now();
        final pickerInitialDate = initialDate == null || initialDate.year < 2020
            ? now
            : initialDate;
        final picked = await showDatePicker(
          context: context,
          initialDate: pickerInitialDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (!mounted || picked == null) {
          return;
        }

        controller.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      },
    );
  }

  DateTime? _parsePurchaseDate(String value) {
    final text = value.trim();
    final slashMatch = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(text);
    if (slashMatch != null) {
      final day = int.tryParse(slashMatch.group(1)!);
      final month = int.tryParse(slashMatch.group(2)!);
      final year = int.tryParse(slashMatch.group(3)!);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return DateTime.tryParse(text);
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
    bool allowNone = false,
  }) {
    return InkWell(
      onTap: () async {
        final selected = await _openTextPicker(
          options: allowNone ? _withNoneOption(items) : items,
          searchHint: hint,
          emptyText: 'No data found',
        );
        if (selected == null) return;
        onChanged(_isNoneOrEmpty(selected) ? null : selected);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: (value ?? '').trim().isEmpty ? hint : null,
          filled: true,
          fillColor: const Color(0xFFFBFBFC),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
          ),
        ),
        child: Text(value?.trim().isNotEmpty == true ? value! : ''),
      ),
    );
  }

  Future<String?> _openTextPicker({
    required List<String> options,
    required String searchHint,
    required String emptyText,
  }) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        var query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = options.where((option) {
              final q = query.trim().toLowerCase();
              if (q.isEmpty) return true;
              return option.toLowerCase().contains(q);
            }).toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 12,
                ),
                child: SizedBox(
                  height: 420,
                  child: Column(
                    children: [
                      TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: searchHint,
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFFFBFBFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD7DCE4),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            query = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(child: Text(emptyText))
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final option = filtered[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(option),
                                    onTap: () =>
                                        Navigator.pop(sheetContext, option),
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
}

class _PurchaseItem {
  String? itemCode;
  String? warehouse;
  String? projectCode;
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController warehouseCodeController = TextEditingController();
  final TextEditingController projectCodeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();

  _PurchaseItem();

  void dispose() {
    itemCodeController.dispose();
    warehouseCodeController.dispose();
    projectCodeController.dispose();
    descriptionController.dispose();
    detailsController.dispose();
    qtyController.dispose();
  }
}

class _CodeNameOption {
  const _CodeNameOption({required this.code, required this.name});

  final String code;
  final String name;

  String get displayLabel => name.isEmpty ? code : '$code - $name';
}

class _SalesOrderOption {
  const _SalesOrderOption({
    required this.soNo,
    required this.customer,
    required this.soDate,
    required this.projectCode,
  });

  final String soNo;
  final String customer;
  final String soDate;
  final String projectCode;

  String get displayLabel {
    final parts = <String>[soNo];
    if (customer.isNotEmpty) {
      parts.add(customer);
    }
    if (soDate.isNotEmpty) {
      parts.add(soDate);
    }
    return parts.join(' - ');
  }
}

class _ServiceCallOption {
  const _ServiceCallOption({
    required this.serviceCallNo,
    required this.businessPartner,
    required this.serviceCallDate,
    required this.projectCode,
  });

  final String serviceCallNo;
  final String businessPartner;
  final String serviceCallDate;
  final String projectCode;

  String get displayLabel {
    final parts = <String>[serviceCallNo];
    if (businessPartner.isNotEmpty) {
      parts.add(businessPartner);
    }
    if (serviceCallDate.isNotEmpty) {
      parts.add(serviceCallDate);
    }
    return parts.join(' - ');
  }
}

class PurchaseRequestHeaderData {
  const PurchaseRequestHeaderData({
    this.docDate,
    this.requester,
    this.priority,
    this.department,
    this.remarks,
  });

  final String? docDate;
  final String? requester;
  final String? priority;
  final String? department;
  final String? remarks;
}
