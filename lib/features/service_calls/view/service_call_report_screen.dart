import 'dart:async';

import 'package:flutter/material.dart';

import '../model/service_call_report_item.dart';
import 'service_call_detail_screen.dart';
import '../viewmodel/service_call_viewmodel.dart';

class ServiceCallReportScreen extends StatefulWidget {
  const ServiceCallReportScreen({super.key});

  @override
  State<ServiceCallReportScreen> createState() => _ServiceCallReportScreenState();
}

class _ServiceCallReportScreenState extends State<ServiceCallReportScreen> {
  final _serviceCallViewModel = ServiceCallViewModel();
  final _serviceNoCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();
  final _createdDateCtrl = TextEditingController();
  final _priorityCtrl = TextEditingController();
  final _assignedTechCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();

  List<ServiceCallReportItem> _allRows = <ServiceCallReportItem>[];
  List<ServiceCallReportItem> _filteredRows = <ServiceCallReportItem>[];
  bool _isLoading = false;
  String? _loadError;

  Future<void> _loadRows() async {
    print('RPT_V3: _loadRows start');
    setState(() {
      _isLoading = true;
      _loadError = null;
      _allRows = <ServiceCallReportItem>[];
      _filteredRows = <ServiceCallReportItem>[];
    });
    try {
      final rows = await _serviceCallViewModel.fetchAllServiceCalls();
      if (!mounted) return;
      setState(() {
        _allRows = rows;
      });
      _applyFilters();
      print('RPT_V3: _loadRows success (${rows.length})');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Unable to load service calls. Please retry.';
        _allRows = <ServiceCallReportItem>[];
        _filteredRows = <ServiceCallReportItem>[];
      });
      print('RPT_V3: _loadRows error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to load service calls: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openServiceCallDetails(ServiceCallReportItem row) {
    final serviceNo = row.serviceNo.trim();
    if (serviceNo.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Service No is missing.')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceCallDetailScreen(serviceNo: serviceNo),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print('RPT_V3: initState');
    // Always and only fetch from API on page init.
    unawaited(_loadRows());
    // Extra retry for fresh-install first-open race cases.
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted || _isLoading) return;
      unawaited(_loadRows());
    });
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
        title: const Text('Open Service Call Report [API V3]'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: _isLoading ? null : _loadRows,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadRows,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Open Service Call Report [API V3]',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3F51B5),
          ),
        ),
        if (_isLoading) const LinearProgressIndicator(minHeight: 2),
        if (!_isLoading && _loadError != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _loadError!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
                TextButton(onPressed: _loadRows, child: const Text('Retry')),
              ],
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
                      _dataCell(row.serviceNo, onTap: () => _openServiceCallDetails(row)),
                      _dataCell(row.customer, onTap: () => _openServiceCallDetails(row)),
                      _dataCell(row.createdDate, onTap: () => _openServiceCallDetails(row)),
                      _dataCell(row.priority, onTap: () => _openServiceCallDetails(row)),
                      _dataCell(row.assignedTech, onTap: () => _openServiceCallDetails(row)),
                      _dataCell(row.status, onTap: () => _openServiceCallDetails(row)),
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
        // const Text(
        //   'Open Service Call Report [API V3]',
        //   style: TextStyle(
        //     fontSize: 24,
        //     fontWeight: FontWeight.w700,
        //     color: Color(0xFF3F51B5),
        //   ),
        // ),
        if (_isLoading) const LinearProgressIndicator(minHeight: 2),
        if (!_isLoading && _loadError != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _loadError!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
                TextButton(onPressed: _loadRows, child: const Text('Retry')),
              ],
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
        if (!_isLoading && _loadError == null && _filteredRows.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No service calls found.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ..._filteredRows.map(
          (row) => InkWell(
            onTap: () => _openServiceCallDetails(row),
            borderRadius: BorderRadius.circular(8),
            child: Card(
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

  Widget _dataCell(String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          value,
          style: const TextStyle(fontSize: 18),
        ),
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
