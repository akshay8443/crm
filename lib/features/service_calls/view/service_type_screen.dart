// import 'package:flutter/material.dart';

// class ServiceCallScreen extends StatefulWidget {
//   const ServiceCallScreen({super.key});

//   @override
//   State<ServiceCallScreen> createState() => _ServiceCallScreenState();
// }

// class _ServiceCallScreenState extends State<ServiceCallScreen> {
//   final _formKey = GlobalKey<FormState>();

//   // Text controllers
//   final customerCodeCtrl = TextEditingController();
//   final customerNameCtrl = TextEditingController();
//   final phoneCtrl = TextEditingController();
//   final emailCtrl = TextEditingController();

//   // Dropdown states
//   String ticketStatus = "Open";
//   String priority = "Medium";
//   String originType = "Phone";

//   String? problemType;
//   String? itemCode;
//   String? serialNumber;

//   @override
//   void dispose() {
//     customerCodeCtrl.dispose();
//     customerNameCtrl.dispose();
//     phoneCtrl.dispose();
//     emailCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Service Management / Calls"),
//       ),
//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               // 🔹 CUSTOMER INFO
//               _section(
//                 title: "Customer Information",
//                 child: Column(
//                   children: [
//                     _textField("Customer Code", customerCodeCtrl),
//                     _textField("Customer Name", customerNameCtrl),
//                     _textField("Phone", phoneCtrl,
//                         keyboard: TextInputType.phone),
//                     _textField("Email", emailCtrl,
//                         keyboard: TextInputType.emailAddress),
//                   ],
//                 ),
//               ),

//               // 🔹 TICKET STATUS
//               _section(
//                 title: "Ticket Status",
//                 child: Column(
//                   children: [
//                     _dropdown(
//                       label: "Status",
//                       value: ticketStatus,
//                       items: const ["Open", "Closed", "Pending"],
//                       onChanged: (v) => setState(() => ticketStatus = v!),
//                     ),
//                     _dropdown(
//                       label: "Priority",
//                       value: priority,
//                       items: const ["Low", "Medium", "High"],
//                       onChanged: (v) => setState(() => priority = v!),
//                     ),
//                   ],
//                 ),
//               ),

//               // 🔹 CALL CLASSIFICATION
//               _section(
//                 title: "Call Classification",
//                 child: Column(
//                   children: [
//                     _dropdown(
//                       label: "Origin Type",
//                       value: originType,
//                       items: const ["Phone", "Email", "WhatsApp"],
//                       onChanged: (v) => setState(() => originType = v!),
//                     ),
//                     _dropdown(
//                       label: "Problem Type",
//                       value: problemType,
//                       items: const ["Hardware", "Software"],
//                       onChanged: (v) => setState(() => problemType = v),
//                       requiredField: true,
//                     ),
//                   ],
//                 ),
//               ),

//               // 🔹 PRODUCT DETAILS
//               _section(
//                 title: "Product Details",
//                 child: Column(
//                   children: [
//                     _dropdown(
//                       label: "Item Code",
//                       value: itemCode,
//                       items: const ["Item 1", "Item 2"],
//                       onChanged: (v) => setState(() => itemCode = v),
//                       requiredField: true,
//                     ),
//                     _dropdown(
//                       label: "Serial Number",
//                       value: serialNumber,
//                       items: const ["SN001", "SN002"],
//                       onChanged: (v) => setState(() => serialNumber = v),
//                       requiredField: true,
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // 🔹 ACTION BUTTONS
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text("Cancel"),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: _submit,
//                       child: const Text("Submit"),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------- ACTION ----------------

//   void _submit() {
//     if (!_formKey.currentState!.validate()) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Service Call Submitted")),
//     );
//   }

//   // ---------------- UI HELPERS ----------------

