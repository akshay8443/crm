import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';
import '../viewmodel/service_call_viewmodel.dart';

class ServiceCallDetailScreen extends StatefulWidget {
  const ServiceCallDetailScreen({super.key, required this.serviceNo});

  final String serviceNo;

  @override
  State<ServiceCallDetailScreen> createState() => _ServiceCallDetailScreenState();
}

class _ServiceCallDetailScreenState extends State<ServiceCallDetailScreen> {
  static const List<String> _statusOptions = <String>[
    'Open',
    'Closed',
    'Call Closed JWS Open',
  ];

  final _serviceCallViewModel = ServiceCallViewModel();
  bool _isLoading = false;
  bool _isUpdatingStatus = false;
  String? _loadError;
  Map<String, dynamic> _details = <String, dynamic>{};
  List<Map<String, dynamic>> _attachments = <Map<String, dynamic>>[];
  String? _selectedStatus;

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
      _details = <String, dynamic>{};
      _attachments = <Map<String, dynamic>>[];
    });
    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _serviceCallViewModel.fetchSpecficServiceCall(widget.serviceNo),
        _serviceCallViewModel.fetchServiceAttachments(widget.serviceNo),
      ]);
      final data = results[0] as Map<String, dynamic>;
      final attachments = results[1] as List<Map<String, dynamic>>;
      if (!mounted) return;
      setState(() {
        _details = data;
        _attachments = attachments;
        _selectedStatus = _normalizeStatus(_rawValueFor(const ['CurrentStatus']));
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

  Future<void> _updateCurrentStatus() async {
    final selected = _selectedStatus;
    if (selected == null || selected.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid status.')),
      );
      return;
    }
    if (!_hasStatusChanged) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Status is unchanged.')));
      return;
    }

    setState(() {
      _isUpdatingStatus = true;
    });
    try {
      final response = await _serviceCallViewModel.updateServiceCallStatus(
        serviceNo: widget.serviceNo,
        currentStatus: selected,
      );
      if (!mounted) return;
      final message = (response['message'] ?? 'Status updated successfully')
          .toString()
          .trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isEmpty ? 'Status updated successfully' : message)),
      );
      await _loadDetails();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status update failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  bool get _hasStatusChanged {
    final current = _normalizeStatus(_rawValueFor(const ['CurrentStatus']));
    return _selectedStatus != null && _selectedStatus != current;
  }

  String? _normalizeStatus(String? value) {
    if (value == null) return null;
    final cleaned = value.replaceAll(RegExp(r'[^A-Za-z]'), '').toLowerCase();
    if (cleaned == 'open') return 'Open';
    if (cleaned == 'inprogress' || cleaned == 'progress') return 'InProgress';
    if (cleaned == 'closed' || cleaned == 'close') return 'Closed';
    if (cleaned == 'callclosedjwsopen') return 'Call Closed JWS Open';
    return null;
  }

  String _attachmentName(Map<String, dynamic> item) {
    final value = (item['FileName'] ?? item['fileName'] ?? '').toString().trim();
    return value.isEmpty ? 'Attachment' : value;
  }

  String? _attachmentUrl(Map<String, dynamic> item) {
    final rawPath = (item['FilePath'] ?? item['filePath'] ?? '').toString().trim();
    if (rawPath.isEmpty) return null;
    final sanitizedPath = rawPath.replaceAll('\\', '/').replaceAll(' ', '%20');
    if (sanitizedPath.startsWith('http://') ||
        sanitizedPath.startsWith('https://')) {
      return sanitizedPath;
    }
    final normalizedPath = sanitizedPath.startsWith('/')
        ? sanitizedPath
        : '/$sanitizedPath';
    return '${ApiConstants.baseUrl}$normalizedPath';
  }

  Widget _attachmentsSection() {
    if (_attachments.isEmpty) {
      return _section('Attachments', <Widget>[
        const Text('No attachments found.', style: TextStyle(color: Colors.black54)),
      ]);
    }
    return _section(
      'Attachments (${_attachments.length})',
      _attachments.map((item) {
        final imageUrl = _attachmentUrl(item);
        final fileName = _attachmentName(item);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: imageUrl == null
                    ? null
                    : () => showDialog<void>(
                          context: context,
                          builder: (dialogContext) => Dialog(
                            child: InteractiveViewer(
                              child: Image.network(
                                imageUrl,
                                headers: const <String, String>{
                                  'Authorization': ApiConstants.basicAuthorization,
                                },
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: imageUrl == null
                        ? const ColoredBox(
                            color: Color(0xFFE5E7EB),
                            child: Icon(Icons.image_not_supported_outlined),
                          )
                        : Image.network(
                            imageUrl,
                            headers: const <String, String>{
                              'Authorization': ApiConstants.basicAuthorization,
                            },
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const ColoredBox(
                                color: Color(0xFFE5E7EB),
                                child: Icon(Icons.broken_image_outlined),
                              );
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    fileName,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
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
        _infoTile('Contract No', _valueFor(const ['ContractNo'])),
      ]),
      _section('Service', <Widget>[
        _infoTile('Service Call ID', _valueFor(const ['ServiceCallId'])),
        _infoTile('Service No', _valueFor(const ['ServiceNo', 'serviceNo'])),
        _infoTile('Service Type', _valueFor(const ['ServiceType'])),
        _statusEditorTile(),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _isLoading || _isUpdatingStatus || !_hasStatusChanged
                  ? null
                  : _updateCurrentStatus,
              child: _isUpdatingStatus
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update'),
            ),
          ),
        ),
        _infoTile('Priority', _valueFor(const ['Priority'])),
        _infoTile('Assigned Tech', _valueFor(const ['AssignedTech'])),
        _infoTile('Created Date', _valueFor(const ['CreatedDate'])),
        _infoTile('Closed Date', _valueFor(const ['ClosedDate'])),
      ]),
      _section('Product', <Widget>[
        _infoTile('Item Code', _valueFor(const ['ItemCode'])),
        _infoTile('Item Name', _valueFor(const ['ItemName', 'ItemDescription'])),
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
      _attachmentsSection(),
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
    return _infoTileChild(label, Text(value));
  }

  Widget _infoTileChild(String label, Widget child) {
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
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _statusEditorTile() {
    return _infoTileChild(
      'Current Status',
      DropdownButtonFormField<String>(
        initialValue: _selectedStatus,
        isExpanded: true,
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        hint: const Text('Select Status'),
        items: _statusOptions
            .map(
              (status) => DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              ),
            )
            .toList(),
        onChanged: _isUpdatingStatus
            ? null
            : (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
      ),
    );
  }

  String? _rawValueFor(List<String> keys) {
    for (final key in keys) {
      if (_details.containsKey(key)) {
        final value = _details[key];
        if (value == null) return null;
        final text = value.toString().trim();
        if (text.isNotEmpty && text != '-') return text;
      }
    }
    return null;
  }

  String _valueFor(List<String> keys) {
    final value = _rawValueFor(keys);
    return value ?? '-';
  }
}
