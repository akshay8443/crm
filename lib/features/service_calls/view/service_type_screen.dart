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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../model/service_call_request.dart';
import '../viewmodel/service_call_viewmodel.dart';

class ServiceTypeScreen extends StatefulWidget {
  const ServiceTypeScreen({super.key});

  @override
  State<ServiceTypeScreen> createState() => _ServiceTypeScreenState();
}

class _ServiceTypeScreenState extends State<ServiceTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  final ServiceCallViewModel _serviceCallViewModel = ServiceCallViewModel();
  bool _isSubmitting = false;

  // ---------------- Controllers ----------------
  final customerCodeCtrl = TextEditingController();
  final customerNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final projectCtrl = TextEditingController();
  final expenseCtrl = TextEditingController();
  final tourLocationCtrl = TextEditingController();
  final serviceNoCtrl = TextEditingController(text: "SC-000011");
  final createdCtrl = TextEditingController();
  final closedDateCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();

  DateTime? tourStartDate;
  DateTime? tourEndDate;
  DateTime? closedDate;
  int _detailsTabIndex = 0;
  final List<XFile> _attachments = [];

  // ---------------- Dropdown Values ----------------
  String ticketStatus = "Open";
  String priority = "Medium";
  String? assignedTech;
  String department = "select Department";
  String serviceType = "select ServiceType";
  String originType = "Select";
  String callType = "Select Call Type";
  String chargeable = "Select";
  String jobSheet = "No";
  String tourClaim = "No";
  String? contractNo;

  String problemType = "Select Problem Type";
  String problemSubType = "Select ProblemSub Type";
  String repairAssessment = "Select";
  String? itemCode;
  String? mfrSerialNumber;
  String? serialNumber;

  @override
  void initState() {
    super.initState();
    createdCtrl.text = _formatDate(DateTime.now());
  }

  @override
  void dispose() {
    customerCodeCtrl.dispose();
    customerNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    projectCtrl.dispose();
    expenseCtrl.dispose();
    tourLocationCtrl.dispose();
    serviceNoCtrl.dispose();
    createdCtrl.dispose();
    closedDateCtrl.dispose();
    remarksCtrl.dispose();
    subjectCtrl.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Service Management / Calls")),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section(
                "Customer Information",
                Column(
                  children: [
                    _field("Customer Code", customerCodeCtrl),
                    _field("Customer Name", customerNameCtrl),
                    _field("Phone", phoneCtrl, keyboard: TextInputType.phone),
                    _field(
                      "Email",
                      emailCtrl,
                      keyboard: TextInputType.emailAddress,
                    ),
                    _dropdown(
                      "Contract No.",
                      contractNo,
                      ["CN-1001", "CN-1002", "CN-1003"],
                      (v) => setState(() => contractNo = v),
                    ),
                    _field("Project", projectCtrl),
                  ],
                ),
              ),

              _section(
                "Ticket Status",
                Column(
                  children: [
                    _dropdown("Status", ticketStatus, [
                      "Open",
                      "In Progress",
                      "Closed",
                    ], (v) => setState(() => ticketStatus = v!)),
                    _dropdown("Priority", priority, [
                      "Low",
                      "Medium",
                      "High",
                    ], (v) => setState(() => priority = v!)),
                    const Divider(),
                    _dropdown(
                      "Assigned Tech",
                      assignedTech,
                      ["Select AssignedPerson", "Tech 1", "Tech 2"],
                      (v) => setState(() => assignedTech = v),
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
                    ], (v) => setState(() => department = v!)),
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
                    ], (v) => setState(() => callType = v!)),
                    _dropdown("Chargeable", chargeable, [
                      "Select",
                      "Chargeable",
                      "FOC",
                    ], (v) => setState(() => chargeable = v!)),
                    _dropdown("Job Sheet", jobSheet, [
                      "No",
                      "YES",
                      "NO",
                    ], (v) => setState(() => jobSheet = v!)),
                    _dropdown(
                      "Problem Type",
                      problemType,
                      [
                        "Select Problem Type",
                        "Not working",
                        "Boom Barrier",
                        "AMC Contract",
                        "AMC Payment",
                        "Boom Barrier",
                        "AMC Contract",
                        "AMC Payment",
                        "AMC FOLLOW UP",
                        "Tender Submission",
                        "PMT",
                        "Material Delivery",
                        "Maintenance Work",
                        "XBIS",
                        "Meeting",
                        "PLC",
                        "UVSS",
                        "Bollard",
                        "Site Handover",
                        "Warranty",
                        "DEMO/TRIAL",
                        "Meeting/Others",
                        "Repair",
                        "NVM",
                        "Material Acceptance",
                        "SALES",
                        "Survey",
                        "Spike Barrier",
                        "LCD Monitor",
                      ],
                      (v) => setState(() => problemType = v!),
                      requiredField: true,
                    ),
                    _dropdown(
                      "Problem Sub Type",
                      problemSubType,
                      [
                        "Select ProblemSub Type",
                        "UPS not working",
                        "PMT of Debugging",
                        "PMT",
                        "Motor , Conveyor Bel",
                        "Turnstile",
                        "XBIS 5335S",
                        "Boom Barrier",
                        "KMS",
                        "Meeting",
                        "UVSS",
                        "Mobile tracer",
                        "X-Ray Machine",
                        "Delivery of cctv",
                        "NETWORK SWITCHES",
                        "Work at Site",
                        "AVTDS",
                        "PLC",
                        "NVM",
                        "Bollard",
                        "VLT-2800",
                        "Buried Cable Systems",
                        "GMS",
                        "Spike Barrier",
                        "CCTV",
                        "Acess Control System",
                        "HHMD",
                      ],
                      (v) => setState(() => problemSubType = v!),
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
                      tourStartDate,
                      (d) => setState(() => tourStartDate = d),
                    ),
                    _datePicker(
                      "Tour End Date",
                      tourEndDate,
                      (d) => setState(() => tourEndDate = d),
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
                      ["Item 001", "Item 002"],
                      (v) => setState(() => itemCode = v),
                      requiredField: true,
                    ),
                    _dropdown(
                      "MFR Serial Number",
                      mfrSerialNumber,
                      ["MFR001", "MFR002"],
                      (v) => setState(() => mfrSerialNumber = v),
                    ),
                    _dropdown(
                      "Serial Number",
                      serialNumber,
                      ["SN001", "SN002"],
                      (v) => setState(() => serialNumber = v),
                      requiredField: true,
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
                        if (picked == null) return;
                        setState(() {
                          closedDate = picked;
                          closedDateCtrl.text = _formatDate(picked);
                        });
                      },
                    ),
                    TextFormField(
                      controller: remarksCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Remarks",
                        border: OutlineInputBorder(),
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
                      TabBar(
                        onTap: (index) {
                          setState(() {
                            _detailsTabIndex = index;
                          });
                        },
                        tabs: [
                          Tab(text: "Subject"),
                          Tab(text: "Attachments"),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: _detailsTabIndex == 0
                            ? TextFormField(
                                controller: subjectCtrl,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  hintText: "Enter subject details",
                                  border: OutlineInputBorder(),
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
                                          (file) => ListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.zero,
                                            leading: const Icon(
                                              Icons.attach_file,
                                            ),
                                            title: Text(_fileName(file.path)),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                setState(() {
                                                  _attachments.remove(file);
                                                });
                                              },
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

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Submit"),
                    ),
                  ),
                ],
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
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        validator: requiredField
            ? (v) => v == null ? "Please select $label" : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
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

  Widget _datePicker(
    String label,
    DateTime? date,
    ValueChanged<DateTime> onPicked,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        controller: TextEditingController(
          text: date == null ? "" : "${date.day}/${date.month}/${date.year}",
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialDate: date ?? DateTime.now(),
          );
          if (picked != null) onPicked(picked);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
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
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final expenseAmount = double.tryParse(expenseCtrl.text.trim()) ?? 0;
    final request = ServiceCallRequest(
      customerCode: customerCodeCtrl.text.trim(),
      customerName: customerNameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      contractNo: _valueOrEmpty(contractNo, <String>[]),
      itemCode: _valueOrEmpty(itemCode, <String>[]),
      serialNumber: _valueOrEmpty(serialNumber, <String>[]),
      mfrSerialno: _valueOrEmpty(mfrSerialNumber, <String>[]),
      currentStatus: ticketStatus.trim(),
      priority: priority.trim(),
      assignedTech: _valueOrEmpty(assignedTech, <String>[
        'Select AssignedPerson',
      ]),
      serviceType: _valueOrEmpty(serviceType, <String>['select ServiceType']),
      originType: _valueOrEmpty(originType, <String>['Select']),
      problemType: _valueOrEmpty(problemType, <String>['Select Problem Type']),
      problemSubType: _valueOrEmpty(problemSubType, <String>[
        'Select ProblemSub Type',
      ]),
      callType: _valueOrEmpty(callType, <String>['Select Call Type']),
      jobSheet: jobSheet.trim(),
      tourClaim: tourClaim.trim(),
      subjects: subjectCtrl.text.trim(),
      tourLocation: tourLocationCtrl.text.trim(),
      repairAssesmentType: _valueOrEmpty(repairAssessment, <String>['Select']),
      projectCode: projectCtrl.text.trim(),
      chargeable: _valueOrEmpty(chargeable, <String>['Select']),
      remarks: remarksCtrl.text.trim(),
      expenseAmount: expenseAmount,
    );

    print('SERVICE CALL FORM DATA: ${request.toJson()}');

    try {
      final response = await _serviceCallViewModel.createServiceCall(request);
      if (!mounted) return;
      final message = (response['message'] ?? 'Service Call Submitted')
          .toString();
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Success'),
          content: Text(message),
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
