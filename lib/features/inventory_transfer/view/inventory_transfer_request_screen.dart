import 'package:flutter/material.dart';

class InventoryTransferRequestScreen extends StatefulWidget {
  const InventoryTransferRequestScreen({super.key});

  @override
  State<InventoryTransferRequestScreen> createState() =>
      _InventoryTransferRequestScreenState();
}

class _InventoryTransferRequestScreenState
    extends State<InventoryTransferRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _byDepartmentController = TextEditingController();
  final TextEditingController _responsibleDepartmentController =
      TextEditingController();
  final TextEditingController _employeeCodeController = TextEditingController();
  final TextEditingController _teamController = TextEditingController();
  final TextEditingController _importantNoteController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  final TextEditingController _documentNoController = TextEditingController();
  final TextEditingController _postingDateController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _documentDateController = TextEditingController();
  final TextEditingController _opportunityNoController = TextEditingController();
  final TextEditingController _connectedTransferNoController =
      TextEditingController();

  final TextEditingController _demoStartDateController =
      TextEditingController();
  final TextEditingController _demoEndDateController = TextEditingController();
  final TextEditingController _expectedReturnDateController =
      TextEditingController();
  final TextEditingController _salesOrderNoController = TextEditingController();
  final TextEditingController _serviceCallNoController = TextEditingController();

  String _transferType = 'Issue';
  String _status = 'Open';
  String? _fromWarehouse;
  String? _toWarehouse;

  final List<String> _transferTypeOptions = <String>[
    'Issue',
    'Transfer',
    'Return',
  ];
  final List<String> _statusOptions = <String>['Open', 'Closed', 'Pending'];
  final List<String> _warehouseOptions = <String>[
    'WH-01',
    'WH-02',
    'WH-03',
  ];

  final List<_InventoryItemRow> _items = <_InventoryItemRow>[_InventoryItemRow()];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _documentDateController.text = _formatDate(now);
    _postingDateController.text = _formatDate(now);
    _status = 'Open';
  }

  @override
  void dispose() {
    _byDepartmentController.dispose();
    _responsibleDepartmentController.dispose();
    _employeeCodeController.dispose();
    _teamController.dispose();
    _importantNoteController.dispose();
    _remarksController.dispose();

    _documentNoController.dispose();
    _postingDateController.dispose();
    _dueDateController.dispose();
    _documentDateController.dispose();
    _opportunityNoController.dispose();
    _connectedTransferNoController.dispose();

    _demoStartDateController.dispose();
    _demoEndDateController.dispose();
    _expectedReturnDateController.dispose();
    _salesOrderNoController.dispose();
    _serviceCallNoController.dispose();

    for (final row in _items) {
      row.dispose();
    }
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    controller.text = _formatDate(picked);
    if (mounted) setState(() {});
  }

  void _addItemRow() {
    setState(() {
      _items.add(_InventoryItemRow());
    });
  }

  void _removeItemRow(int index) {
    if (_items.length == 1) return;
    setState(() {
      final row = _items.removeAt(index);
      row.dispose();
    });
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inventory Transfer Request submitted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Transfer Request'),
        actions: [
          TextButton(
            onPressed: _onCancel,
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _onSubmit,
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _sectionCard(
                title: 'Transfer Details',
                child: Column(
                  children: [
                    _dropdownField(
                      label: 'Transfer Type',
                      value: _transferType,
                      options: _transferTypeOptions,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _transferType = value);
                      },
                    ),
                    _dropdownField(
                      label: 'From Warehouse',
                      value: _fromWarehouse,
                      options: _warehouseOptions,
                      onChanged: (value) => setState(() => _fromWarehouse = value),
                      requiredField: true,
                    ),
                    _dropdownField(
                      label: 'To Warehouse',
                      value: _toWarehouse,
                      options: _warehouseOptions,
                      onChanged: (value) => setState(() => _toWarehouse = value),
                      requiredField: true,
                    ),
                    _dateField(
                      label: 'Demo Start Date',
                      controller: _demoStartDateController,
                    ),
                    _dateField(
                      label: 'Demo End Date',
                      controller: _demoEndDateController,
                    ),
                    _dateField(
                      label: 'Expected Return Date',
                      controller: _expectedReturnDateController,
                    ),
                    _textField(
                      label: 'Sales Order No',
                      controller: _salesOrderNoController,
                    ),
                    _textField(
                      label: 'Service Call No',
                      controller: _serviceCallNoController,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _sectionCard(
                title: 'Department & Notes',
                child: Column(
                  children: [
                    _textField(
                      label: 'By Department',
                      controller: _byDepartmentController,
                    ),
                    _textField(
                      label: 'Responsible Department',
                      controller: _responsibleDepartmentController,
                    ),
                    _textField(
                      label: 'Employee Code',
                      controller: _employeeCodeController,
                    ),
                    _textField(
                      label: 'Team',
                      controller: _teamController,
                    ),
                    _dropdownField(
                      label: 'Status',
                      value: _status,
                      options: _statusOptions,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _status = value);
                      },
                    ),
                    _textField(
                      label: 'Important Note',
                      controller: _importantNoteController,
                      maxLines: 3,
                    ),
                    _textField(
                      label: 'Remarks',
                      controller: _remarksController,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _sectionCard(
                title: 'Document Details',
                child: Column(
                  children: [
                    _textField(
                      label: 'Document No',
                      controller: _documentNoController,
                    ),
                    _dateField(
                      label: 'Posting Date',
                      controller: _postingDateController,
                    ),
                    _dateField(
                      label: 'Due Date',
                      controller: _dueDateController,
                    ),
                    _dateField(
                      label: 'Document Date',
                      controller: _documentDateController,
                    ),
                    _textField(
                      label: 'Opportunity No',
                      controller: _opportunityNoController,
                    ),
                    _textField(
                      label: 'Connected Transfer No',
                      controller: _connectedTransferNoController,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _sectionCard(
                title: 'Items',
                child: Column(
                  children: [
                    for (int i = 0; i < _items.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _itemRowCard(i),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: _addItemRow,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Row'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemRowCard(int index) {
    final row = _items[index];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Row ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (_items.length > 1)
                IconButton(
                  onPressed: () => _removeItemRow(index),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove row',
                ),
            ],
          ),
          _textField(label: 'Item Code', controller: row.itemCodeController),
          _textField(
            label: 'Description',
            controller: row.descriptionController,
            maxLines: 2,
          ),
          _textField(label: 'Serial No', controller: row.serialNoController),
          _textField(
            label: 'Quantity',
            controller: row.quantityController,
            keyboardType: TextInputType.number,
          ),
          _textField(label: 'From Whs', controller: row.fromWhsController),
          _textField(label: 'To Whs', controller: row.toWhsController),
          _textField(label: 'Project', controller: row.projectController),
          _textField(label: 'Checked By', controller: row.checkedByController),
          _dateField(
            label: 'Checked Date',
            controller: row.checkedDateController,
          ),
          _dateField(
            label: 'Previous Date',
            controller: row.previousDateController,
          ),
          _dateField(label: 'Next Check', controller: row.nextCheckController),
          _textField(label: 'Remarks', controller: row.remarksController),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: options
            .map((option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ))
            .toList(),
        onChanged: onChanged,
        validator: requiredField
            ? (selected) =>
                (selected == null || selected.isEmpty) ? 'Please select $label' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _pickDate(controller),
        decoration: InputDecoration(
          labelText: label,
          hintText: 'dd/mm/yyyy',
          suffixIcon: const Icon(Icons.calendar_today_outlined),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}

class _InventoryItemRow {
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController serialNoController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController fromWhsController = TextEditingController();
  final TextEditingController toWhsController = TextEditingController();
  final TextEditingController projectController = TextEditingController();
  final TextEditingController checkedByController = TextEditingController();
  final TextEditingController checkedDateController = TextEditingController();
  final TextEditingController previousDateController = TextEditingController();
  final TextEditingController nextCheckController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  void dispose() {
    itemCodeController.dispose();
    descriptionController.dispose();
    serialNoController.dispose();
    quantityController.dispose();
    fromWhsController.dispose();
    toWhsController.dispose();
    projectController.dispose();
    checkedByController.dispose();
    checkedDateController.dispose();
    previousDateController.dispose();
    nextCheckController.dispose();
    remarksController.dispose();
  }
}
