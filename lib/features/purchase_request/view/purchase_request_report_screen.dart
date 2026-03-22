import 'package:flutter/material.dart';

import 'purchase_request_static_data.dart';

class PurchaseRequestReportScreen extends StatefulWidget {
  const PurchaseRequestReportScreen({super.key});

  @override
  State<PurchaseRequestReportScreen> createState() =>
      _PurchaseRequestReportScreenState();
}

class _PurchaseRequestReportScreenState
    extends State<PurchaseRequestReportScreen> {
  final TextEditingController _docNoFilterController = TextEditingController();
  final TextEditingController _requesterFilterController =
      TextEditingController();
  final TextEditingController _docDateFilterController =
      TextEditingController();

  String _priorityFilter = '';
  String _departmentFilter = '';

  final List<_PurchaseRequestRow> _rows = const [
    _PurchaseRequestRow(
      'PR-000027',
      '',
      '21-Mar-2026',
      'Select Priority',
      'Select Department',
      '',
    ),
    _PurchaseRequestRow(
      'PR-000026',
      '',
      '21-Mar-2026',
      'Select Priority',
      'Select Department',
      '',
    ),
    _PurchaseRequestRow(
      'PR-000019',
      '',
      '21-Mar-2026',
      'Select Priority',
      'Select Department',
      '',
    ),
    _PurchaseRequestRow(
      'PR-000016',
      '100',
      '21-Mar-2026',
      'Low',
      'Engineering',
      'aaa',
    ),
    _PurchaseRequestRow(
      'PR-000015',
      '101',
      '21-Mar-2026',
      'Medium',
      'R&D',
      'test',
    ),
    _PurchaseRequestRow(
      'PR-000014',
      '101',
      '21-Mar-2026',
      'Low',
      'Supply Chain Mgmt',
      'ytttt',
    ),
    _PurchaseRequestRow(
      'PR-000013',
      '100',
      '21-Mar-2026',
      'Medium',
      'Support',
      '',
    ),
    _PurchaseRequestRow(
      'PR-000011',
      '101',
      '20-Mar-2026',
      'Low',
      'R&D',
      'testing',
    ),
    _PurchaseRequestRow(
      'PR-000010',
      '100',
      '20-Mar-2026',
      'High',
      'Engineering',
      'ABC',
    ),
    _PurchaseRequestRow(
      'PR-000009',
      '101',
      '20-Mar-2026',
      'Low',
      'Select Department',
      '',
    ),
    _PurchaseRequestRow(
      'PR-000007',
      '10',
      '20-Mar-2026',
      'High',
      'Select Department',
      'abcd',
    ),
    _PurchaseRequestRow(
      'PR-000006',
      '1011',
      '20-Mar-2026',
      'Medium',
      'Support',
      'TESTINg2',
    ),
    _PurchaseRequestRow(
      'PR-000005',
      '101',
      '20-Mar-2026',
      'Medium',
      'R&D',
      'testing',
    ),
    _PurchaseRequestRow(
      'PR-000003',
      '100',
      '20-Mar-2026',
      'Low',
      'Supply Chain Mgmt',
      'testing',
    ),
    _PurchaseRequestRow(
      'PR-000002',
      '2329',
      '20-Mar-2026',
      'Low',
      'Select Department',
      'testing2',
    ),
    _PurchaseRequestRow(
      'PR-000001',
      '10',
      '20-Mar-2026',
      'Low',
      'Supply Chain Mgmt',
      'testing',
    ),
  ];

  @override
  void dispose() {
    _docNoFilterController.dispose();
    _requesterFilterController.dispose();
    _docDateFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRows = _rows.where(_matchesFilters).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(title: const Text('Purchase Request Report')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;

            return Column(
              children: [
                _buildHeader(),
                _buildFilters(isMobile),
                Expanded(
                  child: isMobile
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),

      // padding: const EdgeInsets.all(12),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(10),
      // ),
    );
  }

  Widget _buildFilters(bool isMobile) {
    final filterFields = [
      _filterTextField(controller: _docNoFilterController, hint: 'Doc No'),
      _filterTextField(
        controller: _requesterFilterController,
        hint: 'Requester',
      ),
      _filterTextField(controller: _docDateFilterController, hint: 'Doc Date'),
      _filterDropdown(
        value: _priorityFilter,
        hint: 'Priority',
        items: const ['Low', 'Medium', 'High'],
        onChanged: (value) => setState(() => _priorityFilter = value ?? ''),
      ),
      _filterDropdown(
        value: _departmentFilter,
        hint: 'Department',
        items: kDepartmentOptions,
        onChanged: (value) => setState(() => _departmentFilter = value ?? ''),
      ),
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
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
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

  Widget _filterDropdown({
    required String value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value.isEmpty ? null : value,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
      onChanged: onChanged,
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

  Widget _buildMobileList(List<_PurchaseRequestRow> rows) {
    if (rows.isEmpty) {
      return const Center(child: Text('No purchase request found'));
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
              _mobileRow('Doc No', row.docNo, isLink: true),
              _mobileRow(
                'Requester',
                row.requester.isEmpty ? '-' : row.requester,
              ),
              _mobileRow('Doc Date', row.docDate),
              _mobileRow('Priority', row.priority),
              _mobileRow('Department', row.department),
              _mobileRow('Remarks', row.remarks.isEmpty ? '-' : row.remarks),
            ],
          ),
        );
      },
    );
  }

  Widget _mobileRow(String label, String value, {bool isLink = false}) {
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
              style: TextStyle(
                color: isLink
                    ? const Color(0xFF2437A5)
                    : const Color(0xFF1E2433),
                decoration: isLink ? TextDecoration.underline : null,
                fontWeight: isLink ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(List<_PurchaseRequestRow> rows) {
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
                  'Requester',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Doc Date',
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
                  'Remarks',
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
                      DataCell(
                        Text(
                          row.docNo,
                          style: const TextStyle(
                            color: Color(0xFF2437A5),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      DataCell(Text(row.requester)),
                      DataCell(Text(row.docDate)),
                      DataCell(Text(row.priority)),
                      DataCell(Text(row.department)),
                      DataCell(Text(row.remarks)),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  bool _matchesFilters(_PurchaseRequestRow row) {
    final docNoFilter = _docNoFilterController.text.trim().toLowerCase();
    final requesterFilter = _requesterFilterController.text
        .trim()
        .toLowerCase();
    final docDateFilter = _docDateFilterController.text.trim().toLowerCase();
    final priorityFilter = _priorityFilter.trim().toLowerCase();
    final departmentFilter = _departmentFilter.trim().toLowerCase();

    final matchesDocNo =
        docNoFilter.isEmpty || row.docNo.toLowerCase().contains(docNoFilter);
    final matchesRequester =
        requesterFilter.isEmpty ||
        row.requester.toLowerCase().contains(requesterFilter);
    final matchesDocDate =
        docDateFilter.isEmpty ||
        row.docDate.toLowerCase().contains(docDateFilter);
    final matchesPriority =
        priorityFilter.isEmpty || row.priority.toLowerCase() == priorityFilter;
    final matchesDepartment =
        departmentFilter.isEmpty ||
        row.department.toLowerCase() == departmentFilter;

    return matchesDocNo &&
        matchesRequester &&
        matchesDocDate &&
        matchesPriority &&
        matchesDepartment;
  }
}

class _PurchaseRequestRow {
  const _PurchaseRequestRow(
    this.docNo,
    this.requester,
    this.docDate,
    this.priority,
    this.department,
    this.remarks,
  );

  final String docNo;
  final String requester;
  final String docDate;
  final String priority;
  final String department;
  final String remarks;
}
