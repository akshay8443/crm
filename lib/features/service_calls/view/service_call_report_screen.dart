import 'package:flutter/material.dart';

class ServiceCallReportScreen extends StatefulWidget {
  const ServiceCallReportScreen({super.key});

  @override
  State<ServiceCallReportScreen> createState() => _ServiceCallReportScreenState();
}

class _ServiceCallReportScreenState extends State<ServiceCallReportScreen> {
  final _serviceNoCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();
  final _createdDateCtrl = TextEditingController();
  final _priorityCtrl = TextEditingController();
  final _assignedTechCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();

  final List<_ServiceCallReportItem> _allRows = const [
    _ServiceCallReportItem(
      serviceNo: 'SC-000010',
      customer: 'AFS Najafgarh',
      createdDate: '06-Feb-2026',
      priority: 'Medium',
      assignedTech: '0',
      status: 'O',
    ),
    _ServiceCallReportItem(
      serviceNo: 'SC-000011',
      customer: 'Airport Delhi',
      createdDate: '08-Feb-2026',
      priority: 'High',
      assignedTech: 'Anil Kumar',
      status: 'Open',
    ),
  ];

  List<_ServiceCallReportItem> _filteredRows = const [];

  @override
  void initState() {
    super.initState();
    _filteredRows = _allRows;
  }

  @override
  void dispose() {
    _serviceNoCtrl.dispose();
    _customerCtrl.dispose();
    _createdDateCtrl.dispose();
    _priorityCtrl.dispose();
    _assignedTechCtrl.dispose();
    _statusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Service Call Report'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Open Service Call Report',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3F51B5),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 1350,
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade400),
              columnWidths: const {
                0: FlexColumnWidth(1.4),
                1: FlexColumnWidth(1.4),
                2: FlexColumnWidth(1.4),
                3: FlexColumnWidth(1.4),
                4: FlexColumnWidth(1.4),
                5: FlexColumnWidth(1.4),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFF3F51B5)),
                  children: [
                    _headerCell('Service No', _serviceNoCtrl),
                    _headerCell('Customer', _customerCtrl),
                    _headerCell('Created Date', _createdDateCtrl),
                    _headerCell('Priority', _priorityCtrl),
                    _headerCell('Assigned Tech', _assignedTechCtrl),
                    _headerCell('Status', _statusCtrl),
                  ],
                ),
                ..._filteredRows.map(
                  (row) => TableRow(
                    children: [
                      _dataCell(row.serviceNo),
                      _dataCell(row.customer),
                      _dataCell(row.createdDate),
                      _dataCell(row.priority),
                      _dataCell(row.assignedTech),
                      _dataCell(row.status),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: _applyFilters,
          icon: const Icon(Icons.search),
          label: const Text('Search'),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Open Service Call Report',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3F51B5),
          ),
        ),
        const SizedBox(height: 12),
        _mobileFilter('Service No', _serviceNoCtrl),
        _mobileFilter('Customer', _customerCtrl),
        _mobileFilter('Created Date', _createdDateCtrl),
        _mobileFilter('Priority', _priorityCtrl),
        _mobileFilter('Assigned Tech', _assignedTechCtrl),
        _mobileFilter('Status', _statusCtrl),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _applyFilters,
            icon: const Icon(Icons.search),
            label: const Text('Search'),
          ),
        ),
        const SizedBox(height: 12),
        ..._filteredRows.map(
          (row) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _mobileRow('Service No', row.serviceNo),
                  _mobileRow('Customer', row.customer),
                  _mobileRow('Created Date', row.createdDate),
                  _mobileRow('Priority', row.priority),
                  _mobileRow('Assigned Tech', row.assignedTech),
                  _mobileRow('Status', row.status),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerCell(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 34,
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataCell(String value) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        value,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _mobileFilter(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _mobileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _applyFilters() {
    final serviceNo = _serviceNoCtrl.text.trim().toLowerCase();
    final customer = _customerCtrl.text.trim().toLowerCase();
    final createdDate = _createdDateCtrl.text.trim().toLowerCase();
    final priority = _priorityCtrl.text.trim().toLowerCase();
    final assignedTech = _assignedTechCtrl.text.trim().toLowerCase();
    final status = _statusCtrl.text.trim().toLowerCase();

    setState(() {
      _filteredRows = _allRows.where((row) {
        return row.serviceNo.toLowerCase().contains(serviceNo) &&
            row.customer.toLowerCase().contains(customer) &&
            row.createdDate.toLowerCase().contains(createdDate) &&
            row.priority.toLowerCase().contains(priority) &&
            row.assignedTech.toLowerCase().contains(assignedTech) &&
            row.status.toLowerCase().contains(status);
      }).toList();
    });
  }
}

class _ServiceCallReportItem {
  const _ServiceCallReportItem({
    required this.serviceNo,
    required this.customer,
    required this.createdDate,
    required this.priority,
    required this.assignedTech,
    required this.status,
  });

  final String serviceNo;
  final String customer;
  final String createdDate;
  final String priority;
  final String assignedTech;
  final String status;
}