//   Widget _section({required String title, required Widget child}) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title,
//                 style:
//                     const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 12),
//             child,
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _textField(
//     String label,
//     TextEditingController controller, {
//     TextInputType keyboard = TextInputType.text,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboard,
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//         ),
//       ),
//     );
//   }

//   Widget _dropdown({
//     required String label,
//     required String? value,
//     required List<String> items,
//     required ValueChanged<String?> onChanged,
//     bool requiredField = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         items: items
//             .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//             .toList(),
//         onChanged: onChanged,
//         validator: requiredField
//             ? (v) => v == null ? "Please select $label" : null
//             : null,
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../model/contract_data.dart';
import '../model/employee_data.dart';
import '../model/problem_sub_type_data.dart';
import '../model/problem_type_data.dart';
import '../model/project_data.dart';
import '../model/service_call_request.dart';
import '../viewmodel/service_call_viewmodel.dart';

class ServiceTypeScreen extends StatefulWidget {
  const ServiceTypeScreen({super.key});

  @override
  State<ServiceTypeScreen> createState() => _ServiceTypeScreenState();
}

class _ServiceTypeScreenState extends State<ServiceTypeScreen> {
  static const String _selectCustomerCode = "Select Customer Code";
  static const String _selectCustomerName = "Select Customer Name";
  static const String _selectPhone = "Select Phone";
  static const String _selectEmail = "Select Email";
  static const String _selectContractNo = "Select Contract No.";
  static const String _selectProject = "Select Project";
  static const String _selectAttendBy = "Select Attend By";
  static const String _selectItemCode = "Select Item Code";
  static const String _selectMfrSerialNo = "Select MFR Serial Number";
  static const String _selectSerialNumber = "Select Serial Number";
  static const String _selectProblemType = "Select Problem Type";
  static const String _selectProblemSubType = "Select ProblemSub Type";

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  final ServiceCallViewModel _serviceCallViewModel = ServiceCallViewModel();
  bool _hasRequestedInitialMasterData = false;
  bool _isSubmitting = false;
  bool _showValidationErrors = false;
  bool _isContractDataLoading = false;
  bool _isProjectDataLoading = false;
  bool _isEmployeeDataLoading = false;
  bool _isProblemTypeDataLoading = false;
  bool _isProblemSubTypeDataLoading = false;
  bool _isServiceNoLoading = false;
  String? _contractLoadError;
  String? _projectLoadError;
  String? _employeeLoadError;
  String? _problemTypeLoadError;
  String? _problemSubTypeLoadError;

  // ---------------- Controllers ----------------
  final customerNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final expenseCtrl = TextEditingController();
  final tourLocationCtrl = TextEditingController();
  final serviceNoCtrl = TextEditingController();
  final createdCtrl = TextEditingController();
  final closedDateCtrl = TextEditingController();
  final tourStartDateCtrl = TextEditingController();
  final tourEndDateCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();

  DateTime? tourStartDate;
  DateTime? tourEndDate;
  DateTime? closedDate;
  int _detailsTabIndex = 0;
  final List<XFile> _attachments = [];

  // ---------------- Dropdown Values ----------------
  String ticketStatus = "Select Status";
  String priority = "Select Priority";
  String customerCode = _selectCustomerCode;
  String customerName = _selectCustomerName;
  String phone = _selectPhone;
  String email = _selectEmail;
  String contractNo = _selectContractNo;
  String selectedProject = _selectProject;
  String assignedTech = _selectAttendBy;
  String department = "select Department";
  String serviceType = "select ServiceType";
  String originType = "Select";
  String callType = "Select Call Type";
  String chargeable = "Select";
  String jobSheet = "Select";
  String tourClaim = "No";
  final List<ContractData> _contractData = <ContractData>[];
  final List<ProjectData> _projectData = <ProjectData>[];
  final List<EmployeeData> _employeeData = <EmployeeData>[];
  final List<ProblemTypeData> _problemTypeData = <ProblemTypeData>[];
  final List<ProblemSubTypeData> _problemSubTypeData = <ProblemSubTypeData>[];

  String problemType = _selectProblemType;
  String problemSubType = _selectProblemSubType;
  String repairAssessment = "Select";
  String itemCode = _selectItemCode;
  String mfrSerialNumber = _selectMfrSerialNo;
  String serialNumber = _selectSerialNumber;

  @override
  void initState() {
    super.initState();
    print('SERVICE TYPE SCREEN initState');
    createdCtrl.text = _formatDate(DateTime.now());
    _syncCustomerTextControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasRequestedInitialMasterData) return;
      _hasRequestedInitialMasterData = true;
      print('SERVICE TYPE SCREEN initial master-data load');
      _reloadMasterData();
    });
  }

  Future<void> _reloadMasterData() async {
    print('SERVICE TYPE SCREEN reload master-data start');
    await Future.wait(<Future<void>>[
      _loadContractData(),
      _loadProjectData(),
      _loadEmployeeData(),
      _loadProblemTypeData(),
      _loadProblemSubTypeData(),
      _loadNextServiceNo(),
    ]);
    print('SERVICE TYPE SCREEN reload master-data completed');
  }

  Future<void> _loadNextServiceNo() async {
    setState(() {
      _isServiceNoLoading = true;
    });
    try {
      final nextServiceNo = await _serviceCallViewModel.fetchNextServiceNo();
      if (!mounted) return;
      setState(() {
        serviceNoCtrl.text = nextServiceNo;
      });
    } catch (e) {
      print('SERVICE TYPE SCREEN next service no error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isServiceNoLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    customerNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    expenseCtrl.dispose();
    tourLocationCtrl.dispose();
    serviceNoCtrl.dispose();
    createdCtrl.dispose();
    closedDateCtrl.dispose();
    tourStartDateCtrl.dispose();
    tourEndDateCtrl.dispose();
    remarksCtrl.dispose();
    subjectCtrl.dispose();
    super.dispose();
  }

  List<String> _buildOptions(Iterable<String> source, String placeholder) {
    final values = LinkedHashSet<String>.from(
      source.map((value) => value.trim()).where((value) => value.isNotEmpty),
    ).toList();
    values.sort((a, b) => a.compareTo(b));
    return <String>[placeholder, ...values];
  }

  List<ContractData> get _selectedCustomerContracts {
    final selectedCode = _customerCodeFromSelection(customerCode);
    if (selectedCode.isEmpty) return const <ContractData>[];
    return _contractData
        .where((row) => row.businessPartnerCode.trim() == selectedCode)
        .toList();
  }

  String _customerCodeLabel(String code, String name) {
    if (name.trim().isEmpty) return code.trim();
    return '${code.trim()} - ${name.trim()}';
  }

  List<MapEntry<String, String>> get _customerCodeOptions {
    final byCode = <String, String>{};
    for (final row in _contractData) {
      final code = row.businessPartnerCode.trim();
      if (code.isEmpty) continue;
      final name = row.businessPartnerName.trim();
      byCode.putIfAbsent(code, () => name);
      if (byCode[code]!.isEmpty && name.isNotEmpty) {
        byCode[code] = name;
      }
    }
    final entries = byCode.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  List<String> get _customerCodeItems => <String>[
    _selectCustomerCode,
    ..._customerCodeOptions.map(
      (entry) => _customerCodeLabel(entry.key, entry.value),
    ),
  ];

  String _customerCodeFromSelection(String selected) {
    final normalized = selected.trim();
    if (normalized.isEmpty || normalized == _selectCustomerCode) return '';
    for (final entry in _customerCodeOptions) {
      if (_customerCodeLabel(entry.key, entry.value) == normalized) {
        return entry.key;
      }
    }
    // Backward-safe: in case a plain code is already saved in state.
    final exactCode = _customerCodeOptions.where((e) => e.key == normalized);
    if (exactCode.isNotEmpty) return exactCode.first.key;
    return '';
  }

  List<String> get _contractNoItems => _buildOptions(
    _selectedCustomerContracts.map((row) => row.contractNo),
    _selectContractNo,
  );

  List<ContractData> get _selectedContractRows {
    if (contractNo.trim().isEmpty || contractNo.trim() == _selectContractNo) {
      return _selectedCustomerContracts;
    }
    return _selectedCustomerContracts
        .where((row) => row.contractNo.trim() == contractNo.trim())
        .toList();
  }

  List<String> get _itemCodeItems => _buildOptions(
    _selectedContractRows.map((row) => row.itemNo),
    _selectItemCode,
  );

  List<String> get _mfrSerialItems => _buildOptions(
    _selectedContractRows.map((row) => row.mfrSerialNo),
    _selectMfrSerialNo,
  );

  List<String> get _serialNumberItems => _buildOptions(
    _selectedContractRows.map((row) => row.serialNumber),
    _selectSerialNumber,
  );

  List<String> get _projectItems => _buildOptions(
    _projectData.map((row) => row.displayLabel),
    _selectProject,
  );

  List<String> get _employeeItems => _buildOptions(
    _employeeData.map((row) => row.employeeName),
    _selectAttendBy,
  );

  List<String> get _problemTypeItems => _buildOptions(
    _problemTypeData.map((row) => row.problemType),
    _selectProblemType,
  );

  List<String> get _problemSubTypeItems => _buildOptions(
    _problemSubTypeData.map((row) => row.problemSubType),
    _selectProblemSubType,
  );

  String _projectCodeFromSelection(String selected) {
    final normalized = selected.trim();
    if (normalized.isEmpty || normalized == _selectProject) return '';
    for (final row in _projectData) {
      if (row.displayLabel == normalized) {
        return row.projectCode;
      }
    }
    return '';
  }

  void _setCustomerFieldsFromContract(ContractData contract) {
    customerName = contract.businessPartnerName.trim().isEmpty
        ? _selectCustomerName
        : contract.businessPartnerName.trim();
    phone = contract.phone.trim().isEmpty ? _selectPhone : contract.phone.trim();
    email = contract.email.trim().isEmpty ? _selectEmail : contract.email.trim();
    _syncCustomerTextControllers();
  }

  void _setProductFieldsFromContract(ContractData contract) {
    final nextItemCode = contract.itemNo.trim();
    final nextMfr = contract.mfrSerialNo.trim();
    final nextSerial = contract.serialNumber.trim();
    itemCode = nextItemCode.isEmpty ? _selectItemCode : nextItemCode;
    mfrSerialNumber = nextMfr.isEmpty ? _selectMfrSerialNo : nextMfr;
    serialNumber = nextSerial.isEmpty ? _selectSerialNumber : nextSerial;
  }

  void _resetProductSelection() {
    itemCode = _selectItemCode;
    mfrSerialNumber = _selectMfrSerialNo;
    serialNumber = _selectSerialNumber;
  }

  void _resetCustomerSelection() {
    customerName = _selectCustomerName;
    phone = _selectPhone;
    email = _selectEmail;
    contractNo = _selectContractNo;
    _syncCustomerTextControllers();
    _resetProductSelection();
  }

  void _syncCustomerTextControllers() {
    customerNameCtrl.text =
        customerName == _selectCustomerName ? '' : customerName;
    phoneCtrl.text = phone == _selectPhone ? '' : phone;
    emailCtrl.text = email == _selectEmail ? '' : email;
  }

  void _onCustomerCodeChanged(String? value) {
    final nextValue = (value ?? '').trim().isEmpty
        ? _selectCustomerCode
        : value!.trim();
    setState(() {
      customerCode = nextValue;
      final selectedCode = _customerCodeFromSelection(customerCode);
      final contracts = _selectedCustomerContracts;
      if (selectedCode.isEmpty || contracts.isEmpty) {
        _resetCustomerSelection();
        return;
      }
      final firstContract = contracts.first;
      _setCustomerFieldsFromContract(firstContract);
      contractNo = firstContract.contractNo.trim().isEmpty
          ? _selectContractNo
          : firstContract.contractNo.trim();
      _setProductFieldsFromContract(firstContract);
    });
  }

  void _onContractNoChanged(String? value) {
    final nextValue = (value ?? '').trim().isEmpty
        ? _selectContractNo
        : value!.trim();
    setState(() {
      contractNo = nextValue;
      if (nextValue == _selectContractNo) {
        _resetProductSelection();
        return;
      }
      final matched = _selectedCustomerContracts.where(
        (row) => row.contractNo.trim() == nextValue,
      );
      if (matched.isEmpty) {
        _resetProductSelection();
        return;
      }
      final selectedRow = matched.first;
      _setCustomerFieldsFromContract(selectedRow);
      _setProductFieldsFromContract(selectedRow);
    });
  }

  Future<void> _loadContractData() async {
    setState(() {
      _isContractDataLoading = true;
      _contractLoadError = null;
    });
    try {
      final data = await _serviceCallViewModel.fetchContractData();
      if (!mounted) return;
      setState(() {
        _contractData
          ..clear()
          ..addAll(data);
        _resetCustomerSelection();
        customerCode = _selectCustomerCode;
        _contractLoadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _contractLoadError = 'Unable to load customer data. Please retry.';
      });
      _showSnackBar('Unable to load customer data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isContractDataLoading = false;
        });
      }
    }
  }

  Future<void> _loadProjectData() async {
    setState(() {
      _isProjectDataLoading = true;
      _projectLoadError = null;
    });
    try {
      final data = await _serviceCallViewModel.fetchProjectData();
      if (!mounted) return;
      setState(() {
        _projectData
          ..clear()
          ..addAll(data);
        selectedProject = _selectProject;
        _projectLoadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _projectLoadError = 'Unable to load project data. Please retry.';
      });
      _showSnackBar('Unable to load project data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProjectDataLoading = false;
        });
      }
    }
  }

  Future<void> _loadEmployeeData() async {
    setState(() {
      _isEmployeeDataLoading = true;
      _employeeLoadError = null;
    });
    try {
      final data = await _serviceCallViewModel.fetchEmployeeData();
      if (!mounted) return;
      setState(() {
        _employeeData
          ..clear()
          ..addAll(data);
        assignedTech = _selectAttendBy;
        _employeeLoadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _employeeLoadError = 'Unable to load employee data. Please retry.';
      });
      _showSnackBar('Unable to load employee data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isEmployeeDataLoading = false;
        });
      }
    }
  }

  Future<void> _loadProblemTypeData() async {
    setState(() {
      _isProblemTypeDataLoading = true;
      _problemTypeLoadError = null;
    });
    try {
      final data = await _serviceCallViewModel.fetchProblemTypeData();
      if (!mounted) return;
      setState(() {
        _problemTypeData
          ..clear()
          ..addAll(data);
        problemType = _selectProblemType;
        _problemTypeLoadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _problemTypeLoadError = 'Unable to load problem types. Please retry.';
      });
      _showSnackBar('Unable to load problem types: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProblemTypeDataLoading = false;
        });
      }
    }
  }

  Future<void> _loadProblemSubTypeData() async {
    setState(() {
      _isProblemSubTypeDataLoading = true;
      _problemSubTypeLoadError = null;
    });
    try {
      final data = await _serviceCallViewModel.fetchProblemSubTypeData();
      if (!mounted) return;
      setState(() {
        _problemSubTypeData
          ..clear()
          ..addAll(data);
        problemSubType = _selectProblemSubType;
        _problemSubTypeLoadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _problemSubTypeLoadError =
            'Unable to load problem sub types. Please retry.';
      });
      _showSnackBar('Unable to load problem sub types: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProblemSubTypeDataLoading = false;
        });
      }
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final isMasterDataLoading =
        _isContractDataLoading ||
        _isProjectDataLoading ||
        _isEmployeeDataLoading ||
        _isProblemTypeDataLoading ||
        _isProblemSubTypeDataLoading ||
        _isServiceNoLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Management / Calls"),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: isMasterDataLoading ? null : () => _reloadMasterData(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _showValidationErrors
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section(
                "Customer Information",
                Column(
                  children: [
                    _dropdown(
                      "Customer Code",
                      customerCode,
                      _customerCodeItems,
                      _onCustomerCodeChanged,
                      requiredField: true,
                      invalidValues: const [_selectCustomerCode],
                    ),
                    _field(
                      "Customer Name",
                      customerNameCtrl,
                      readOnly: true,
                    ),
                    _field(
                      "Phone",
                      phoneCtrl,
                      keyboard: TextInputType.phone,
                      readOnly: true,
                    ),
                    _field(
                      "Email",
                      emailCtrl,
                      keyboard: TextInputType.emailAddress,
                      readOnly: true,
                    ),
                    _dropdown(
                      "Contract No.",
                      contractNo,
                      _contractNoItems,
                      _onContractNoChanged,
                    ),
                    if (_isContractDataLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    if (!_isContractDataLoading && _contractLoadError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _contractLoadError!,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadContractData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    _dropdown(
                      "Project",
                      selectedProject,
                      _projectItems,
                      (v) => setState(
                        () => selectedProject =
                            (v ?? '').trim().isEmpty ? _selectProject : v!,
                      ),
                      requiredField: true,
                      invalidValues: const [_selectProject],
                    ),
                    if (_isProjectDataLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    if (!_isProjectDataLoading && _projectLoadError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _projectLoadError!,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadProjectData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              _section(
                "Ticket Status",
                Column(
                  children: [
                    _dropdown("Status", ticketStatus, [
                      "Select Status",
                      "Open",
                      "In Progress",
                      "Closed",
                    ], (v) => setState(() => ticketStatus = v!),
                        requiredField: true,
                        invalidValues: const ["Select Status"]),
                    _dropdown("Priority", priority, [
                      "Select Priority",
                      "Low",
                      "Medium",
                      "High",
                    ], (v) => setState(() => priority = v!),
                        requiredField: true,
                        invalidValues: const ["Select Priority"]),
                    const Divider(),
                    _dropdown(
                      "Attend By",
                      assignedTech,
                      _employeeItems,
                      (v) => setState(
                        () => assignedTech =
                            (v ?? '').trim().isEmpty ? _selectAttendBy : v!,
                      ),
                      requiredField: true,
                      invalidValues: const [_selectAttendBy],
                    ),
                    if (_isEmployeeDataLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    if (!_isEmployeeDataLoading && _employeeLoadError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _employeeLoadError!,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadEmployeeData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    _dropdown("Department", department, [
                      "select Department",
                      "Accounts",
                      "Admin",
                      "Audit",
                      "D&D",
                      "Engineering",
                      "Finance&Accounts",
                      "HR",
                      "IT",
                      "Management",
                      "Pre_Sales",
                      "Production",
                      "Projects",
                      "Sales",
                      "Solution Design - Operations",
                      "Supply_Chain_Management",
                      "Support",
                    ], (v) => setState(() => department = v!),
                        requiredField: true,
                        invalidValues: const ["select Department"]),
                    _dropdown(
                      "ServiceType",
                      serviceType,
                      [
                        "select ServiceType",
                        "CAMC",
                        "NCAMC",
                        "WARRANTY",
                        "OUT OF WARRANTY",
                        "REPAIR",
                        "AMC",
                        "UPGRADATION",
                        "PROJECT",
                      ],
                      (v) => setState(() => serviceType = v!),
                      requiredField: true,
                      invalidValues: const ["select ServiceType"],
                    ),
                  ],
                ),
              ),

              _section(
                "Call Classification",
                Column(
                  children: [
                    _dropdown(
                      "Origin Type",
                      originType,
                      [
                        "Select",
                        "E-Mail",
                        "Telephone No.",
                        "Web",
                        "Site Visit",
                        "Speed Post",
                        "By Hand",
                        "Telephonic",
                        "Letter",
                        "Highcourt",
                        "Courier",
                      ],
                      (v) => setState(() => originType = v!),
                      requiredField: true,
                      invalidValues: const ["Select"],
                    ),
                    _dropdown("Call Type", callType, [
                      "Select Call Type",
                      "Visit",
                      "Vendor Visit",
                      "Remote Support",
                      "Repair",
                      "DEMO",
                      "Replacement",
                      "Sales Visit",
                      "PMT",
                      "Survey",
                      "Meeting",
                      "Service",
                      "Repair Assessment",
                      "Follow up",
                      "Paint",
                      "Site Visit",
                      "Repair Production",
                      "Jobsheet Repair",
                      "Tour",
                      "Upgradation",
                      "reference for repair",
                      "PTZ Camera",
                      "Hydraulic Oil",
                      "UNDER WARRENTY",
                      "double entry",
                      "Onsite work",
                    ], (v) => setState(() => callType = v!),
                        requiredField: true,
                        invalidValues: const ["Select Call Type"]),
                    _dropdown("Chargeable", chargeable, [
                      "Select",
                      "Chargeable",
                      "FOC",
                    ], (v) => setState(() => chargeable = v!),
                        requiredField: true,
                        invalidValues: const ["Select"]),
                    _dropdown("Job Sheet", jobSheet, [
                      "Select",
                      "No",
                      "YES",
                      "NO",
                    ], (v) => setState(() => jobSheet = v!),
                        requiredField: true,
                        invalidValues: const ["Select"]),
                    _dropdown(
                      "Problem Type",
                      problemType,
                      _problemTypeItems,
                      (v) => setState(() => problemType = v!),
                      requiredField: true,
                      invalidValues: const [_selectProblemType],
                    ),
                    if (_isProblemTypeDataLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    if (!_isProblemTypeDataLoading &&
                        _problemTypeLoadError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _problemTypeLoadError!,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadProblemTypeData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    _dropdown(
                      "Problem Sub Type",
                      problemSubType,
                      _problemSubTypeItems,
                      (v) => setState(() => problemSubType = v!),
                      requiredField: true,
                      invalidValues: const [_selectProblemSubType],
                    ),
                    if (_isProblemSubTypeDataLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    if (!_isProblemSubTypeDataLoading &&
                        _problemSubTypeLoadError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _problemSubTypeLoadError!,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadProblemSubTypeData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              _section(
                "Tour Details",
                Column(
                  children: [
                    _dropdown("Tour Claim", tourClaim, [
                      "No",
                      "YES",
                      "NO",
                    ], (v) => setState(() => tourClaim = v!)),
                    _datePicker(
                      "Tour Start Date",
                      date: tourStartDate,
                      controller: tourStartDateCtrl,
                      onPicked: (d) => setState(() {
                        tourStartDate = d;
                        tourStartDateCtrl.text = _formatDate(d);
                      }),
                    ),
                    _datePicker(
                      "Tour End Date",
                      date: tourEndDate,
                      controller: tourEndDateCtrl,
                      onPicked: (d) => setState(() {
                        tourEndDate = d;
                        tourEndDateCtrl.text = _formatDate(d);
                      }),
                    ),
                    _field(
                      "Total Expense Amount",
                      expenseCtrl,
                      keyboard: TextInputType.number,
                    ),
                    _field("Tour_Location", tourLocationCtrl),
                    _dropdown(
                      "Repair Assessment Type",
                      repairAssessment,
                      ["Select", "Opto", "Non Opto"],
                      (v) => setState(() => repairAssessment = v!),
                    ),
                  ],
                ),
              ),

              _section(
                "Product Details",
                Column(
                  children: [
                    _dropdown(
                      "Item Code",
                      itemCode,
                      _itemCodeItems,
                      (v) => setState(
                        () => itemCode =
                            (v ?? '').trim().isEmpty ? _selectItemCode : v!,
                      ),
                      requiredField: true,
                      invalidValues: const [_selectItemCode],
                    ),
                    _dropdown(
                      "MFR Serial Number",
                      mfrSerialNumber,
                      _mfrSerialItems,
                      (v) => setState(
                        () => mfrSerialNumber =
                            (v ?? '').trim().isEmpty ? _selectMfrSerialNo : v!,
                      ),
                      invalidValues: const [_selectMfrSerialNo],
                    ),
                    _dropdown(
                      "Serial Number",
                      serialNumber,
                      _serialNumberItems,
                      (v) => setState(
                        () => serialNumber =
                            (v ?? '').trim().isEmpty
                            ? _selectSerialNumber
                            : v!,
                      ),
                      requiredField: true,
                      invalidValues: const [_selectSerialNumber],
                    ),
                  ],
                ),
              ),

              _section(
                "Administrative",
                Column(
                  children: [
                    _field("Service No", serviceNoCtrl, readOnly: true),
                    _field("Created", createdCtrl, readOnly: true),
                    _field(
                      "Closed Date",
                      closedDateCtrl,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDate: closedDate ?? DateTime.now(),
                        );
                        if (!mounted || picked == null) return;
                        setState(() {
                          closedDate = picked;
                          closedDateCtrl.text = _formatDate(picked);
                        });
                      },
                    ),
                    TextFormField(
                      controller: remarksCtrl,
                      maxLines: 4,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return "Please enter Remarks";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: "Remarks",
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFBDBDBD)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _section(
                "Details",
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TabBar(
                          labelColor: Colors.white,
                          unselectedLabelColor: const Color(0xFF374151),
                          indicator: BoxDecoration(
                            color: const Color(0xFF6D28D9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          tabs: const [
                            Tab(text: "Subject"),
                            Tab(text: "Attachments"),
                          ],
                          onTap: (index) {
                            _safeUnfocus();
                            setState(() {
                              _detailsTabIndex = index;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: _detailsTabIndex == 0
                            ? TextFormField(
                                controller: subjectCtrl,
                                maxLines: 3,
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return "Please enter Subject";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: "Enter subject details",
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFFBDBDBD)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFF2563EB),
                                      width: 1.5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWide = constraints.maxWidth >= 700;
                                  return Column(
                                    children: [
                                      if (isWide)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _attachmentTile(
                                                label: "Take Photo",
                                                icon: Icons.camera_alt_outlined,
                                                onTap: () => _pickAttachment(
                                                  ImageSource.camera,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _attachmentTile(
                                                label: "Gallery",
                                                icon: Icons.image_outlined,
                                                onTap: () => _pickAttachment(
                                                  ImageSource.gallery,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      else ...[
                                        _attachmentTile(
                                          label: "Take Photo",
                                          icon: Icons.camera_alt_outlined,
                                          onTap: () => _pickAttachment(
                                            ImageSource.camera,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        _attachmentTile(
                                          label: "Gallery",
                                          icon: Icons.image_outlined,
                                          onTap: () => _pickAttachment(
                                            ImageSource.gallery,
                                          ),
                                        ),
                                      ],
                                      if (_attachments.isNotEmpty) ...[
                                        const SizedBox(height: 16),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Selected Attachments (${_attachments.length})",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ..._attachments.map(
                                          (file) => Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color(0xFFE5E7EB),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () =>
                                                        _viewAttachment(file),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _attachmentPreview(
                                                            file),
                                                        const SizedBox(
                                                            width: 10),
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              top: 4,
                                                            ),
                                                            child: Text(
                                                              _fileName(
                                                                file.path,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.close),
                                                  onPressed: () {
                                                    setState(() {
                                                      _attachments
                                                          .remove(file);
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Builder(
                builder: (context) {
                  final isProcessing =
                      _isSubmitting ||
                      _isContractDataLoading ||
                      _isProjectDataLoading ||
                      _isEmployeeDataLoading ||
                      _isProblemTypeDataLoading ||
                      _isProblemSubTypeDataLoading ||
                      _isServiceNoLoading;
                  return Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: isProcessing ? null : () => Navigator.pop(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFBDBDBD)),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: isProcessing ? null : _confirmAndSubmit,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isProcessing
                                  ? Colors.grey.shade400
                                  : Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Helpers ----------------

  Widget _section(String title, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboard = TextInputType.text,
    bool readOnly = false,
    bool requiredField = false,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        readOnly: readOnly,
        showCursor: !readOnly,
        enableInteractiveSelection: !readOnly,
        onTap: onTap,
        validator: requiredField
            ? (value) {
                if ((value ?? '').trim().isEmpty) {
                  return "Please enter $label";
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFBDBDBD)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    bool requiredField = false,
    List<String> invalidValues = const <String>[],
  }) {
    final uniqueItems = LinkedHashSet<String>.from(
      items.map((e) => e.trim()).where((e) => e.isNotEmpty),
    ).toList();
    final normalizedValue = value?.trim();
    final dropdownValue = (normalizedValue != null &&
            uniqueItems.any((item) => item == normalizedValue))
        ? normalizedValue
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FormField<String>(
        initialValue: dropdownValue,
        validator: requiredField
            ? (v) {
                final current = (v ?? '').trim();
                if (current.isEmpty) return "Please select $label";
                if (invalidValues.any((item) => item.trim() == current)) {
                  return "Please select $label";
                }
                return null;
              }
            : null,
        builder: (fieldState) {
          final currentValue = (fieldState.value ?? '').trim();
          final hasSelection = currentValue.isNotEmpty;
          return GestureDetector(
            onTap: () async {
              final selected = await _showSearchableDropdownDialog(
                label: label,
                items: uniqueItems,
                currentValue: currentValue,
              );
              if (selected == null) return;
              fieldState.didChange(selected);
              onChanged(selected);
            },
            child: InputDecorator(
              isEmpty: !hasSelection,
              decoration: InputDecoration(
                labelText: label,
                hintText: 'Select',
                border: const OutlineInputBorder(),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFBDBDBD)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                ),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                errorText: fieldState.errorText,
              ),
              child: hasSelection
                  ? Text(
                      currentValue,
                      style: const TextStyle(color: Colors.black87),
                    )
                  : const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }

  Future<String?> _showSearchableDropdownDialog({
    required String label,
    required List<String> items,
    required String currentValue,
  }) async {
    List<String> filteredItems = List<String>.from(items);
    return await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Select $label'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final query = value.trim().toLowerCase();
                        setDialogState(() {
                          filteredItems = items
                              .where((item) => item.toLowerCase().contains(query))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260,
                      child: filteredItems.isEmpty
                          ? const Center(child: Text('No results found'))
                          : ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final option = filteredItems[index];
                                final isSelected = option == currentValue;
                                return ListTile(
                                  dense: true,
                                  title: Text(option),
                                  trailing: isSelected
                                      ? const Icon(Icons.check)
                                      : null,
                                  onTap: () {
                                    _safeUnfocus();
                                    Navigator.of(dialogContext).pop(option);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _safeUnfocus();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _attachmentTile({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC7D2FE), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _viewAttachment(XFile file) async {
    _safeUnfocus();
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        const bgColor = Color(0xFF111827);
        return Dialog(
          backgroundColor: bgColor,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Center(
                    child: kIsWeb
                        ? Image.network(
                            file.path,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white70,
                                size: 48,
                              );
                            },
                          )
                        : Image.file(
                            File(file.path),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white70,
                                size: 48,
                              );
                            },
                          ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _attachmentPreview(XFile file) {
    const previewSize = 100.0;
    final fallback = Container(
      width: previewSize,
      height: previewSize,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.broken_image_outlined, size: 20),
    );

    if (kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          file.path,
          width: previewSize,
          height: previewSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(file.path),
        width: previewSize,
        height: previewSize,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }

  Widget _datePicker(
    String label, {
    required DateTime? date,
    required TextEditingController controller,
    required ValueChanged<DateTime> onPicked,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        readOnly: true,
        showCursor: false,
        enableInteractiveSelection: false,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialDate: date ?? DateTime.now(),
          );
          if (!mounted || picked == null) return;
          onPicked(picked);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatDateTimeForApi(DateTime date) {
    final normalized = DateTime(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
    );
    return normalized.toIso8601String();
  }

  Future<void> _pickAttachment(ImageSource source) async {
    try {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux)) {
        _showSnackBar("Camera/Gallery is not supported on this platform.");
        return;
      }

      if (source == ImageSource.gallery) {
        final pickedFiles = await _imagePicker.pickMultiImage();
        if (pickedFiles.isEmpty) return;
        if (!mounted) return;
        setState(() {
          _attachments.addAll(pickedFiles);
        });
        return;
      }

      final picked = await _imagePicker.pickImage(source: ImageSource.camera);
      if (picked == null) return;
      if (!mounted) return;
      setState(() {
        _attachments.add(picked);
      });
    } on MissingPluginException {
      _showSnackBar(
        "Image picker plugin not loaded. Reinstall app (flutter clean + run).",
      );
    } on PlatformException catch (e) {
      final code = e.code.toLowerCase();
      if (code.contains('permission')) {
        _showSnackBar("Permission denied. Please allow camera/photos access.");
        return;
      }
      _showSnackBar("Unable to open camera/gallery (${e.code}).");
    } catch (e) {
      _showSnackBar("Unable to open camera/gallery. $e");
    }
  }

  String _fileName(String path) {
    return File(path).uri.pathSegments.last;
  }

  void _safeUnfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _confirmAndSubmit() async {
    if (_isSubmitting) return;
    _safeUnfocus();
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;

    if (_detailsTabIndex != 0) {
      setState(() {
        _detailsTabIndex = 0;
      });
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
    }

    if (!_showValidationErrors) {
      setState(() {
        _showValidationErrors = true;
      });
    }

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Submit'),
        content: const Text('Are you sure you want to submit this service call?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldSubmit == true) {
      await _submit();
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _valueOrEmpty(String? value, List<String> placeholders) {
    if (value == null) return '';
    final normalized = value.trim();
    if (normalized.isEmpty) return '';
    if (placeholders.contains(normalized)) return '';
    return normalized;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    _safeUnfocus();
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;

    if (_detailsTabIndex != 0) {
      setState(() {
        _detailsTabIndex = 0;
      });
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
    }
    if (!_showValidationErrors) {
      setState(() {
        _showValidationErrors = true;
      });
    }
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;
    print('SERVICE CALL SUBMIT CLICKED');

    setState(() {
      _isSubmitting = true;
    });

    final expenseAmount = double.tryParse(expenseCtrl.text.trim()) ?? 0;
    final request = ServiceCallRequest(
      customerCode: _customerCodeFromSelection(customerCode),
      customerName: _valueOrEmpty(customerName, <String>[_selectCustomerName]),
      phone: _valueOrEmpty(phone, <String>[_selectPhone]),
      email: _valueOrEmpty(email, <String>[_selectEmail]),
      contractNo: _valueOrEmpty(contractNo, <String>[_selectContractNo]),
      itemCode: _valueOrEmpty(itemCode, <String>[_selectItemCode]),
      serialNumber: _valueOrEmpty(serialNumber, <String>[_selectSerialNumber]),
      mfrSerialno: _valueOrEmpty(mfrSerialNumber, <String>[_selectMfrSerialNo]),
      currentStatus: ticketStatus.trim(),
      priority: priority.trim(),
      assignedTech: _valueOrEmpty(assignedTech, <String>[
        _selectAttendBy,
      ]),
      serviceType: _valueOrEmpty(serviceType, <String>['select ServiceType']),
      serviceNo: serviceNoCtrl.text.trim(),
      createdDate: _formatDateTimeForApi(DateTime.now()),
      closedDate: closedDate == null ? null : _formatDateTimeForApi(closedDate!),
      originType: _valueOrEmpty(originType, <String>['Select']),
      problemType: _valueOrEmpty(problemType, <String>[_selectProblemType]),
      problemSubType: _valueOrEmpty(problemSubType, <String>[
        _selectProblemSubType,
      ]),
      callType: _valueOrEmpty(callType, <String>['Select Call Type']),
      jobSheet: jobSheet.trim(),
      tourClaim: tourClaim.trim(),
      subjects: subjectCtrl.text.trim(),
      tourStartDate:
          tourStartDate == null ? null : _formatDateTimeForApi(tourStartDate!),
      tourEndDate: tourEndDate == null ? null : _formatDateTimeForApi(tourEndDate!),
      tourLocation: tourLocationCtrl.text.trim(),
      repairAssesmentType: _valueOrEmpty(repairAssessment, <String>['Select']),
      projectCode: _projectCodeFromSelection(selectedProject),
      chargeable: _valueOrEmpty(chargeable, <String>['Select']),
      remarks: remarksCtrl.text.trim(),
      expenseAmount: expenseAmount,
    );

    print('SERVICE CALL FORM DATA: ${request.toJson()}');

    try {
      print('SERVICE CALL API CALL START');
      final response = await _serviceCallViewModel.createServiceCall(request);
      print('SERVICE CALL API CALL SUCCESS [UPLOAD FLOW V2]: $response');
      final message = (response['message'] ?? 'Service Call Submitted')
          .toString();
      final serviceNo =
          (response['serviceNo'] ??
                  response['ServiceNo'] ??
                  response['serviceNO'] ??
                  request.serviceNo)
              .toString()
              .trim();
      final resolvedServiceNo = serviceNo.isNotEmpty
          ? serviceNo
          : request.serviceNo.trim();
      String attachmentMessage = '';
      final attachmentFiles = List<XFile>.from(_attachments);
      print(
        'SERVICE CALL ATTACHMENT COUNT [UPLOAD FLOW V2]: ${attachmentFiles.length}',
      );
      if (attachmentFiles.isNotEmpty) {
        try {
          print('UPLOAD IMAGE CALL START [UPLOAD FLOW V2]');
          await _serviceCallViewModel.uploadServiceAttachments(
            serviceNo: resolvedServiceNo,
            customerCode: request.customerCode,
            files: attachmentFiles,
          );
          print('UPLOAD IMAGE CALL SUCCESS [UPLOAD FLOW V2]');
          attachmentMessage =
              '\nAttachments uploaded: ${attachmentFiles.length} file(s)';
        } catch (e) {
          print('UPLOAD IMAGE CALL ERROR [UPLOAD FLOW V2]: $e');
          attachmentMessage =
              '\nService created, but attachment upload failed: $e';
        }
      } else {
        print('UPLOAD IMAGE SKIPPED [UPLOAD FLOW V2]: no attachments selected');
      }
      final successMessage = resolvedServiceNo.isEmpty
          ? '$message$attachmentMessage'
          : '$message\nService No: $resolvedServiceNo$attachmentMessage';
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Success'),
          content: Text(successMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      print('SERVICE CALL API CALL ERROR: $e');
      if (!mounted) return;
      _showSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
