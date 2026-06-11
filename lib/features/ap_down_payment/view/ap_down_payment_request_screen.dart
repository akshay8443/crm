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
  const ApDownPaymentRequestScreen({super.key, this.initialDocNo});

  final String? initialDocNo;

  @override
  State<ApDownPaymentRequestScreen> createState() =>
      _ApDownPaymentRequestScreenState();
}

class _ApDownPaymentRequestScreenState
    extends State<ApDownPaymentRequestScreen> {
  static const int _attachmentImageQuality = 70;
  static const double _attachmentMaxWidth = 1920;
  static const double _attachmentMaxHeight = 1920;
  static const String _noneOption = 'None';
  final ImagePicker _imagePicker = ImagePicker();
  final List<_DownPaymentItem> _items = [_DownPaymentItem()];
  final List<XFile> _attachments = [];
  List<Map<String, dynamic>> _existingAttachments = const [];

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
  List<_BuyerOption> _buyerOptions = const [];
  List<String> _ownerOptions = const [];
  List<String> _departmentOptions = const [];
  List<String> _salesOrderOptions = const [];
  List<String> _serviceCallOptions = const [];
  List<_ItemOption> _itemOptions = const [];
  List<String> _taxCodeOptions = const [];
  List<String> _warehouseOptions = const [];
  List<String> _projectOptions = const [];
  bool _isSubmitting = false;
  bool _isLoadingExistingRequest = false;

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
    'OthersExceptTour',
    'EmpAdvNoTour',
    'EmpClrNoTour',
  ];

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
    final initialDocNo = widget.initialDocNo?.trim() ?? '';
    if (initialDocNo.isNotEmpty) {
      _apDownPaymentNoController.text = initialDocNo;
      _fetchApDownPaymentDetails(initialDocNo);
      _fetchApDownPaymentAttachments(initialDocNo);
    } else {
      _postingDateController.text = _formatDate(now);
      _dueDateController.text = _formatDate(now);
      _fetchNextApDownPaymentNumber();
    }
    _fetchApDownPaymentVendors();
    _fetchApDownPaymentBuyers();
    _fetchApDownPaymentOwners();
    _fetchApDownPaymentDepartments();
    _fetchApDownPaymentSalesOrders();
    _fetchApDownPaymentServiceCalls();
    _fetchApDownPaymentItems();
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
        title: Text(
          _isViewDetailsMode
              ? 'AP Down Payment Details'
              : 'AP Down Payment Request',
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
        child: _isLoadingExistingRequest
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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

  Uri _buildNoCacheUriWithQuery(String path, Map<String, String> query) {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final params = <String, String>{
      ...uri.queryParameters,
      ...query,
      '_ts': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    return uri.replace(queryParameters: params);
  }

  Future<void> _fetchApDownPaymentDetails(String docNo) async {
    final normalizedDocNo = docNo.trim();
    if (normalizedDocNo.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingExistingRequest = true;
    });

    try {
      final uri = _buildNoCacheUriWithQuery(
        ApiConstants.getSpecificApDownPaymentPath,
        <String, String>{'DocNo': normalizedDocNo},
      );
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 25));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get specific AP down payment failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from AP down payment details API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid AP down payment detail response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid AP down payment detail response format');
      }

      final detailRows = rows.whereType<Map<String, dynamic>>().toList();
      if (detailRows.isEmpty) {
        throw Exception('AP down payment detail not found');
      }

      if (!mounted) return;
      setState(() {
        _applyApDownPaymentDetails(
          _normalizedApDownPaymentDetailRows(detailRows),
        );
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load AP Down Payment details')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingExistingRequest = false;
        });
      }
    }
  }

  Future<void> _fetchApDownPaymentAttachments(String docNo) async {
    final normalizedDocNo = docNo.trim();
    if (normalizedDocNo.isEmpty) {
      return;
    }

    final candidateQueries = <Map<String, String>>[
      <String, String>{'docNo': normalizedDocNo},
      <String, String>{'DocNo': normalizedDocNo},
      <String, String>{'documentNo': normalizedDocNo},
      <String, String>{'DocumentNo': normalizedDocNo},
    ];

    List<Map<String, dynamic>> resolvedAttachments = const [];
    var hasSuccessfulResponse = false;

    try {
      for (final query in candidateQueries) {
        final uri = _buildNoCacheUriWithQuery(
          ApiConstants.getAttachmentsPath,
          query,
        );
        final response = await http
            .get(uri, headers: _getHeaders())
            .timeout(const Duration(seconds: 20));

        if (response.statusCode < 200 || response.statusCode >= 300) {
          continue;
        }

        hasSuccessfulResponse = true;
        if (response.body.trim().isEmpty) {
          resolvedAttachments = const [];
          continue;
        }

        final dynamic decoded = jsonDecode(response.body);
        final rows = _extractAttachmentRows(decoded);
        if (rows.isNotEmpty) {
          resolvedAttachments = _filterAttachmentsForDocNo(
            rows,
            normalizedDocNo,
          );
          if (resolvedAttachments.isNotEmpty) {
            break;
          }
        } else {
          resolvedAttachments = const [];
        }
      }

      if (!mounted || !hasSuccessfulResponse) {
        return;
      }

      setState(() {
        _existingAttachments = resolvedAttachments;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _existingAttachments = const [];
      });
    }
  }

  void _applyApDownPaymentDetails(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) {
      return;
    }

    _apDownPaymentNoController.text = _readFirstNonEmptyValue(
      rows,
      <String>['DocNo'],
    );
    _vendorRefNoController.text = _readFirstNonEmptyValue(rows, <String>[
      'VendorRefNo',
      'VendorReferenceNo',
    ]);
    _cardCodeController.text = _readFirstNonEmptyValue(rows, <String>[
      'CardCode',
      'BPCode',
      'VendorCode',
    ]);
    _cardNameController.text = _readFirstNonEmptyValue(rows, <String>[
      'CardName',
      'BPName',
      'VendorName',
    ]);
    _buyerController.text = _resolveBuyerDisplayValue(rows);
    _ownerController.text = _resolveOwnerDisplayValue(rows);
    _serviceCallController.text = _readFirstNonEmptyValue(rows, <String>[
      'ServiceCall',
      'ServiceCallNo',
    ]);
    _salesOrderController.text = _readFirstNonEmptyValue(rows, <String>[
      'SalesOrder',
      'SalesOrderNo',
    ]);
    _tourStartDateController.text = _formatDisplayDate(
      _readFirstNonEmptyValue(rows, <String>[
        'TourStartDate',
        'TourFromDate',
        'StartDate',
      ]),
    );
    _tourEndDateController.text = _formatDisplayDate(
      _readFirstNonEmptyValue(rows, <String>[
        'TourEndDate',
        'TourToDate',
        'EndDate',
      ]),
    );

    _responsibleDepartment = _readFirstNonEmptyValue(rows, <String>[
      'ResponsibleDept',
      'ResponsibleDepartment',
    ]);
    _priority = _readFirstNonEmptyValue(rows, <String>['Priority']);
    _paymentType = _readFirstNonEmptyValue(rows, <String>['PaymentType']);
    _dpmPercentController.text = _readFirstNonEmptyValue(rows, <String>[
      'DPMPercent',
      'DpmPercent',
    ]);
    _remarksController.text = _readFirstNonEmptyValue(
      rows,
      <String>['Remarks'],
    );
    _importantNoteController.text = _readFirstNonEmptyValue(rows, <String>[
      'ImportantNote',
    ]);
    _postingDateController.text = _formatDisplayDate(
      _readFirstNonEmptyValue(rows, <String>['PostingDate']),
    );
    _dueDateController.text = _formatDisplayDate(
      _readFirstNonEmptyValue(rows, <String>['DueDate']),
    );

    for (final item in _items) {
      item.dispose();
    }
    _items
      ..clear()
      ..addAll(
        rows.map((row) {
          final item = _DownPaymentItem();
          item.itemCodeController.text = _readValue(row, <String>['ItemCode']);
          item.descriptionController.text = _readValue(row, <String>[
            'ItemDescription',
            'Description',
          ]);
          item.qtyController.text = _readValue(row, <String>[
            'Quantity',
            'Qty',
          ]);
          item.unitPriceController.text = _readValue(row, <String>[
            'UnitPrice',
          ]);
          item.discountController.text = _readValue(row, <String>[
            'DiscountPercent',
            'Discount',
          ]);
          item.taxCodeController.text = _readValue(row, <String>['TaxCode']);
          item.warehouseController.text = _readValue(row, <String>[
            'Warehouse',
          ]);
          item.projectController.text = _readValue(row, <String>[
            'ProjectCode',
            'Project',
          ]);
          return item;
        }),
      );

    if (_items.isEmpty) {
      _items.add(_DownPaymentItem());
    }
  }

  List<Map<String, dynamic>> _normalizedApDownPaymentDetailRows(
    List<Map<String, dynamic>> rows,
  ) {
    final seen = <String>{};
    final normalized = <Map<String, dynamic>>[];

    for (final row in rows) {
      final lineIdentity = _readValue(row, const <String>[
        'LineId',
        'LineNum',
        'LineNo',
        'RowNo',
      ]);
      final fallbackIdentity = <String>[
        _readValue(row, const <String>['ItemCode']).toLowerCase(),
        _readValue(row, const <String>['ItemDescription']).toLowerCase(),
        _readValue(row, const <String>['Quantity', 'Qty']).toLowerCase(),
        _readValue(row, const <String>['UnitPrice']).toLowerCase(),
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

  List<Map<String, dynamic>> _extractAttachmentRows(dynamic decoded) {
    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList();
    }
    if (decoded is Map<String, dynamic>) {
      final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
      if (nested is List) {
        return nested.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  List<Map<String, dynamic>> _filterAttachmentsForDocNo(
    List<Map<String, dynamic>> rows,
    String docNo,
  ) {
    final normalizedDocNo = docNo.trim().toLowerCase();
    final filtered = rows.where((row) {
      final attachmentDocNo = _readValue(row, const <String>[
        'DocNo',
        'docNo',
        'DocumentNo',
        'documentNo',
        'RefNo',
        'ReferenceNo',
      ]).trim().toLowerCase();

      if (attachmentDocNo.isEmpty) {
        return true;
      }
      return attachmentDocNo == normalizedDocNo;
    }).toList();

    return filtered;
  }

  String _formatDisplayDate(String value) {
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) {
      return value.trim();
    }
    return _formatDate(parsed);
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
          _buyerField(),
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
    final isReadOnly = _isViewDetailsMode;
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
          if (!isReadOnly)
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
    final isReadOnly = _isViewDetailsMode;
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
              readOnly: isReadOnly,
              decoration: inputDecoration,
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 140,
            child: TextField(
              controller: item.unitPriceController,
              readOnly: isReadOnly,
              decoration: inputDecoration,
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 130,
            child: TextField(
              controller: item.discountController,
              readOnly: isReadOnly,
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
            child: isReadOnly
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: () => _removeItemRow(item),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFC62828),
                    ),
                    tooltip: 'Delete row',
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsCard() {
    final existingAttachments = _existingAttachments;
    final hasLocalAttachments = _attachments.isNotEmpty;
    final hasExistingAttachments = existingAttachments.isNotEmpty;

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
                Text(
                  _isViewDetailsMode
                      ? 'Uploaded attachments'
                      : 'Click here to upload files',
                  style: TextStyle(
                    color: _isViewDetailsMode
                        ? const Color(0xFF6A7685)
                        : const Color(0xFF2D66C6),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_isViewDetailsMode && !hasExistingAttachments) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'No attachments found',
                    style: TextStyle(
                      color: Color(0xFF6A7685),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (!_isViewDetailsMode && hasLocalAttachments) ...[
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
                if (_isViewDetailsMode && hasExistingAttachments) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${existingAttachments.length} file(s) found',
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
                      itemCount: existingAttachments.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final attachment = existingAttachments[index];
                        final imageUrl = _attachmentUrl(attachment);
                        final fileName = _attachmentName(attachment);

                        return GestureDetector(
                          onTap: imageUrl == null
                              ? null
                              : () => _openNetworkAttachmentPreview(
                                    imageUrl,
                                    fileName,
                                  ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 96,
                              height: 96,
                              child: imageUrl == null
                                  ? _attachmentPlaceholder(
                                      Icons.image_not_supported_outlined,
                                    )
                                  : Image.network(
                                      imageUrl,
                                      headers: const <String, String>{
                                        'Authorization':
                                            ApiConstants.basicAuthorization,
                                      },
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return _attachmentPlaceholder(
                                          Icons.broken_image_outlined,
                                        );
                                      },
                                    ),
                            ),
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
        suffixIcon: _isViewDetailsMode
            ? null
            : const Icon(Icons.arrow_drop_down),
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
      onTap: _isViewDetailsMode
          ? null
          : () async {
        final selected = await _openVendorPicker();
        if (!mounted || selected == null) return;
        setState(() {
          _cardCodeController.text = selected.cardCode;
          _cardNameController.text = selected.cardName;
        });
      },
    );
  }

  Widget _buyerField() {
    return TextField(
      controller: _buyerController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Buyer',
        filled: true,
        fillColor: const Color(0xFFFBFBFC),
        suffixIcon: _isViewDetailsMode
            ? null
            : const Icon(Icons.arrow_drop_down),
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
      onTap: _isViewDetailsMode
          ? null
          : () async {
              final selected = await _openBuyerPicker();
              if (!mounted || selected == null) return;
              setState(() {
                _buyerController.text = selected.displayLabel;
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

      final buyersByCode = <String, _BuyerOption>{};
      final buyersByLabel = <String, _BuyerOption>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) continue;

        final firstName = _readValue(row, <String>[
          'FirstName',
          'firstName',
        ]);
        final middleName = _readValue(row, <String>[
          'MiddleName',
          'middleName',
        ]);
        final lastName = _readValue(row, <String>[
          'LastName',
          'lastName',
        ]);
        final joinedName = <String>[
          if (firstName.isNotEmpty) firstName,
          if (middleName.isNotEmpty) middleName,
          if (lastName.isNotEmpty) lastName,
        ].join(' ');
        final name = joinedName.isNotEmpty
            ? joinedName
            : _readValue(row, <String>[
                'SalesEmployeeName',
                'BuyerName',
                'EmployeeName',
                'Employee',
                'FullName',
                'Name',
              ]);
        final code = _readValue(row, <String>[
          'SalesEmployeeCode',
          'SalesEmployeeID',
          'EmployeeCode',
          'EmpCode',
          'EmployeeId',
          'EmployeeNo',
          'EmpNo',
          'Code',
        ]);

        final normalizedCode = code.trim();
        final normalizedName = name.trim();
        if (normalizedCode.isEmpty && normalizedName.isEmpty) {
          continue;
        }

        final option = _BuyerOption(
          code: normalizedCode,
          name: normalizedName,
        );
        if (normalizedCode.isNotEmpty) {
          buyersByCode[normalizedCode] = option;
        } else {
          buyersByLabel[option.displayLabel.toLowerCase()] = option;
        }
      }

      final options = <_BuyerOption>[
        ...buyersByCode.values,
        ...buyersByLabel.values,
      ]..sort((a, b) => a.displayLabel.compareTo(b.displayLabel));

      if (!mounted) return;
      setState(() {
        _buyerOptions = options;
        final matchedBuyer = _matchBuyerOption(rawValue: _buyerController.text);
        if (matchedBuyer != null && matchedBuyer.displayLabel.trim().isNotEmpty) {
          _buyerController.text = matchedBuyer.displayLabel;
        }
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
      if (normalized.startsWith('3rd fl -') ||
          normalized == '3rd fl' ||
          normalized.contains('3rd floor-scm') ||
          normalized.contains('3rd floor scm')) {
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
      final directValue = row[key];
      if (directValue != null) {
        final text = directValue.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }

      final normalizedTargetKey = _normalizeApiKey(key);
      for (final entry in row.entries) {
        if (_normalizeApiKey(entry.key) != normalizedTargetKey) {
          continue;
        }

        final text = entry.value?.toString().trim() ?? '';
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return '';
  }

  String _readFirstNonEmptyValue(
    List<Map<String, dynamic>> rows,
    List<String> keys,
  ) {
    for (final row in rows) {
      final value = _readValue(row, keys);
      if (value.trim().isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  String _normalizeApiKey(String key) {
    return key.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toLowerCase();
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

      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: _attachmentImageQuality,
        maxWidth: _attachmentMaxWidth,
        maxHeight: _attachmentMaxHeight,
      );
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
      final files = await _imagePicker.pickMultiImage(
        imageQuality: _attachmentImageQuality,
        maxWidth: _attachmentMaxWidth,
        maxHeight: _attachmentMaxHeight,
      );
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

  Future<void> _openNetworkAttachmentPreview(
    String imageUrl,
    String fileName,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: 420,
              height: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: InteractiveViewer(
                      child: Image.network(
                        imageUrl,
                        headers: const <String, String>{
                          'Authorization': ApiConstants.basicAuthorization,
                        },
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return _attachmentPlaceholder(
                            Icons.broken_image_outlined,
                          );
                        },
                      ),
                    ),
                  ),
                ],
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

  Widget _attachmentPlaceholder(IconData icon) {
    return ColoredBox(
      color: const Color(0xFFE5E7EB),
      child: Center(child: Icon(icon, color: const Color(0xFF6A7685))),
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
      readOnly: readOnly || _isViewDetailsMode,
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
    final isReadOnly = _isViewDetailsMode;
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'dd/mm/yyyy',
        suffixIcon: isReadOnly
            ? const Icon(Icons.calendar_today_outlined, size: 18)
            : Row(
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
      onTap: isReadOnly
          ? null
          : () async {
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
        suffixIcon: _isViewDetailsMode
            ? null
            : const Icon(Icons.arrow_drop_down),
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
      onTap: _isViewDetailsMode
          ? null
          : () async {
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

  Future<_BuyerOption?> _openBuyerPicker() async {
    return showModalBottomSheet<_BuyerOption>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        var query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _buyerOptions.where((option) {
              final q = query.trim().toLowerCase();
              if (q.isEmpty) return true;
              return option.displayLabel.toLowerCase().contains(q) ||
                  option.code.toLowerCase().contains(q) ||
                  option.name.toLowerCase().contains(q);
            }).toList(growable: false);

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
                          hintText: 'Search buyer code / buyer name',
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
                            ? const Center(child: Text('No buyer found'))
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
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

  Widget _tableSelectionField({
    required TextEditingController controller,
    required List<String> options,
    required String hintText,
    required String searchHint,
    required ValueChanged<String?> onSelected,
  }) {
    return InkWell(
      onTap: _isViewDetailsMode
          ? null
          : () async {
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
          suffixIcon: _isViewDetailsMode
              ? null
              : const Icon(Icons.arrow_drop_down),
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
      onTap: _isViewDetailsMode
          ? null
          : () async {
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
          suffixIcon: _isViewDetailsMode
              ? null
              : const Icon(Icons.arrow_drop_down),
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
      onTap: _isViewDetailsMode
          ? null
          : () async {
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
          suffixIcon: _isViewDetailsMode
              ? null
              : const Icon(Icons.arrow_drop_down),
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
    _putIfNotBlank(payload, 'BPCode', _cardCodeController.text.trim());
    _putIfNotBlank(payload, 'BPName', _cardNameController.text.trim());
    _putIfNotBlank(payload, 'Buyer', _selectedBuyerCode());
    _putIfNotBlank(payload, 'BuyerName', _selectedBuyerName());
    _putIfNotBlank(payload, 'SalesEmployeeCode', _selectedBuyerCode());
    _putIfNotBlank(payload, 'SalesEmployeeName', _selectedBuyerName());
    _putIfNotBlank(
      payload,
      'ResponsibleDept',
      _normalizedSelectionValue(_responsibleDepartment),
    );
    _putIfNotBlank(payload, 'Owner', _selectedOwnerDisplayValue());
    _putIfNotBlank(payload, 'OwnerCode', _selectedOwnerCode());
    _putIfNotBlank(payload, 'OwnerName', _selectedOwnerName());
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

      var docNo = _apDownPaymentNoController.text.trim();
      var successMessage = 'AP Down Payment submitted successfully';
      final responseBody = response.body.trim();
      if (responseBody.isNotEmpty) {
        try {
          final decoded = jsonDecode(responseBody);
          if (decoded is Map<String, dynamic>) {
            final serverMessage = decoded['message']?.toString().trim() ?? '';
            if (serverMessage.isNotEmpty) {
              successMessage = serverMessage;
            }

            final serverDocNo = _readValue(decoded, <String>[
              'DocNo',
              'DocNum',
              'APDownPaymentNo',
              'APdownPaymentNo',
              'DocumentNo',
            ]);
            if (serverDocNo.isNotEmpty) {
              docNo = serverDocNo;
              _apDownPaymentNoController.text = serverDocNo;
            }
          }
        } catch (_) {
          // Ignore non-JSON response bodies; status code already indicates success.
        }
      }

      await _uploadApDownPaymentAttachments(docNo);

      if (docNo.isNotEmpty &&
          !successMessage.toLowerCase().contains(docNo.toLowerCase())) {
        successMessage = '$successMessage\nAP Down Payment No: $docNo';
      }

      await _showSubmitSuccessDialog(successMessage);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to submit AP Down Payment: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _uploadApDownPaymentAttachments(String docNo) async {
    final normalizedDocNo = docNo.trim();
    if (_attachments.isEmpty || normalizedDocNo.isEmpty) {
      return;
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.uploadApDownPaymentFilePath}',
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

    Future<http.StreamedResponse> sendWithFieldName(
      String fieldName,
      Map<String, String> fieldProfile,
    ) async {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(<String, String>{
          'Authorization': ApiConstants.basicAuthorization,
          'Accept': 'application/json',
        })
        ..fields.addAll(fieldProfile);
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

    final fieldNames = <String>['file', 'files', 'File', 'Image'];
    final fieldProfiles = <Map<String, String>>[
      <String, String>{'DocNo': normalizedDocNo},
      <String, String>{'docNo': normalizedDocNo},
      <String, String>{'DocumentNo': normalizedDocNo},
      <String, String>{'APDownPaymentNo': normalizedDocNo},
      <String, String>{'ApDownPaymentNo': normalizedDocNo},
    ];
    int? lastStatusCode;
    String lastResponseBody = '';
    Object? lastError;

    for (final fieldProfile in fieldProfiles) {
      for (final fieldName in fieldNames) {
        try {
          final streamedResponse = await sendWithFieldName(
            fieldName,
            fieldProfile,
          );
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

  Future<void> _showSubmitSuccessDialog(String message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
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

  String _attachmentName(Map<String, dynamic> item) {
    final value = _readValue(item, const <String>[
      'FileName',
      'fileName',
      'Name',
      'name',
    ]);
    return value.isEmpty ? 'Attachment' : value;
  }

  String? _attachmentUrl(Map<String, dynamic> item) {
    final rawPath = _readValue(item, const <String>[
      'FilePath',
      'filePath',
      'Path',
      'path',
      'Url',
      'url',
      'ImageUrl',
      'imageUrl',
    ]);
    if (rawPath.isEmpty) {
      return null;
    }

    final sanitizedPath = rawPath
        .replaceAll('\\', '/')
        .replaceAll(' ', '%20');
    if (sanitizedPath.startsWith('http://') ||
        sanitizedPath.startsWith('https://')) {
      return sanitizedPath;
    }

    final normalizedPath = sanitizedPath.startsWith('/')
        ? sanitizedPath
        : '/$sanitizedPath';
    return '${ApiConstants.baseUrl}$normalizedPath';
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

  String _extractDisplayName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final idx = trimmed.indexOf(' - ');
    if (idx <= 0) return trimmed;
    return trimmed.substring(idx + 3).trim();
  }

  String _resolveBuyerDisplayValue(List<Map<String, dynamic>> rows) {
    final buyerCode = _readFirstNonEmptyValue(rows, <String>[
      'Buyer',
      'BuyerCode',
      'SalesEmployeeCode',
      'SalesEmployeeID',
      'EmployeeCode',
      'Code',
    ]);
    final buyerName = _readFirstNonEmptyValue(rows, <String>[
      'BuyerName',
      'SalesEmployeeName',
      'EmployeeName',
      'FullName',
      'Name',
    ]);

    final matchedOption = _matchBuyerOption(
      code: buyerCode,
      name: buyerName,
      rawValue: buyerCode,
    );
    if (matchedOption != null) {
      return matchedOption.displayLabel;
    }

    if (buyerCode.isNotEmpty && buyerName.isNotEmpty) {
      return '$buyerCode - $buyerName';
    }
    if (buyerName.isNotEmpty) {
      return buyerName;
    }
    return buyerCode;
  }

  _BuyerOption? _matchBuyerOption({
    String? code,
    String? name,
    String? rawValue,
  }) {
    final normalizedCode = code?.trim() ?? '';
    final normalizedName = name?.trim() ?? '';
    final normalizedRaw = rawValue?.trim() ?? '';

    for (final option in _buyerOptions) {
      if (normalizedCode.isNotEmpty && option.code == normalizedCode) {
        return option;
      }
      if (normalizedName.isNotEmpty && option.name == normalizedName) {
        return option;
      }
      if (normalizedRaw.isNotEmpty &&
          (option.displayLabel == normalizedRaw ||
              option.code == normalizedRaw ||
              option.name == normalizedRaw)) {
        return option;
      }
    }

    if (normalizedCode.isEmpty && normalizedName.isEmpty) {
      return null;
    }
    return _BuyerOption(code: normalizedCode, name: normalizedName);
  }

  String _selectedBuyerCode() {
    final selected = _matchBuyerOption(rawValue: _buyerController.text);
    if (selected == null) {
      return _extractCode(_buyerController.text);
    }
    return selected.code.isNotEmpty
        ? selected.code
        : _extractCode(selected.displayLabel);
  }

  String _selectedBuyerName() {
    final selected = _matchBuyerOption(rawValue: _buyerController.text);
    if (selected == null) {
      return _extractDisplayName(_buyerController.text);
    }
    if (selected.name.isNotEmpty) {
      return selected.name;
    }
    return _extractDisplayName(selected.displayLabel);
  }

  String _resolveOwnerDisplayValue(List<Map<String, dynamic>> rows) {
    final ownerCode = _readFirstNonEmptyValue(rows, <String>[
      'OwnerCode',
      'Owner',
      'SalesEmployeeCode',
      'EmployeeCode',
      'Code',
    ]);
    final ownerName = _readFirstNonEmptyValue(rows, <String>[
      'OwnerName',
      'SalesEmployeeName',
      'EmployeeName',
      'FullName',
      'Name',
    ]);

    if (ownerCode.isNotEmpty && ownerName.isNotEmpty) {
      return '$ownerCode - $ownerName';
    }
    if (ownerName.isNotEmpty) {
      return ownerName;
    }
    return ownerCode;
  }

  String _selectedOwnerCode() {
    return _extractCode(_ownerController.text);
  }

  String _selectedOwnerDisplayValue() {
    return _ownerController.text.trim();
  }

  String _selectedOwnerName() {
    return _extractDisplayName(_ownerController.text);
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

class _BuyerOption {
  const _BuyerOption({required this.code, required this.name});

  final String code;
  final String name;

  String get displayLabel => name.trim().isEmpty
      ? code
      : code.trim().isEmpty
      ? name
      : '$code - $name';
}
