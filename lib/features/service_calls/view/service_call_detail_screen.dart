import 'package:flutter/material.dart';

import '../viewmodel/service_call_viewmodel.dart';

class ServiceCallDetailScreen extends StatefulWidget {
  const ServiceCallDetailScreen({super.key, required this.serviceNo});

  final String serviceNo;

  @override
  State<ServiceCallDetailScreen> createState() => _ServiceCallDetailScreenState();
}

class _ServiceCallDetailScreenState extends State<ServiceCallDetailScreen> {
  final _serviceCallViewModel = ServiceCallViewModel();
  bool _isLoading = false;
  String? _loadError;
  Map<String, dynamic> _details = <String, dynamic>{};

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
      _details = <String, dynamic>{};
    });
    try {
      final data = await _serviceCallViewModel.fetchSpecficServiceCall(
        widget.serviceNo,
      );
      if (!mounted) return;
      setState(() {
        _details = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Unable to load service call details. Please retry.';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to load details: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Call: ${widget.serviceNo}'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: _isLoading ? null : _loadDetails,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDetails,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_isLoading) const LinearProgressIndicator(minHeight: 2),
              if (!_isLoading && _loadError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
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
                      TextButton(
                        onPressed: _isLoading ? null : _loadDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              if (!_isLoading && _loadError == null && _details.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'No details found.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              if (!_isLoading && _loadError == null && _details.isNotEmpty)
                ..._buildDetailSections(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDetailSections() {
    return <Widget>[
      _section('Customer', <Widget>[
        _infoTile('Customer Code', _valueFor(const ['CustomerCode'])),
        _infoTile('Customer Name', _valueFor(const ['CustomerName'])),
        _infoTile('Phone', _valueFor(const ['Phone'])),
        _infoTile('Email', _valueFor(const ['Email'])),
        _infoTile('Contract No', _valueFor(const ['ContractNo'])),
      ]),
      _section('Service', <Widget>[
        _infoTile('Service Call ID', _valueFor(const ['ServiceCallId'])),
        _infoTile('Service No', _valueFor(const ['ServiceNo', 'serviceNo'])),
        _infoTile('Service Type', _valueFor(const ['ServiceType'])),
        _infoTile('Current Status', _valueFor(const ['CurrentStatus'])),
        _infoTile('Priority', _valueFor(const ['Priority'])),
        _infoTile('Assigned Tech', _valueFor(const ['AssignedTech'])),
        _infoTile('Created Date', _valueFor(const ['CreatedDate'])),
        _infoTile('Closed Date', _valueFor(const ['ClosedDate'])),
      ]),
      _section('Product', <Widget>[
        _infoTile('Item Code', _valueFor(const ['ItemCode'])),
        _infoTile('Serial Number', _valueFor(const ['SerialNumber'])),
        _infoTile('MFR Serial No', _valueFor(const ['MFRSerialno'])),
      ]),
      _section('Classification', <Widget>[
        _infoTile('Origin Type', _valueFor(const ['OriginType'])),
        _infoTile('Problem Type', _valueFor(const ['ProblemType'])),
        _infoTile('Problem Sub Type', _valueFor(const ['ProblemSubType'])),
        _infoTile('Call Type', _valueFor(const ['CallType'])),
        _infoTile('Job Sheet', _valueFor(const ['JobSheet'])),
      ]),
      _section('Tour', <Widget>[
        _infoTile('Tour Claim', _valueFor(const ['TourClaim'])),
        _infoTile('Tour Start Date', _valueFor(const ['TourStartDate'])),
        _infoTile('Tour End Date', _valueFor(const ['TourEndDate'])),
        _infoTile('Tour Location', _valueFor(const ['TourLocation'])),
      ]),
      _section('Additional', <Widget>[
        _infoTile('Subjects', _valueFor(const ['Subjects'])),
        _infoTile('Repair Assessment', _valueFor(const ['RepairAssesmentType'])),
        _infoTile('Project Code', _valueFor(const ['ProjectCode'])),
        _infoTile('Chargeable', _valueFor(const ['Chargeable'])),
        _infoTile('Expense Amount', _valueFor(const ['ExpenseAmount'])),
        _infoTile('Remarks', _valueFor(const ['Remarks'])),
      ]),
    ];
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
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

  String _valueFor(List<String> keys) {
    for (final key in keys) {
      if (_details.containsKey(key)) {
        final value = _details[key];
        if (value == null) return '-';
        final text = value.toString().trim();
        return text.isEmpty ? '-' : text;
      }
    }
    return '-';
  }
}
