import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import 'ap_down_payment_request_screen.dart';

class ApDownPaymentReportScreen extends StatefulWidget {
  const ApDownPaymentReportScreen({super.key});

  @override
  State<ApDownPaymentReportScreen> createState() =>
      _ApDownPaymentReportScreenState();
}

class _ApDownPaymentReportScreenState extends State<ApDownPaymentReportScreen> {
  final TextEditingController _docNoFilterController = TextEditingController();
  final TextEditingController _vendorFilterController = TextEditingController();
  final TextEditingController _postingDateFilterController =
      TextEditingController();

  String _priorityFilter = '';
  String _departmentFilter = '';
  bool _isLoading = false;

  List<_ApDownPaymentRow> _rows = const [];

  static const List<String> _candidateReportPaths = <String>[
    '/api/GetAllAPDownPayment',
    '/api/GetAllAPdownPayment',
    '/api/GetAllAPDownPaymentRequest',
    '/api/GetAPDownPaymentReport',
    '/api/APDownPaymentReport',
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllApDownPayments();
  }

  @override
  void dispose() {
    _docNoFilterController.dispose();
    _vendorFilterController.dispose();
    _postingDateFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRows = _rows.where(_matchesFilters).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(title: const Text('AP Down Payment Report')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;

            return Column(
              children: [
                _buildHeader(),
                _buildFilters(isMobile),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : isMobile
                      ? _buildMobileList(filteredRows)
                      : _buildTableView(filteredRows),
                ),
              ],
            );
          },
        ),
      ),
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

  Future<void> _fetchAllApDownPayments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<dynamic>? rows;

      for (final path in _candidateReportPaths) {
        try {
          final uri = _buildNoCacheUri(path);
          final response = await http
              .get(uri, headers: _getHeaders())
              .timeout(const Duration(seconds: 25));

          if (response.statusCode < 200 || response.statusCode >= 300) {
            continue;
          }
          if (response.body.isEmpty) {
            continue;
          }

          final dynamic decoded = jsonDecode(response.body);
          if (decoded is List) {
            rows = decoded;
            break;
          }
          if (decoded is Map<String, dynamic>) {
            final nested =
                decoded['data'] ?? decoded['result'] ?? decoded['items'];
            if (nested is List) {
              rows = nested;
              break;
            }
          }
        } catch (_) {
          continue;
        }
      }

      if (rows == null) {
        throw Exception('AP Down Payment report API not available');
      }

      final mappedRows = <_ApDownPaymentRow>[];
      final seenDocNos = <String>{};

      for (final row in rows) {
        if (row is! Map<String, dynamic>) continue;

        final docNo = _readValue(row, const <String>[
          'DocNo',
          'DocNum',
          'APDownPaymentNo',
          'APdownPaymentNo',
          'DocumentNo',
        ]);

        if (docNo.isEmpty || !seenDocNos.add(docNo.toLowerCase())) {
          continue;
        }

        mappedRows.add(
          _ApDownPaymentRow(
            docNo: docNo,
            vendor: _readValue(row, const <String>[
              'CardName',
              'VendorName',
              'BPName',
              'BusinessPartner',
              'CardCode',
            ]),
            postingDate: _formatApiDate(
              _readValue(row, const <String>[
                'PostingDate',
                'DocDate',
                'DocumentDate',
                'Date',
              ]),
            ),
            priority: _readValue(row, const <String>['Priority']),
            department: _readValue(row, const <String>[
              'ResponsibleDepartment',
              'ResponsibleDept',
              'Department',
            ]),
            owner: _readValue(row, const <String>[
              'Owner',
              'OwnerName',
              'Buyer',
              'BuyerName',
            ]),
          ),
        );
      }

      mappedRows.sort(_compareRowsDescending);

      if (!mounted) return;
      setState(() {
        _rows = mappedRows;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load AP Down Payment list')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _readValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final directValue = json[key];
      if (directValue != null) {
        final normalized = directValue.toString().trim();
        if (normalized.isNotEmpty) {
          return normalized;
        }
      }

      final normalizedTargetKey = _normalizeApiKey(key);
      for (final entry in json.entries) {
        if (_normalizeApiKey(entry.key) != normalizedTargetKey) {
          continue;
        }

        final normalized = entry.value?.toString().trim() ?? '';
        if (normalized.isNotEmpty) {
          return normalized;
        }
      }
    }
    return '';
  }

  String _normalizeApiKey(String key) {
    return key.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toLowerCase();
  }

  String _formatApiDate(String value) {
    final text = value.trim();
    if (text.isEmpty) return '';

    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;

    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final day = parsed.day.toString().padLeft(2, '0');
    final month = months[parsed.month - 1];
    return '$day-$month-${parsed.year}';
  }

  int _compareRowsDescending(_ApDownPaymentRow a, _ApDownPaymentRow b) {
    final dateCompare = _parseDisplayDate(
      b.postingDate,
    ).compareTo(_parseDisplayDate(a.postingDate));
    if (dateCompare != 0) {
      return dateCompare;
    }

    final docNoCompare = _extractTrailingNumber(
      b.docNo,
    ).compareTo(_extractTrailingNumber(a.docNo));
    if (docNoCompare != 0) {
      return docNoCompare;
    }

    return b.docNo.toLowerCase().compareTo(a.docNo.toLowerCase());
  }

  DateTime _parseDisplayDate(String value) {
    final text = value.trim();
    if (text.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);

    final parsed = DateTime.tryParse(text);
    if (parsed != null) return parsed;

    final match = RegExp(r'^(\d{2})-([A-Za-z]{3})-(\d{4})$').firstMatch(text);
    if (match == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    const months = <String, int>{
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };

    final day = int.tryParse(match.group(1)!);
    final month = months[match.group(2)!.toLowerCase()];
    final year = int.tryParse(match.group(3)!);

    if (day == null || month == null || year == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime(year, month, day);
  }

  int _extractTrailingNumber(String value) {
    final match = RegExp(r'(\d+)(?!.*\d)').firstMatch(value);
    return int.tryParse(match?.group(1) ?? '') ?? -1;
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
    );
  }

  Widget _buildFilters(bool isMobile) {
    final filterFields = [
      _filterTextField(controller: _docNoFilterController, hint: 'Doc No'),
      _filterTextField(controller: _vendorFilterController, hint: 'Vendor'),
      _filterTextField(
        controller: _postingDateFilterController,
        hint: 'Posting Date',
      ),
      _filterTextField(hint: 'Priority', onChanged: (value) {
        setState(() => _priorityFilter = value);
      }),
      _filterTextField(hint: 'Department', onChanged: (value) {
        setState(() => _departmentFilter = value);
      }),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF3F51B5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: isMobile
          ? Column(
              children: [
                for (int i = 0; i < filterFields.length; i++) ...[
                  filterFields[i],
                  if (i != filterFields.length - 1) const SizedBox(height: 8),
                ],
              ],
            )
          : Row(
              children: [
                for (int i = 0; i < filterFields.length; i++) ...[
                  Expanded(child: filterFields[i]),
                  if (i != filterFields.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
    );
  }

  Widget _filterTextField({
    TextEditingController? controller,
    required String hint,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged ?? (_) => setState(() {}),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildMobileList(List<_ApDownPaymentRow> rows) {
    if (rows.isEmpty) {
      return const Center(child: Text('No AP Down Payment found'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: rows.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final row = rows[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE3E8F2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _mobileRow('Doc No', row.docNo),
              _mobileRow('Vendor', row.vendor.isEmpty ? '-' : row.vendor),
              _mobileRow('Posting Date', row.postingDate),
              _mobileRow('Priority', row.priority.isEmpty ? '-' : row.priority),
              _mobileRow(
                'Department',
                row.department.isEmpty ? '-' : row.department,
              ),
              _mobileRow('Owner', row.owner.isEmpty ? '-' : row.owner),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => _openDetails(row.docNo),
                  child: const Text('View'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mobileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF4C4F59),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF1E2433)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(List<_ApDownPaymentRow> rows) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 1100),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFF3F51B5)),
            columns: const [
              DataColumn(
                label: Text(
                  'Doc No',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Vendor',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Posting Date',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Priority',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Department',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Owner',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Action',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            rows: rows
                .map(
                  (row) => DataRow(
                    cells: [
                      DataCell(Text(row.docNo)),
                      DataCell(Text(row.vendor)),
                      DataCell(Text(row.postingDate)),
                      DataCell(Text(row.priority)),
                      DataCell(Text(row.department)),
                      DataCell(Text(row.owner)),
                      DataCell(
                        TextButton(
                          onPressed: () => _openDetails(row.docNo),
                          child: const Text('View'),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  bool _matchesFilters(_ApDownPaymentRow row) {
    final docNoFilter = _docNoFilterController.text.trim().toLowerCase();
    final vendorFilter = _vendorFilterController.text.trim().toLowerCase();
    final postingDateFilter = _postingDateFilterController.text
        .trim()
        .toLowerCase();
    final priorityFilter = _priorityFilter.trim().toLowerCase();
    final departmentFilter = _departmentFilter.trim().toLowerCase();

    final matchesDocNo =
        docNoFilter.isEmpty || row.docNo.toLowerCase().contains(docNoFilter);
    final matchesVendor =
        vendorFilter.isEmpty || row.vendor.toLowerCase().contains(vendorFilter);
    final matchesPostingDate =
        postingDateFilter.isEmpty ||
        row.postingDate.toLowerCase().contains(postingDateFilter);
    final matchesPriority =
        priorityFilter.isEmpty ||
        row.priority.toLowerCase().contains(priorityFilter);
    final matchesDepartment =
        departmentFilter.isEmpty ||
        row.department.toLowerCase().contains(departmentFilter);

    return matchesDocNo &&
        matchesVendor &&
        matchesPostingDate &&
        matchesPriority &&
        matchesDepartment;
  }

  void _openDetails(String docNo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApDownPaymentRequestScreen(initialDocNo: docNo),
      ),
    );
  }
}

class _ApDownPaymentRow {
  const _ApDownPaymentRow({
    required this.docNo,
    required this.vendor,
    required this.postingDate,
    required this.priority,
    required this.department,
    required this.owner,
  });

  final String docNo;
  final String vendor;
  final String postingDate;
  final String priority;
  final String department;
  final String owner;
}
