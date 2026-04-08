import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ApDownPaymentRequestScreen extends StatefulWidget {
  const ApDownPaymentRequestScreen({super.key});

  @override
  State<ApDownPaymentRequestScreen> createState() =>
      _ApDownPaymentRequestScreenState();
}

class _ApDownPaymentRequestScreenState extends State<ApDownPaymentRequestScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final List<_DownPaymentItem> _items = [_DownPaymentItem()];
  final List<XFile> _attachments = [];

  final _vendorRefNoController = TextEditingController();
  final _buyerController = TextEditingController();
  final _ownerController = TextEditingController();
  final _serviceCallController = TextEditingController();
  final _salesOrderController = TextEditingController();
  final _tourStartDateController = TextEditingController();
  final _tourEndDateController = TextEditingController();

  final _dpmPercentController = TextEditingController();
  final _remarksController = TextEditingController();
  final _importantNoteController = TextEditingController();

  final _apDownPaymentNoController = TextEditingController(text: 'APDPM-000001');
  final _postingDateController = TextEditingController();
  final _dueDateController = TextEditingController();

  String? _responsibleDepartment;
  String? _priority;
  String? _paymentType;

  final List<String> _employeeOptions = const [
    'EMP001 - Rahul Verma',
    'EMP002 - Neha Sharma',
    'EMP003 - Amit Singh',
  ];

  final List<String> _departmentOptions = const [
    'Sales',
    'Purchase',
    'Operations',
    'Service',
    'Finance',
  ];

  final List<String> _priorityOptions = const [
    'High',
    'Medium',
    'Low',
    'Urgent',
  ];

  final List<String> _paymentTypeOptions = const [
    'Advance Payment',
    'Against Sales Order',
    'Against Service Call',
    'Project Based',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _postingDateController.text = _formatDate(now);
    _dueDateController.text = _formatDate(now);
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    _vendorRefNoController.dispose();
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
              onPressed: _onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1E69F2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Submit'),
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
          _labelField('Vendor Ref No', _vendorRefNoController),
          const SizedBox(height: 10),
          _selectionField(
            label: 'Buyer',
            controller: _buyerController,
            options: _employeeOptions,
            searchHint: 'Search buyer',
          ),
          const SizedBox(height: 10),
          _selectionField(
            label: 'Owner',
            controller: _ownerController,
            options: _employeeOptions,
            searchHint: 'Search owner',
          ),
          const SizedBox(height: 10),
          _selectionField(
            label: 'Service Call',
            controller: _serviceCallController,
            options: const ['SC-100021', 'SC-100022', 'SC-100023'],
            searchHint: 'Search service call',
          ),
          const SizedBox(height: 10),
          _selectionField(
            label: 'Sales Order',
            controller: _salesOrderController,
            options: const ['SO-30541', 'SO-30542', 'SO-30543'],
            searchHint: 'Search sales order',
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
            onChanged: (value) => setState(() => _responsibleDepartment = value),
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
          _labelField('DPM %', _dpmPercentController),
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
                        SizedBox(width: 30, child: Text('#', style: headerStyle)),
                        SizedBox(width: 160, child: Text('Item Code', style: headerStyle)),
                        SizedBox(width: 190, child: Text('Description', style: headerStyle)),
                        SizedBox(width: 120, child: Text('Qty', style: headerStyle)),
                        SizedBox(width: 140, child: Text('Unit Price', style: headerStyle)),
                        SizedBox(width: 130, child: Text('Discount %', style: headerStyle)),
                        SizedBox(width: 120, child: Text('Tax Code', style: headerStyle)),
                        SizedBox(width: 170, child: Text('Warehouse', style: headerStyle)),
                        SizedBox(width: 160, child: Text('Project', style: headerStyle)),
                        SizedBox(width: 80, child: Text('Act', style: headerStyle)),
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
            child: TextField(controller: item.itemCodeController, decoration: inputDecoration),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 190,
            child: TextField(controller: item.descriptionController, decoration: inputDecoration),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 120,
            child: TextField(controller: item.qtyController, decoration: inputDecoration),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 140,
            child: TextField(controller: item.unitPriceController, decoration: inputDecoration),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 130,
            child: TextField(controller: item.discountController, decoration: inputDecoration),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 120,
            child: TextField(controller: item.taxCodeController, decoration: inputDecoration),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 170,
            child: TextField(controller: item.warehouseController, decoration: inputDecoration),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 160,
            child: TextField(controller: item.projectController, decoration: inputDecoration),
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
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
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
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
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
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFBFBFC),
        suffixIcon: const Icon(Icons.arrow_drop_down),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          options: options,
          searchHint: searchHint,
          emptyText: 'No data found',
        );
        if (!mounted || selected == null) return;
        setState(() {
          controller.text = selected;
        });
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
        onChanged(selected);
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
                                  style: const TextStyle(color: Color(0xFF6A7685)),
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
                                    onTap: () => Navigator.pop(sheetContext, option),
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

  void _onSubmit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AP Down Payment Request ready for submit')),
    );
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
