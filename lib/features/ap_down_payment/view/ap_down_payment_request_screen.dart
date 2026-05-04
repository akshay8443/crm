import 'dart:convert';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/session/user_session.dart';

class ApDownPaymentRequestScreen extends StatefulWidget {
  const ApDownPaymentRequestScreen({super.key});

  @override
  State<ApDownPaymentRequestScreen> createState() =>
      _ApDownPaymentRequestScreenState();
}

class _ApDownPaymentRequestScreenState
    extends State<ApDownPaymentRequestScreen> {
  static const String _noneOption = 'None';
  final ImagePicker _imagePicker = ImagePicker();
  final List<_DownPaymentItem> _items = [_DownPaymentItem()];
  final List<XFile> _attachments = [];

  final _vendorRefNoController = TextEditingController();
  final _cardCodeController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _buyerController = TextEditingController();
  final _ownerController = TextEditingController();
  final _serviceCallController = TextEditingController();
  final _salesOrderController = TextEditingController();
  final _tourStartDateController = TextEditingController();
  final _tourEndDateController = TextEditingController();

  final _dpmPercentController = TextEditingController();
  final _remarksController = TextEditingController();
  final _importantNoteController = TextEditingController();

  final _apDownPaymentNoController = TextEditingController();
  final _postingDateController = TextEditingController();
  final _dueDateController = TextEditingController();

  String? _responsibleDepartment;
  String? _priority;
  String? _paymentType;
  List<_VendorOption> _vendorOptions = const [];
  List<String> _buyerOptions = const [];
  List<String> _ownerOptions = const [];
  List<String> _departmentOptions = const [];
  List<String> _salesOrderOptions = const [];
  List<String> _serviceCallOptions = const [];
  List<_ItemOption> _itemOptions = const [];
  List<String> _taxCodeOptions = const [];
  List<String> _warehouseOptions = const [];
  List<String> _projectOptions = const [];
  bool _isSubmitting = false;

  final List<String> _priorityOptions = const [
    'HIGH',
    'MEDIUM',
    'LOW',
    'URGENT',
  ];

  final List<String> _paymentTypeOptions = const [
    'Select',
    'Clearance',
    'Advance',
    'Vendor Payment',
    'OthersExcepTour',
    'EmpAdvNoTour',
    'EmpClrNoTour',
  ];

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
        normalized.toLowerCase() == _noneOption.toLowerCase() ||
        normalized.toLowerCase() == 'select';
  }

  String _normalizedSelectionValue(String? value) {
    return _isNoneOrEmpty(value) ? '' : value!.trim();
  }

  void _putIfNotBlank(Map<String, dynamic> target, String key, String value) {
    final normalized = value.trim();
    if (normalized.isNotEmpty) {
      target[key] = normalized;
    }
  }

  void _putIfNumNotNull(Map<String, dynamic> target, String key, num? value) {
    if (value != null) {
      target[key] = value;
    }
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _postingDateController.text = _formatDate(now);
    _dueDateController.text = _formatDate(now);
    _fetchApDownPaymentVendors();
    _fetchApDownPaymentBuyers();
    _fetchApDownPaymentOwners();
    _fetchApDownPaymentDepartments();
    _fetchApDownPaymentSalesOrders();
    _fetchApDownPaymentServiceCalls();
    _fetchApDownPaymentItems();
    _fetchNextApDownPaymentNumber();
    _fetchApDownPaymentTaxCodes();
    _fetchApDownPaymentWarehouses();
    _fetchApDownPaymentProjects();
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    _vendorRefNoController.dispose();
    _cardCodeController.dispose();
    _cardNameController.dispose();
    _buyerController.dispose();
    _ownerController.dispose();
    _serviceCallController.dispose();
    _salesOrderController.dispose();
    _tourStartDateController.dispose();
    _tourEndDateController.dispose();
    _dpmPercentController.dispose();
    _remarksController.dispose();
    _importantNoteController.dispose();
    _apDownPaymentNoController.dispose();
    _postingDateController.dispose();
    _dueDateController.dispose();
    super.dispose();
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
          'AP Down Payment Request',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: OutlinedButton(
              onPressed: () => Navigator.maybePop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
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
              onPressed: _isSubmitting ? null : _onSubmit,
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
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            12,
            14,
            12,
            14 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            children: [
              _buildMainDetailsCard(),
              const SizedBox(height: 12),
              _buildPaymentDetailsCard(),
              const SizedBox(height: 12),
              _buildDocumentCard(),
              const SizedBox(height: 12),
              _buildItemsCard(),
              const SizedBox(height: 12),
              _buildAttachmentsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainDetailsCard() {
    return _sectionCard(
      title: 'Main Details',
      child: Column(
        children: [
          _vendorCodeField(),
          const SizedBox(height: 10),
          _labelField('Card Name', _cardNameController, readOnly: true),
          const SizedBox(height: 10),
          _labelField('Vendor Reference Number', _vendorRefNoController),
          const SizedBox(height: 10),
          _selectionField(
            label: 'Buyer',
            controller: _buyerController,
            options: _buyerOptions,
            searchHint: 'Search buyer',
          ),
          const SizedBox(height: 10),
          _selectionField(
            label: 'Owner',
            controller: _ownerController,
            options: _ownerOptions,
            searchHint: 'Search owner',
          ),
          const SizedBox(height: 10),
          _selectionField(
            label: 'Service Call',
            controller: _serviceCallController,
            options: _serviceCallOptions,
            searchHint: 'Search service call',
            allowNone: true,
          ),
          const SizedBox(height: 10),
          _selectionField(
            label: 'Sales Order',
            controller: _salesOrderController,
            options: _salesOrderOptions,
            searchHint: 'Search sales order',
            allowNone: true,
          ),
          const SizedBox(height: 10),
          _dateField('Tour Start Date', _tourStartDateController),
          const SizedBox(height: 10),
          _dateField('Tour End Date', _tourEndDateController),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return _sectionCard(
      title: 'Payment Details',
      child: Column(
        children: [
          _dropdownField(
            label: 'Responsible Department',
            value: _responsibleDepartment,
            items: _departmentOptions,
            onChanged: (value) =>
                setState(() => _responsibleDepartment = value),
            hint: 'Select department',
          ),
          const SizedBox(height: 10),
          _dropdownField(
            label: 'Priority',
            value: _priority,
            items: _priorityOptions,
            onChanged: (value) => setState(() => _priority = value),
            hint: 'Select priority',
          ),
          const SizedBox(height: 10),
          _dropdownField(
            label: 'Payment Type',
            value: _paymentType,
            items: _paymentTypeOptions,
            onChanged: (value) => setState(() => _paymentType = value),
            hint: 'Select payment type',
          ),
          const SizedBox(height: 10),
          _labelField(
            'DPM %',
            _dpmPercentController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
          const SizedBox(height: 10),
          _labelField('Remarks', _remarksController, maxLines: 3),
          const SizedBox(height: 10),
          _labelField('Important Note', _importantNoteController, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildDocumentCard() {
    return _sectionCard(
      title: 'Document Details',
      child: Column(
        children: [
          _labelField(
            'AP Down Payment No',
            _apDownPaymentNoController,
            readOnly: true,
          ),
          const SizedBox(height: 10),
          _dateField('Posting Date', _postingDateController),
          const SizedBox(height: 10),
          _dateField('Due Date', _dueDateController),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    const tableMinWidth = 1280.0;
    final headerStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Color(0xFF6C7684),
    );

    return _sectionCard(
      title: 'Items',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                          width: 30,
                          child: Text('#', style: headerStyle),
                        ),
                        SizedBox(
                          width: 160,
                          child: Text('Item Code', style: headerStyle),
                        ),
                        SizedBox(
                          width: 190,
                          child: Text('Description', style: headerStyle),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text('Qty', style: headerStyle),
                        ),
                        SizedBox(
                          width: 140,
                          child: Text('Unit Price', style: headerStyle),
                        ),
                        SizedBox(
                          width: 130,
                          child: Text('Discount %', style: headerStyle),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text('Tax Code', style: headerStyle),
                        ),
                        SizedBox(
                          width: 170,
                          child: Text('Warehouse', style: headerStyle),
                        ),
                        SizedBox(
                          width: 160,
                          child: Text('Project', style: headerStyle),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text('Act', style: headerStyle),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    _items.length,
                    (index) => _itemRow(index + 1, _items[index]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _addItemRow,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1E69F2),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Row'),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(int rowNo, _DownPaymentItem item) {
    final inputDecoration = InputDecoration(
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFFBFBFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text('$rowNo')),
          SizedBox(
            width: 160,
            child: _itemSelectionField(
              controller: item.itemCodeController,
              hintText: 'Item code',
              searchHint: 'Search item code / item name',
              onSelected: (selected) {
                setState(() {
                  item.itemCodeController.text = selected?.code ?? '';
                  final description = selected?.description;
                  item.descriptionController.text =
                      description != null && description.trim().isNotEmpty
                      ? description
                      : '';
                  item.warehouseController.text =
                      _defaultWarehouseLabel() ??
                      item.warehouseController.text.trim();
                });
              },
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 190,
            child: TextField(
              controller: item.descriptionController,
              readOnly: true,
              minLines: 1,
              maxLines: 2,
              decoration: inputDecoration.copyWith(
                hintText: 'Auto-filled from item code',
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 120,
            child: TextField(
              controller: item.qtyController,
              decoration: inputDecoration,
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 140,
            child: TextField(
              controller: item.unitPriceController,
              decoration: inputDecoration,
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 130,
            child: TextField(
              controller: item.discountController,
              decoration: inputDecoration,
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 120,
            child: _tableSelectionField(
              controller: item.taxCodeController,
              options: _taxCodeOptions,
              hintText: 'Tax code',
              searchHint: 'Search tax code',
              onSelected: (selected) {
                setState(() {
                  item.taxCodeController.text = selected ?? '';
                });
              },
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 170,
            child: _tableSelectionField(
              controller: item.warehouseController,
              options: _warehouseOptions,
              hintText: 'Warehouse',
              searchHint: 'Search warehouse',
              onSelected: (selected) {
                setState(() {
                  item.warehouseController.text = selected ?? '';
                });
              },
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 160,
            child: _tableSelectionField(
              controller: item.projectController,
              options: _projectOptions,
              hintText: 'Project',
              searchHint: 'Search project',
              onSelected: (selected) {
                setState(() {
                  item.projectController.text = selected ?? '';
                });
              },
            ),
          ),
          SizedBox(
            width: 80,
            child: IconButton(
              onPressed: () => _removeItemRow(item),
              icon: const Icon(Icons.delete_outline, color: Color(0xFFC62828)),
              tooltip: 'Delete row',
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
        onTap: _openUploadOptions,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 130),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFCFE),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFC8CED9)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Take Photo / Choose From Gallery',
                  style: TextStyle(
                    color: Color(0xFF6A7685),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Click here to upload files',
                  style: TextStyle(
                    color: Color(0xFF2D66C6),
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
                                  child: _xFileImage(file, fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
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

  Widget _vendorCodeField() {
    return TextField(
      controller: _cardCodeController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Card Code',
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
      onTap: () async {
        final selected = await _openVendorPicker();
        if (!mounted || selected == null) return;
        setState(() {
          _cardCodeController.text = selected.cardCode;
          _cardNameController.text = selected.cardName;
        });
      },
    );
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

  Future<void> _fetchApDownPaymentVendors() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getApDownBpMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get AP down payment BP master failed');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from AP down payment BP master API');
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid AP down payment BP master response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid AP down payment BP master response format');
      }

      final vendorsByCode = <String, _VendorOption>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) continue;

        final bpCode = _readValue(row, <String>['BPCode', 'CardCode', 'Code']);
        final bpName = _readValue(row, <String>['BPName', 'CardName', 'Name']);

        if (bpCode.trim().isNotEmpty) {
          vendorsByCode[bpCode.trim()] = _VendorOption(
            cardCode: bpCode.trim(),
            cardName: bpName.trim(),
          );
        }
      }

      if (!mounted) return;
      final sortedOptions = vendorsByCode.values.toList()
        ..sort((a, b) => a.displayLabel.compareTo(b.displayLabel));
      setState(() {
        _vendorOptions = sortedOptions;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load vendor reference list')),
      );
    }
  }

  Future<void> _fetchApDownPaymentBuyers() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getApDownBuyerMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get AP down payment buyer master failed');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from AP down payment buyer master API');
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception(
            'Invalid AP down payment buyer master response format',
          );
        }
        rows = nested;
      } else {
        throw Exception('Invalid AP down payment buyer master response format');
      }

      final options = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) continue;

        final name = _readValue(row, <String>[
          'SalesEmployeeName',
          'BuyerName',
          'EmployeeName',
          'Name',
        ]);
        final code = _readValue(row, <String>[
          'SalesEmployeeCode',
          'SalesEmployeeID',
          'EmployeeCode',
          'Code',
        ]);

        String label = '';
        if (code.isNotEmpty && name.isNotEmpty) {
          label = '$code - $name';
        } else if (name.isNotEmpty) {
          label = name;
        } else if (code.isNotEmpty) {
          label = code;
        }

        if (label.trim().isNotEmpty) {
          options.add(label.trim());
        }
      }

      if (!mounted) return;
      setState(() {
        _buyerOptions = options.toList()..sort();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load buyer list')),
      );
    }
  }

  Future<void> _fetchApDownPaymentOwners() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getApDownOwnerMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get AP down payment owner master failed');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from AP down payment owner master API');
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception(
            'Invalid AP down payment owner master response format',
          );
        }
        rows = nested;
      } else {
        throw Exception('Invalid AP down payment owner master response format');
      }

      final options = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) continue;

        final code = _readValue(row, <String>[
          'EmployeeCode',
          'OwnerCode',
          'SalesEmployeeCode',
          'Code',
        ]);
        final firstName = _readValue(row, <String>['FirstName', 'FName']);
        final middleName = _readValue(row, <String>['MiddleName', 'MName']);
        final lastName = _readValue(row, <String>['LastName', 'LName']);
        final fullName = <String>[
          firstName,
          middleName,
          lastName,
        ].where((part) => part.trim().isNotEmpty).join(' ').trim();
        final fallbackName = _readValue(row, <String>[
          'OwnerName',
          'EmployeeName',
          'SalesEmployeeName',
          'Name',
        ]);
        final name = fullName.isNotEmpty ? fullName : fallbackName;

        String label = '';
        if (code.isNotEmpty && name.isNotEmpty) {
          label = '$code - $name';
        } else if (name.isNotEmpty) {
          label = name;
        } else if (code.isNotEmpty) {
          label = code;
        }

        if (label.trim().isNotEmpty) {
          options.add(label.trim());
        }
      }

      if (!mounted) return;
      setState(() {
        _ownerOptions = options.toList()..sort();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load owner list')),
      );
    }
  }

  Future<void> _fetchApDownPaymentDepartments() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getApDownDepartmentMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get AP down payment department master failed');
      }
      if (response.body.isEmpty) {
        throw Exception(
          'Empty response from AP down payment department master API',
        );
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception(
            'Invalid AP down payment department master response format',
          );
        }
        rows = nested;
      } else {
        throw Exception(
          'Invalid AP down payment department master response format',
        );
      }

      final options = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) continue;

        final deptName = _readValue(row, <String>[
          'DeptName',
          'Department',
          'DepartmentName',
          'Name',
        ]);
        final deptCode = _readValue(row, <String>[
          'DeptCode',
          'DepartmentCode',
          'Code',
        ]);

        String label = '';
        if (deptName.isNotEmpty) {
          label = deptName;
        } else if (deptCode.isNotEmpty) {
          label = deptCode;
        }

        if (label.trim().isNotEmpty) {
          options.add(label.trim());
        }
      }

      if (!mounted) return;
      setState(() {
        _departmentOptions = options.toList()..sort();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load department list')),
      );
    }
  }

  Future<void> _fetchApDownPaymentSalesOrders() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getApDownSalesOrderMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get AP down payment sales order master failed');
      }
      if (response.body.isEmpty) {
        throw Exception(
          'Empty response from AP down payment sales order master API',
        );
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception(
            'Invalid AP down payment sales order master response format',
          );
        }
        rows = nested;
      } else {
        throw Exception(
          'Invalid AP down payment sales order master response format',
        );
      }

      final options = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) continue;

        final soNo = _readValue(row, <String>[
          'SoNo',
          'SalesOrderNo',
          'SONo',
          'DocNum',
          'OrderNo',
          'SalesOrderNumber',
          'SalesOrder',
          'DocEntry',
          'Code',
        ]);
        final soDate = _formatSalesOrderDateForDisplay(
          _readValue(row, <String>[
            'SODate',
            'SoDate',
            'SalesOrderDate',
            'OrderDate',
            'DocDate',
            'Date',
          ]),
        );
        final customerName = _readValue(row, <String>[
          'Customer',
          'CustomerName',
          'CardName',
          'BPName',
          'Name',
        ]);

        String label = '';
        if (soNo.isNotEmpty && soDate.isNotEmpty && customerName.isNotEmpty) {
          label = '$soNo - $soDate - $customerName';
        } else if (soNo.isNotEmpty && soDate.isNotEmpty) {
          label = '$soNo - $soDate';
        } else if (soNo.isNotEmpty && customerName.isNotEmpty) {
          label = '$soNo - $customerName';
        } else if (soNo.isNotEmpty) {
          label = soNo;
        } else if (soDate.isNotEmpty && customerName.isNotEmpty) {
          label = '$soDate - $customerName';
        } else if (soDate.isNotEmpty) {
          label = soDate;
        } else if (customerName.isNotEmpty) {
          label = customerName;
        }

        if (label.trim().isNotEmpty) {
          options.add(label.trim());
        }
      }

      if (!mounted) return;
      setState(() {
        _salesOrderOptions = options.toList()..sort();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load sales order list')),
      );
    }
  }

  Future<void> _fetchApDownPaymentServiceCalls() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getApDownServiceCallMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get AP down payment service call master failed');
      }
      if (response.body.isEmpty) {
        throw Exception(
          'Empty response from AP down payment service call master API',
        );
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception(
            'Invalid AP down payment service call master response format',
          );
        }
        rows = nested;
      } else {
        throw Exception(
          'Invalid AP down payment service call master response format',
        );
      }

      final options = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) continue;

        final callId = _readValue(row, <String>[
          'CallID',
          'ServiceCallNo',
          'CallNo',
          'ServiceCall',
          'DocNum',
          'Code',
          'DocEntry',
        ]);
        final bpName = _readValue(row, <String>[
          'BPName',
          'Customer',
          'CustomerName',
          'CardName',
          'Name',
          'Subject',
          'Title',
          'Description',
        ]);
        final callDate = _formatSalesOrderDateForDisplay(
          _readValue(row, <String>[
            'CallDate',
            'ServiceCallDate',
            'DocDate',
            'Date',
          ]),
        );
        final subject = _readValue(row, <String>[
          'Subject',
          'Title',
          'Description',
          'CustomerName',
          'CardName',
          'Name',
        ]);

        String label = '';
        if (callId.isNotEmpty && bpName.isNotEmpty && callDate.isNotEmpty) {
          label = '$callId - $bpName - $callDate';
        } else if (callId.isNotEmpty && bpName.isNotEmpty) {
          label = '$callId - $bpName';
        } else if (callId.isNotEmpty && callDate.isNotEmpty) {
          label = '$callId - $callDate';
        } else if (callId.isNotEmpty && subject.isNotEmpty) {
          label = '$callId - $subject';
        } else if (callId.isNotEmpty) {
          label = callId;
        } else if (bpName.isNotEmpty && callDate.isNotEmpty) {
          label = '$bpName - $callDate';
        } else if (bpName.isNotEmpty) {
          label = bpName;
        } else if (callDate.isNotEmpty) {
          label = callDate;
        } else if (subject.isNotEmpty) {
          label = subject;
        }

        if (label.trim().isNotEmpty) {
          options.add(label.trim());
        }
      }

      if (!mounted) return;
      setState(() {
        _serviceCallOptions = options.toList()..sort();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load service call list')),
      );
    }
  }

  Future<void> _fetchApDownPaymentItems() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getApDownItemMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get AP down payment item master failed');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from AP down payment item master API');
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception(
            'Invalid AP down payment item master response format',
          );
        }
        rows = nested;
      } else {
        throw Exception('Invalid AP down payment item master response format');
      }

      final itemOptions = <_ItemOption>[];
      final seenCodes = <String>{};

      for (final row in rows) {
        if (row is! Map<String, dynamic>) continue;

        final code = _readValue(row, <String>['ItemCode', 'Code', 'ItemNo']);
        final description = _readValue(row, <String>[
          'ItemDescription',
          'ItemName',
          'Dscription',
          'Description',
          'Name',
        ]);

        if (code.trim().isNotEmpty) {
          final normalizedCode = code.trim().toLowerCase();
          if (seenCodes.add(normalizedCode)) {
            itemOptions.add(
              _ItemOption(code: code.trim(), description: description.trim()),
            );
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _itemOptions = (itemOptions.toList()
          ..sort((a, b) => a.code.toLowerCase().compareTo(b.code.toLowerCase())));
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load item master list')),
      );
    }
  }

  Future<void> _fetchNextApDownPaymentNumber() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getNextApDownPaymentNumberPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get next AP down payment number failed');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from next AP down payment number API');
      }

      final decoded = jsonDecode(response.body);
      String number = '';

      if (decoded is String) {
        number = decoded.trim();
      } else if (decoded is num) {
        number = decoded.toString().trim();
      } else if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map<String, dynamic>) {
          number = _readValue(first, <String>[
            'APdownPaymentNo',
            'APDownPaymentNo',
            'APdownPaymentNumber',
            'APDownPaymentNumber',
            'DocNum',
            'Number',
            'NextNumber',
            'Code',
          ]);
        } else if (first != null) {
          number = first.toString().trim();
        }
      } else if (decoded is Map<String, dynamic>) {
        number = _readValue(decoded, <String>[
          'APdownPaymentNo',
          'APDownPaymentNo',
          'APdownPaymentNumber',
          'APDownPaymentNumber',
          'DocNum',
          'Number',
          'NextNumber',
          'data',
          'result',
          'value',
        ]);
      }

      if (!mounted || number.isEmpty) return;
      setState(() {
        _apDownPaymentNoController.text = number;
      });
    } catch (_) {
      // Keep screen usable even if number API fails.
    }
  }

  Future<void> _fetchApDownPaymentTaxCodes() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getApDownTaxCodeMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get AP down payment tax code master failed');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from AP down payment tax code API');
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid AP down payment tax code response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid AP down payment tax code response format');
      }

      final options = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) continue;

        final code = _readValue(row, <String>['TaxCode', 'VatGroup', 'Code']);
        final name = _readValue(row, <String>[
          'TaxName',
          'Name',
          'Description',
        ]);

        String label = '';
        if (code.isNotEmpty && name.isNotEmpty) {
          label = '$code - $name';
        } else if (code.isNotEmpty) {
          label = code;
        } else if (name.isNotEmpty) {
          label = name;
        }

        if (label.trim().isNotEmpty) {
          options.add(label.trim());
        }
      }

      if (!mounted) return;
      setState(() {
        _taxCodeOptions = options.toList()..sort();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load tax code list')),
      );
    }
  }

  Future<void> _fetchApDownPaymentWarehouses() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getApDownWarehouseMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get AP down payment warehouse master failed');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from AP down payment warehouse API');
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid AP down payment warehouse response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid AP down payment warehouse response format');
      }

      final options = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) continue;

        final code = _readValue(row, <String>[
          'WhsCode',
          'WarehouseCode',
          'Code',
        ]);
        final name = _readValue(row, <String>[
          'WhsName',
          'WarehouseName',
          'Name',
          'Description',
        ]);

        String label = '';
        if (code.isNotEmpty && name.isNotEmpty) {
          label = '$code - $name';
        } else if (code.isNotEmpty) {
          label = code;
        } else if (name.isNotEmpty) {
          label = name;
        }

        if (label.trim().isNotEmpty) {
          options.add(label.trim());
        }
      }

      if (!mounted) return;
      setState(() {
        _warehouseOptions = options.toList()..sort();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load warehouse list')),
      );
    }
  }

  String? _defaultWarehouseLabel() {
    for (final option in _warehouseOptions) {
      final normalized = option.trim().toLowerCase();
      if (normalized.contains('3rd floor warehouse')) {
        return option;
      }
    }
    return null;
  }

  Future<void> _fetchApDownPaymentProjects() async {
    try {
      final uri = _buildNoCacheUri(ApiConstants.getApDownProjectMasterPath);
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get AP down payment project master failed');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from AP down payment project API');
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid AP down payment project response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid AP down payment project response format');
      }

      final options = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) continue;

        final code = _readValue(row, <String>['ProjectCode', 'Code']);
        final name = _readValue(row, <String>[
          'ProjectName',
          'Name',
          'Description',
        ]);

        String label = '';
        if (code.isNotEmpty && name.isNotEmpty) {
          label = '$code - $name';
        } else if (code.isNotEmpty) {
          label = code;
        } else if (name.isNotEmpty) {
          label = name;
        }

        if (label.trim().isNotEmpty) {
          options.add(label.trim());
        }
      }

      if (!mounted) return;
      setState(() {
        _projectOptions = options.toList()..sort();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load project list')),
      );
    }
  }

  String _readValue(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      if (!row.containsKey(key)) continue;
      final value = row[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  String _formatSalesOrderDateForDisplay(String rawDate) {
    final value = rawDate.trim();
    if (value.isEmpty) return '';

    var cleaned = value;
    if (cleaned.contains('T')) {
      cleaned = cleaned.split('T').first;
    }
    if (cleaned.contains(' ')) {
      cleaned = cleaned.split(' ').first;
    }
    return cleaned.trim();
  }

  Future<void> _openUploadOptions() async {
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera is not supported on this platform'),
          ),
        );
        return;
      }

      final photo = await _imagePicker.pickImage(source: ImageSource.camera);
      if (!mounted || photo == null) return;

      setState(() {
        _attachments.add(photo);
      });
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image picker plugin not loaded. Please reinstall and run again.',
          ),
        ),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to open camera. $e')));
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final files = await _imagePicker.pickMultiImage();
      if (!mounted || files.isEmpty) return;

      setState(() {
        _attachments.addAll(files);
      });
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image picker plugin not loaded. Please reinstall and run again.',
          ),
        ),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to pick files from gallery. $e')),
      );
    }
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
              child: _xFileImage(file, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  Widget _xFileImage(XFile file, {required BoxFit fit}) {
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
        return Image.memory(bytes, fit: fit);
      },
    );
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
              fontSize: 20,
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
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
        final initialDate = _parseDate(controller.text) ?? DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (!mounted || picked == null) return;
        controller.text = _formatDate(picked);
      },
    );
  }

  Widget _selectionField({
    required String label,
    required TextEditingController controller,
    required List<String> options,
    required String searchHint,
    bool allowNone = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
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
      onTap: () async {
        final selected = await _openTextPicker(
          options: allowNone ? _withNoneOption(options) : options,
          searchHint: searchHint,
          emptyText: 'No data found',
        );
        if (!mounted || selected == null) return;
        setState(() {
          controller.text = _isNoneOrEmpty(selected) ? '' : selected;
        });
      },
    );
  }

  Future<_VendorOption?> _openVendorPicker() async {
    return showModalBottomSheet<_VendorOption>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        var query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _vendorOptions
                .where((option) {
                  final q = query.trim().toLowerCase();
                  if (q.isEmpty) return true;
                  return option.displayLabel.toLowerCase().contains(q) ||
                      option.cardCode.toLowerCase().contains(q) ||
                      option.cardName.toLowerCase().contains(q);
                })
                .toList(growable: false);

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
                          hintText: 'Search card code / card name',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFFFBFBFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD7DCE4),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD7DCE4),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() => query = value);
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(child: Text('No vendor found'))
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final option = filtered[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(option.cardCode),
                                    subtitle: option.cardName.trim().isEmpty
                                        ? null
                                        : Text(option.cardName),
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

  Widget _tableSelectionField({
    required TextEditingController controller,
    required List<String> options,
    required String hintText,
    required String searchHint,
    required ValueChanged<String?> onSelected,
  }) {
    return InkWell(
      onTap: () async {
        final selected = await _openTextPicker(
          options: options,
          searchHint: searchHint,
          emptyText: 'No data found',
        );
        if (selected == null) return;
        onSelected(_isNoneOrEmpty(selected) ? null : selected);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          isDense: true,
          hintText: (controller.text).trim().isEmpty ? hintText : null,
          filled: true,
          fillColor: const Color(0xFFFBFBFC),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
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
        child: Text(controller.text),
      ),
    );
  }

  Widget _itemSelectionField({
    required TextEditingController controller,
    required String hintText,
    required String searchHint,
    required ValueChanged<_ItemOption?> onSelected,
  }) {
    return InkWell(
      onTap: () async {
        final selected = await _openItemPicker(
          options: _itemOptions,
          searchHint: searchHint,
          emptyText: 'No item found',
        );
        if (selected == null) return;
        onSelected(selected);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          isDense: true,
          hintText: controller.text.trim().isEmpty ? hintText : null,
          filled: true,
          fillColor: const Color(0xFFFBFBFC),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
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
        child: Text(controller.text),
      ),
    );
  }

  Future<_ItemOption?> _openItemPicker({
    required List<_ItemOption> options,
    required String searchHint,
    required String emptyText,
  }) async {
    return showModalBottomSheet<_ItemOption>(
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
                  option.description.toLowerCase().contains(q) ||
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
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD7DCE4),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() => query = value);
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  emptyText,
                                  style: const TextStyle(
                                    color: Color(0xFF6A7685),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final option = filtered[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(option.code),
                                    subtitle: option.description.trim().isEmpty
                                        ? null
                                        : Text(option.description),
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

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return InkWell(
      onTap: () async {
        final selected = await _openTextPicker(
          options: items,
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
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD7DCE4),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() => query = value);
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  emptyText,
                                  style: const TextStyle(
                                    color: Color(0xFF6A7685),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
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

  void _addItemRow() {
    setState(() {
      _items.add(_DownPaymentItem());
    });
  }

  void _removeItemRow(_DownPaymentItem item) {
    if (_items.length == 1) {
      return;
    }
    setState(() {
      _items.remove(item);
      item.dispose();
    });
  }

  void _resetFormAfterSubmit() {
    final now = DateTime.now();

    _vendorRefNoController.clear();
    _cardCodeController.clear();
    _cardNameController.clear();
    _buyerController.clear();
    _ownerController.clear();
    _serviceCallController.clear();
    _salesOrderController.clear();
    _tourStartDateController.clear();
    _tourEndDateController.clear();
    _dpmPercentController.clear();
    _remarksController.clear();
    _importantNoteController.clear();
    _postingDateController.text = _formatDate(now);
    _dueDateController.text = _formatDate(now);

    for (final item in _items) {
      item.dispose();
    }

    setState(() {
      _responsibleDepartment = null;
      _priority = null;
      _paymentType = null;
      _attachments.clear();
      _items
        ..clear()
        ..add(_DownPaymentItem());
    });
  }

  String? _validateRequiredFields() {
    final requiredFields = <MapEntry<String, String>>[
      MapEntry('Vendor Ref No', _vendorRefNoController.text),
      MapEntry('Card Code', _cardCodeController.text),
      MapEntry('Buyer', _buyerController.text),
      MapEntry('Owner', _ownerController.text),
      MapEntry('Responsible Department', _responsibleDepartment ?? ''),
      MapEntry('Priority', _priority ?? ''),
      MapEntry('Payment Type', _paymentType ?? ''),
      MapEntry('AP Down Payment No', _apDownPaymentNoController.text),
      MapEntry('Posting Date', _postingDateController.text),
      MapEntry('Due Date', _dueDateController.text),
    ];

    for (final field in requiredFields) {
      final value = field.value.trim();
      if (_isNoneOrEmpty(value)) {
        return '${field.key} is required';
      }
    }

    final populatedItems = _items
        .where(
          (item) =>
              item.itemCodeController.text.trim().isNotEmpty ||
              item.descriptionController.text.trim().isNotEmpty ||
              item.qtyController.text.trim().isNotEmpty ||
              item.unitPriceController.text.trim().isNotEmpty ||
              item.discountController.text.trim().isNotEmpty ||
              item.taxCodeController.text.trim().isNotEmpty ||
              item.warehouseController.text.trim().isNotEmpty ||
              item.projectController.text.trim().isNotEmpty,
        )
        .toList();

    if (populatedItems.isEmpty) {
      return 'Please add at least one item line';
    }

    for (var index = 0; index < populatedItems.length; index++) {
      final item = populatedItems[index];
      final lineNo = index + 1;
      final lineFields = <MapEntry<String, String>>[
        MapEntry('Item Code', item.itemCodeController.text),
        MapEntry('Description', item.descriptionController.text),
        MapEntry('Qty', item.qtyController.text),
        MapEntry('Unit Price', item.unitPriceController.text),
        MapEntry('Discount %', item.discountController.text),
        MapEntry('Warehouse', item.warehouseController.text),
        MapEntry('Project', item.projectController.text),
      ];

      for (final field in lineFields) {
        if (field.value.trim().isEmpty) {
          return 'Row $lineNo: ${field.key} is required';
        }
      }
    }

    return null;
  }

  Future<void> _onSubmit() async {
    final validationMessage = _validateRequiredFields();
    if (validationMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }

    final linePayload = _items
        .where(
          (item) =>
              item.itemCodeController.text.trim().isNotEmpty ||
              item.descriptionController.text.trim().isNotEmpty ||
              item.qtyController.text.trim().isNotEmpty ||
              item.unitPriceController.text.trim().isNotEmpty ||
              item.discountController.text.trim().isNotEmpty ||
              item.taxCodeController.text.trim().isNotEmpty ||
              item.warehouseController.text.trim().isNotEmpty ||
              item.projectController.text.trim().isNotEmpty,
        )
        .map((item) {
          final line = <String, dynamic>{};
          _putIfNotBlank(
            line,
            'ItemCode',
            _extractCode(item.itemCodeController.text),
          );
          _putIfNotBlank(
            line,
            'ItemDescription',
            item.descriptionController.text.trim(),
          );
          _putIfNumNotNull(line, 'Qty', _tryParseNum(item.qtyController.text));
          _putIfNumNotNull(
            line,
            'UnitPrice',
            _tryParseNum(item.unitPriceController.text),
          );
          _putIfNumNotNull(
            line,
            'Discount',
            _tryParseNum(item.discountController.text),
          );
          _putIfNotBlank(
            line,
            'TaxCode',
            _extractCode(item.taxCodeController.text),
          );
          _putIfNotBlank(
            line,
            'Warehouse',
            _extractCode(item.warehouseController.text),
          );
          _putIfNotBlank(
            line,
            'ProjectCode',
            _extractCode(item.projectController.text),
          );
          return line;
        })
        .toList();

    if (linePayload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item line')),
      );
      return;
    }

    final payload = <String, dynamic>{
      'DocNo': _apDownPaymentNoController.text.trim(),
      'PostingDate': _toApiDate(_postingDateController.text),
      'DueDate': _toApiDate(_dueDateController.text),
      'APKUSERID': UserSession.loggedInEmail,
      'Lines': linePayload,
    };
    _putIfNotBlank(payload, 'VendorRefNo', _vendorRefNoController.text);
    _putIfNotBlank(payload, 'CardCode', _cardCodeController.text.trim());
    _putIfNotBlank(payload, 'CardName', _cardNameController.text.trim());
    _putIfNotBlank(payload, 'Buyer', _buyerController.text.trim());
    _putIfNotBlank(
      payload,
      'ResponsibleDept',
      _normalizedSelectionValue(_responsibleDepartment),
    );
    _putIfNotBlank(payload, 'Owner', _extractCode(_ownerController.text));
    _putIfNotBlank(payload, 'Priority', _normalizedSelectionValue(_priority));
    _putIfNotBlank(
      payload,
      'PaymentType',
      _normalizedSelectionValue(_paymentType),
    );
    _putIfNotBlank(
      payload,
      'ServiceCall',
      _extractCode(_serviceCallController.text),
    );
    _putIfNotBlank(
      payload,
      'SalesOrder',
      _extractCode(_salesOrderController.text),
    );
    _putIfNumNotNull(
      payload,
      'DPMPercent',
      _tryParseNum(_dpmPercentController.text),
    );
    _putIfNotBlank(
      payload,
      'TourStartDate',
      _toApiDate(_tourStartDateController.text),
    );
    _putIfNotBlank(
      payload,
      'TourEndDate',
      _toApiDate(_tourEndDateController.text),
    );
    _putIfNotBlank(payload, 'Remarks', _remarksController.text.trim());
    _putIfNotBlank(
      payload,
      'ImportantNote',
      _importantNoteController.text.trim(),
    );

    try {
      setState(() {
        _isSubmitting = true;
      });

      final uri = _buildNoCacheUri(ApiConstants.createApDownPaymentPath);
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

      if (!mounted) return;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Submit failed (${response.statusCode}). Please check data and try again.',
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AP Down Payment submitted successfully')),
      );
      _resetFormAfterSubmit();
      _fetchNextApDownPaymentNumber();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to submit AP Down Payment')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  DateTime? _parseDate(String value) {
    final text = value.trim();
    final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(text);
    if (match == null) return null;
    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  String _toApiDate(String value) {
    final parsed = _parseDate(value);
    if (parsed == null) {
      return value.trim();
    }
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }

  num? _tryParseNum(String value) {
    final cleaned = value.trim().replaceAll(',', '');
    if (cleaned.isEmpty) return null;
    return num.tryParse(cleaned);
  }

  String _extractCode(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final idx = trimmed.indexOf(' - ');
    if (idx <= 0) return trimmed;
    return trimmed.substring(0, idx).trim();
  }
}

class _DownPaymentItem {
  _DownPaymentItem();

  final itemCodeController = TextEditingController();
  final descriptionController = TextEditingController();
  final qtyController = TextEditingController();
  final unitPriceController = TextEditingController();
  final discountController = TextEditingController();
  final taxCodeController = TextEditingController();
  final warehouseController = TextEditingController();
  final projectController = TextEditingController();

  void dispose() {
    itemCodeController.dispose();
    descriptionController.dispose();
    qtyController.dispose();
    unitPriceController.dispose();
    discountController.dispose();
    taxCodeController.dispose();
    warehouseController.dispose();
    projectController.dispose();
  }
}

class _ItemOption {
  const _ItemOption({required this.code, required this.description});

  final String code;
  final String description;

  String get displayLabel =>
      description.trim().isEmpty ? code : '$code - $description';
}

class _VendorOption {
  const _VendorOption({required this.cardCode, required this.cardName});

  final String cardCode;
  final String cardName;

  String get displayLabel =>
      cardName.trim().isEmpty ? cardCode : '$cardCode - $cardName';
}
