import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';

class GoodsIssueReportScreen extends StatefulWidget {
  const GoodsIssueReportScreen({super.key});

  @override
  State<GoodsIssueReportScreen> createState() => _GoodsIssueReportScreenState();
}

class _GoodsIssueReportScreenState extends State<GoodsIssueReportScreen> {
  final TextEditingController _docNoFilterController = TextEditingController();
  final TextEditingController _employeeFilterController =
      TextEditingController();
  final TextEditingController _dateFilterController = TextEditingController();

  bool _isLoading = false;
  String? _loadingDetailsDocNo;
  List<_GoodsIssueRow> _rows = const <_GoodsIssueRow>[];

  static const String _reportPath = '/api/GetAllGoodIssue';
  static const String _specificPath = '/GetSpecificGoodIssue';

  @override
  void initState() {
    super.initState();
    _fetchAllGoodsIssue();
  }

  @override
  void dispose() {
    _docNoFilterController.dispose();
    _employeeFilterController.dispose();
    _dateFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRows = _rows.where(_matchesFilters).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(title: const Text('Goods Issue Report')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;
            return Column(
              children: [
                _buildFilters(isMobile),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : isMobile
                      ? _buildMobileList(filteredRows)
                      : _buildTable(filteredRows),
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

  Uri _buildNoCacheUriWithQuery(String path, Map<String, String> query) {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final params = Map<String, String>.from(uri.queryParameters)..addAll(query);
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

  Future<void> _fetchAllGoodsIssue() async {
    setState(() => _isLoading = true);

    try {
      final response = await http
          .get(_buildNoCacheUri(_reportPath), headers: _getHeaders())
          .timeout(const Duration(seconds: 25));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Get all good issue failed (${response.statusCode})');
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from good issue report API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid good issue report response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid good issue report response format');
      }

      final mappedRows = <_GoodsIssueRow>[];
      final seenDocNos = <String>{};
      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final docNo = _readValue(row, const <String>[
          'DocNo',
          'DocumentNo',
          'GoodIsssueNo',
          'GoodIssueNo',
          'GoodsIssueNo',
          'DocNum',
        ]);
        if (docNo.isEmpty || !seenDocNos.add(docNo.toLowerCase())) {
          continue;
        }

        mappedRows.add(
          _GoodsIssueRow(
            docNo: docNo,
            postingDate: _formatApiDate(
              _readValue(row, const <String>[
                'PostingDate',
                'DocDate',
                'DocumentDate',
                'Date',
              ]),
            ),
            employee: _readValue(row, const <String>[
              'Employee',
              'EmployeeCode',
              'EmpCode',
              'EmployeeName',
            ]),
            department: _readValue(row, const <String>[
              'Dept',
              'Department',
              'ResponsibleDepartment',
            ]),
            consumptionType: _readValue(row, const <String>[
              'ConsumptionType',
              'Type',
            ]),
          ),
        );
      }

      mappedRows.sort((a, b) => b.docNo.compareTo(a.docNo));
      if (!mounted) {
        return;
      }
      setState(() => _rows = mappedRows);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load Goods Issue list')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openGoodsIssueDetails(_GoodsIssueRow row) async {
    final docNo = row.docNo.trim();
    if (docNo.isEmpty || _loadingDetailsDocNo != null) {
      return;
    }

    setState(() => _loadingDetailsDocNo = docNo);
    try {
      final response = await http
          .get(
            _buildNoCacheUriWithQuery(_specificPath, <String, String>{
              'DocNo': docNo,
            }),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 25));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Get specific good issue failed (${response.statusCode})',
        );
      }
      if (response.body.isEmpty) {
        throw Exception('Empty response from good issue detail API');
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rows;
      if (decoded is List) {
        rows = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'] ?? decoded['result'] ?? decoded['items'];
        if (nested is! List) {
          throw Exception('Invalid good issue detail response format');
        }
        rows = nested;
      } else {
        throw Exception('Invalid good issue detail response format');
      }

      final detailRows = rows.whereType<Map<String, dynamic>>().toList();
      if (detailRows.isEmpty) {
        throw Exception('Good issue detail not found');
      }

      final detail = _GoodsIssueDetail.fromRows(
        detailRows,
        readValue: _readValue,
        formatDate: _formatApiDate,
      );
      if (!mounted) {
        return;
      }
      await _showGoodsIssueDetails(detail);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load Goods Issue details')),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingDetailsDocNo = null);
      }
    }
  }

  bool _matchesFilters(_GoodsIssueRow row) {
    final docNo = _docNoFilterController.text.trim().toLowerCase();
    final employee = _employeeFilterController.text.trim().toLowerCase();
    final date = _dateFilterController.text.trim().toLowerCase();

    return (docNo.isEmpty || row.docNo.toLowerCase().contains(docNo)) &&
        (employee.isEmpty || row.employee.toLowerCase().contains(employee)) &&
        (date.isEmpty || row.postingDate.toLowerCase().contains(date));
  }

  String _readValue(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      final value = row[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }

      final normalizedKey = _normalizeApiKey(key);
      for (final entry in row.entries) {
        if (_normalizeApiKey(entry.key) != normalizedKey) {
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

  String _normalizeApiKey(String key) {
    return key.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toLowerCase();
  }

  String _formatApiDate(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return '';
    }
    return text
        .replaceFirst(RegExp(r'T.*$'), '')
        .replaceFirst(RegExp(r'\s+00:00:00$'), '')
        .replaceFirst(RegExp(r'\s+00$'), '');
  }

  Widget _buildFilters(bool isMobile) {
    final fields = <Widget>[
      _filterField('Doc No', _docNoFilterController),
      _filterField('Employee', _employeeFilterController),
      _filterField('Date', _dateFilterController),
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: isMobile
          ? Column(children: fields)
          : Row(
              children: fields
                  .map(
                    (field) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: field,
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _filterField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMobileList(List<_GoodsIssueRow> rows) {
    if (rows.isEmpty) {
      return const Center(child: Text('No Goods Issue records found'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: rows.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final row = rows[index];
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            onTap: () => _openGoodsIssueDetails(row),
            title: Text(row.docNo),
            subtitle: Text(
              [
                if (row.postingDate.isNotEmpty) row.postingDate,
                if (row.employee.isNotEmpty) row.employee,
                if (row.department.isNotEmpty) row.department,
              ].join(' - '),
            ),
            trailing: _loadingDetailsDocNo == row.docNo
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(row.consumptionType),
          ),
        );
      },
    );
  }

  Widget _buildTable(List<_GoodsIssueRow> rows) {
    if (rows.isEmpty) {
      return const Center(child: Text('No Goods Issue records found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFE8ECF4)),
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text('Doc No')),
          DataColumn(label: Text('Posting Date')),
          DataColumn(label: Text('Employee')),
          DataColumn(label: Text('Department')),
          DataColumn(label: Text('Consumption Type')),
        ],
        rows: rows
            .map(
              (row) => DataRow(
                onSelectChanged: (_) => _openGoodsIssueDetails(row),
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(row.docNo),
                        if (_loadingDetailsDocNo == row.docNo) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),
                  ),
                  DataCell(Text(row.postingDate)),
                  DataCell(Text(row.employee)),
                  DataCell(Text(row.department)),
                  DataCell(Text(row.consumptionType)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _showGoodsIssueDetails(_GoodsIssueDetail detail) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        detail.docNo,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDetailGrid(detail),
                      const SizedBox(height: 18),
                      Text(
                        'Items',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailLines(detail.lines),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailGrid(_GoodsIssueDetail detail) {
    final fields = <MapEntry<String, String>>[
      MapEntry('Doc Date', detail.docDate),
      MapEntry('Posting Date', detail.postingDate),
      MapEntry('Employee', detail.employee),
      MapEntry('Department', detail.department),
      MapEntry('Consumption Type', detail.consumptionType),
      MapEntry('Service Call No', detail.serviceCallNo),
      MapEntry('Sales Order No', detail.salesOrderNo),
      MapEntry('Remarks', detail.remarks),
      MapEntry('Important Note', detail.importantNote),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 650 ? 1 : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: fields.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 1 ? 5 : 2.6,
          ),
          itemBuilder: (context, index) {
            final field = fields[index];
            return DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FB),
                border: Border.all(color: const Color(0xFFE1E5EC)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      field.key,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF677085),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      field.value.isEmpty ? '-' : field.value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
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

  Widget _buildDetailLines(List<_GoodsIssueLine> lines) {
    if (lines.isEmpty) {
      return const Text('No item lines found');
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFE8ECF4)),
        columns: const [
          DataColumn(label: Text('Item Code')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Qty')),
          DataColumn(label: Text('Warehouse')),
          DataColumn(label: Text('Bin')),
          DataColumn(label: Text('Project')),
        ],
        rows: lines
            .map(
              (line) => DataRow(
                cells: [
                  DataCell(Text(line.itemCode)),
                  DataCell(Text(line.itemDesc)),
                  DataCell(Text(line.qty)),
                  DataCell(Text(line.warehouse)),
                  DataCell(Text(line.bin)),
                  DataCell(Text(line.project)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _GoodsIssueRow {
  const _GoodsIssueRow({
    required this.docNo,
    required this.postingDate,
    required this.employee,
    required this.department,
    required this.consumptionType,
  });

  final String docNo;
  final String postingDate;
  final String employee;
  final String department;
  final String consumptionType;
}

class _GoodsIssueDetail {
  const _GoodsIssueDetail({
    required this.docNo,
    required this.docDate,
    required this.postingDate,
    required this.employee,
    required this.department,
    required this.consumptionType,
    required this.serviceCallNo,
    required this.salesOrderNo,
    required this.remarks,
    required this.importantNote,
    required this.lines,
  });

  factory _GoodsIssueDetail.fromRows(
    List<Map<String, dynamic>> rows, {
    required String Function(Map<String, dynamic>, List<String>) readValue,
    required String Function(String) formatDate,
  }) {
    final first = rows.first;
    return _GoodsIssueDetail(
      docNo: readValue(first, const <String>['DocNo', 'GoodIssueNo']),
      docDate: formatDate(readValue(first, const <String>['DocDate'])),
      postingDate: formatDate(readValue(first, const <String>['PostingDate'])),
      employee: readValue(first, const <String>['Employee', 'EmployeeCode']),
      department: readValue(first, const <String>['Dept', 'Department']),
      consumptionType: readValue(first, const <String>[
        'ConsumptionType',
        'Type',
      ]),
      serviceCallNo: readValue(first, const <String>['ServiceCallNo']),
      salesOrderNo: readValue(first, const <String>['SalesOrderNo']),
      remarks: readValue(first, const <String>['Remarks']),
      importantNote: readValue(first, const <String>['ImportantNote']),
      lines: rows
          .map(
            (row) => _GoodsIssueLine(
              itemCode: readValue(row, const <String>['ItemCode']),
              itemDesc: readValue(row, const <String>[
                'ItemDesc',
                'ItemDescription',
              ]),
              qty: readValue(row, const <String>['Qty', 'Quantity']),
              warehouse: readValue(row, const <String>['Warehouse', 'WhsCode']),
              bin: readValue(row, const <String>['Bin', 'BinLocation']),
              project: readValue(row, const <String>['Project', 'ProjectCode']),
            ),
          )
          .where((line) => line.itemCode.isNotEmpty || line.itemDesc.isNotEmpty)
          .toList(growable: false),
    );
  }

  final String docNo;
  final String docDate;
  final String postingDate;
  final String employee;
  final String department;
  final String consumptionType;
  final String serviceCallNo;
  final String salesOrderNo;
  final String remarks;
  final String importantNote;
  final List<_GoodsIssueLine> lines;
}

class _GoodsIssueLine {
  const _GoodsIssueLine({
    required this.itemCode,
    required this.itemDesc,
    required this.qty,
    required this.warehouse,
    required this.bin,
    required this.project,
  });

  final String itemCode;
  final String itemDesc;
  final String qty;
  final String warehouse;
  final String bin;
  final String project;
}
