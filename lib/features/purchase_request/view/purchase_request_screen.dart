import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PurchaseRequestScreen extends StatefulWidget {
  const PurchaseRequestScreen({super.key});

  @override
  State<PurchaseRequestScreen> createState() => _PurchaseRequestScreenState();
}

class _PurchaseRequestScreenState extends State<PurchaseRequestScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final List<_PurchaseItem> items = [
    _PurchaseItem(),
  ];
  final List<XFile> _attachments = [];

  final _requesterNameController = TextEditingController(text: 'Manu');
  final _ownerNameController = TextEditingController();
  final _reqDepartmentController = TextEditingController();
  final _reqToController = TextEditingController();

  final _docNoController = TextEditingController(text: 'PR-20260312');
  final _docDateController = TextEditingController(text: '2026-03-12');
  final _amendmentDateController = TextEditingController();
  final _shipToController = TextEditingController();
  final _serviceCallController = TextEditingController();
  final _salesOrderController = TextEditingController();

  String? _replacementReason;
  String? _responsibleDepartment;
  String? _privateClient;
  String? _priority;

  @override
  void dispose() {
    _requesterNameController.dispose();
    _ownerNameController.dispose();
    _reqDepartmentController.dispose();
    _reqToController.dispose();
    _docNoController.dispose();
    _docDateController.dispose();
    _amendmentDateController.dispose();
    _shipToController.dispose();
    _serviceCallController.dispose();
    _salesOrderController.dispose();
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
          'Purchase Request',
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
              onPressed: () {},
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
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1E69F2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save & Submit'),
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
                  if (isMobile) ...[
                    _buildRequesterDetailsCard(),
                    const SizedBox(height: 12),
                    _buildDocumentInfoCard(),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildRequesterDetailsCard()),
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
      final photo = await _imagePicker.pickImage(source: ImageSource.camera);
      if (!mounted || photo == null) {
        return;
      }

      setState(() {
        _attachments.add(photo);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open camera')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final files = await _imagePicker.pickMultiImage();
      if (!mounted || files.isEmpty) {
        return;
      }

      setState(() {
        _attachments.addAll(files);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to pick files from gallery')),
      );
    }
  }

  Widget _buildRequesterDetailsCard() {
    return _sectionCard(
      title: 'Requester Details',
      child: Column(
        children: [
          _labelField('Requester Name', _requesterNameController),
          const SizedBox(height: 10),
          _labelField('Owner Name', _ownerNameController),
          const SizedBox(height: 10),
          _labelField('Requisition To Department', _reqDepartmentController),
          const SizedBox(height: 10),
          _labelField('Requisition To', _reqToController),
        ],
      ),
    );
  }

  Widget _buildDocumentInfoCard() {
    return _sectionCard(
      title: 'Document Info',
      child: Column(
        children: [
          _twoCol(
            _labelField('Doc No', _docNoController),
            _labelField('Doc Date', _docDateController),
          ),
          const SizedBox(height: 10),
          _twoCol(
            _dateField('Amendment Date', _amendmentDateController),
            _dropdownField(
              label: 'Requirement Type',
              value: null,
              items: const ['Purchase', 'Replacement'],
              onChanged: (_) {},
              hint: 'Select Type',
            ),
          ),
          const SizedBox(height: 10),
          _twoCol(
            _dropdownField(
              label: 'Explanation for Replacement',
              value: _replacementReason,
              items: const ['Breakdown', 'Upgrade', 'Warranty'],
              onChanged: (value) => setState(() => _replacementReason = value),
              hint: 'Select Reason',
            ),
            _dropdownField(
              label: 'Responsible Department',
              value: _responsibleDepartment,
              items: const ['IT', 'Operations', 'Service'],
              onChanged: (value) =>
                  setState(() => _responsibleDepartment = value),
              hint: 'Select Department',
            ),
          ),
          const SizedBox(height: 10),
          _twoCol(
            _labelField('Ship To', _shipToController),
            _dropdownField(
              label: 'Private Client',
              value: _privateClient,
              items: const ['Yes', 'No'],
              onChanged: (value) => setState(() => _privateClient = value),
              hint: 'Select Option',
            ),
          ),
          const SizedBox(height: 10),
          _twoCol(
            _dropdownField(
              label: 'Priority',
              value: _priority,
              items: const ['Low', 'Medium', 'High'],
              onChanged: (value) => setState(() => _priority = value),
              hint: 'Select Priority',
            ),
            _labelField('Service Call No', _serviceCallController),
          ),
          const SizedBox(height: 10),
          _labelField('Sales Order No', _salesOrderController),
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

    return _sectionCard(
      title: 'Items',
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3F7),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                SizedBox(width: 24, child: Text('#', style: headerStyle)),
                Expanded(flex: 2, child: Text('ITEM', style: headerStyle)),
                Expanded(child: Text('ITEMCODE', style: headerStyle)),
                Expanded(child: Text('ITEMDETAILS', style: headerStyle)),
                Expanded(child: Text('WAREHOUSE', style: headerStyle)),
                Expanded(child: Text('PROJECTCODE', style: headerStyle)),
                SizedBox(width: 58, child: Text('QTY', style: headerStyle)),
                SizedBox(width: 36, child: Text('ACT', style: headerStyle)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ...List.generate(
            items.length,
            (index) => _itemRow(index + 1, items[index], isMobile),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              setState(() {
                items.add(_PurchaseItem());
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0xFF8FB2E9),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Center(
                child: Text(
                  'Add Item',
                  style: TextStyle(
                    color: Color(0xFF143A78),
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
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
        onTap: _openUploadOptions,
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
          child: Center(
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
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemRow(int index, _PurchaseItem item, bool isMobile) {
    final rowTextStyle = TextStyle(
      color: const Color(0xFF2A3038),
      fontSize: isMobile ? 12 : 14,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('$index', style: rowTextStyle)),
          Expanded(
            flex: 2,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: item.name,
                hint: Text('Select Item', style: rowTextStyle),
                items: const [
                  DropdownMenuItem(value: 'Mouse', child: Text('Mouse')),
                  DropdownMenuItem(value: 'Keyboard', child: Text('Keyboard')),
                  DropdownMenuItem(value: 'Laptop', child: Text('Laptop')),
                ],
                onChanged: (value) => setState(() => item.name = value),
              ),
            ),
          ),
          Expanded(child: Text(item.code ?? '', style: rowTextStyle)),
          Expanded(child: Text(item.details ?? '', style: rowTextStyle)),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: item.warehouse,
                hint: Text('Warehouse', style: rowTextStyle),
                items: const [
                  DropdownMenuItem(value: 'Warehouse', child: Text('Warehouse')),
                  DropdownMenuItem(value: 'Main', child: Text('Main')),
                ],
                onChanged: (value) => setState(() => item.warehouse = value),
              ),
            ),
          ),
          Expanded(child: Text(item.projectCode ?? '', style: rowTextStyle)),
          SizedBox(width: 58, child: Text(item.qty ?? '', style: rowTextStyle)),
          SizedBox(
            width: 36,
            child: IconButton(
              onPressed: () {
                setState(() {
                  items.remove(item);
                });
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              color: const Color(0xFF667085),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
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

  Widget _twoCol(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 10),
        Expanded(child: right),
      ],
    );
  }

  Widget _labelField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFBFBFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        filled: true,
        fillColor: const Color(0xFFFBFBFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: now,
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

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFBFBFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFD7DCE4)),
        ),
      ),
      hint: Text(hint),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _PurchaseItem {
  String? name;
  String? code;
  String? details;
  String? warehouse;
  String? projectCode;
  String? qty;

  _PurchaseItem();
}
