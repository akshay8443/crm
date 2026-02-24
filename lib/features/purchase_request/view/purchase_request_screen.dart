
// import 'package:flutter/material.dart';

// class PurchaseRequestScreen extends StatefulWidget {
//   const PurchaseRequestScreen({super.key});

//   @override
//   State<PurchaseRequestScreen> createState() => _PurchaseRequestScreenState();
// }

// class _PurchaseRequestScreenState extends State<PurchaseRequestScreen> {
//   final _remarksController = TextEditingController();

//   final List<_PurchaseItem> items = [
//     _PurchaseItem(name: 'Mouse', code: 'IT001', qty: '0'),
//   ];

//   @override
//   void dispose() {
//     _remarksController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//   backgroundColor: const Color(0xFF1E293B),
//   elevation: 0,

//   // 🔙 BACK BUTTON
//   leading: IconButton(
//     icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
//     onPressed: () {
//       Navigator.pop(context);
//     },
//   ),

//   title: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: const [
//       Text(
//         "Purchase Request",
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       Text(
//         "Procurement Module / New Entry",
//         style: TextStyle(
//           color: Color(0xFF94A3B8),
//           fontSize: 11,
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//     ],
//   ),

//   actions: [
//     TextButton(
//       onPressed: () {},
//       child: const Text(
//         "Discard",
//         style: TextStyle(color: Colors.white70, fontSize: 13),
//       ),
//     ),
//     const SizedBox(width: 4),
//     ElevatedButton.icon(
//       onPressed: () {},
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xFF3B82F6),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       ),
//       icon: const Icon(Icons.save, size: 16),
//       label: const Text("Save", style: TextStyle(fontSize: 13)),
//     ),
//     const SizedBox(width: 8),
//   ],
// )
// ,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             _sectionRequester(),
//             const SizedBox(height: 12),
//             _sectionLogistics(),
//             const SizedBox(height: 12),
//             _sectionMetadata(),
//             const SizedBox(height: 12),
//             _sectionItems(),
//             const SizedBox(height: 12),
//             _sectionRemarks(),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   // ---------------- SECTIONS ----------------

//   Widget _sectionRequester() {
//     return _card(
//       title: "REQUESTER DETAILS",
//       icon: Icons.person_outline,
//       child: _textField(label: "Requester Name", value: "Manu"),
//     );
//   }

//   Widget _sectionLogistics() {
//     return _card(
//       title: "LOGISTICS",
//       icon: Icons.local_shipping_outlined,
//       child: Column(
//         children: [
//           _dropdown("Target Warehouse", "Delhi Warehouse"),
//           const SizedBox(height: 12),
//           _textField(label: "Warehouse Code", value: "WH-DEL"),
//         ],
//       ),
//     );
//   }

//   Widget _sectionMetadata() {
//     return _card(
//       title: "DOCUMENT METADATA",
//       icon: Icons.description_outlined,
//       child: Column(
//         children: [
//           _rowFields(
//             _textField(label: "Doc No", value: "PR-202601271556"),
//             _textField(label: "Doc Date", value: "2026-01-27"),
//           ),
//           const SizedBox(height: 12),
//           _rowFields(
//             _dateField(label: "Valid Until", hint: "dd-mm-yyyy"),
//             _dateField(label: "Required Date", hint: "dd-mm-yyyy"),
//           ),
//           const SizedBox(height: 12),
//           _textField(
//             label: "Project Reference",
//             hint: "e.g. PRJ-202X-001",
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _sectionItems() {
//     return _card(
//       title: "ITEMS",
//       icon: Icons.inventory_2_outlined,
//       child: Column(
//         children: [
//           // Items list
//           ...items.asMap().entries.map((entry) => _itemRow(entry.key + 1, entry.value)),
//           const SizedBox(height: 8),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: () {
//                 setState(() {
//                   items.add(_PurchaseItem(name: '', code: '', qty: '0'));
//                 });
//               },
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: const Color(0xFF3B82F6),
//                 side: const BorderSide(color: Color(0xFF3B82F6)),
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               ),
//               icon: const Icon(Icons.add, size: 18),
//               label: const Text("Add New Item"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _sectionRemarks() {
//     return _card(
//       title: "REMARKS",
//       icon: Icons.notes_outlined,
//       child: TextField(
//         controller: _remarksController,
//         maxLines: 3,
//         decoration: const InputDecoration(
//           hintText: "Enter any additional instructions, approvals, or shipping notes here...",
//           hintStyle: TextStyle(color: Color(0xFF94A3B8)),
//           border: OutlineInputBorder(),
//           filled: true,
//           fillColor: Colors.white,
//         ),
//       ),
//     );
//   }

//   // ---------------- ITEM ROW ----------------

//   Widget _itemRow(int index, _PurchaseItem item) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: const Color(0xFFE2E8F0)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header row with index and delete button
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF1F5F9),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   "#$index",
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF64748B),
//                   ),
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
//                 onPressed: () {
//                   setState(() {
//                     items.remove(item);
//                   });
//                 },
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//                 tooltip: "Delete Item",
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
          
//           // Item Description Dropdown
//           DropdownButtonFormField<String>(
//             value: item.name.isEmpty ? null : item.name,
//             hint: const Text("Item Description", style: TextStyle(fontSize: 14)),
//             items: const [
//               DropdownMenuItem(value: 'Mouse', child: Text("Mouse")),
//               DropdownMenuItem(value: 'Keyboard', child: Text("Keyboard")),
//             ],
//             onChanged: (v) => setState(() => item.name = v ?? ''),
//             decoration: const InputDecoration(
//               labelText: "Item Description",
//               border: OutlineInputBorder(),
//               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//               isDense: true,
//             ),
//           ),
//           const SizedBox(height: 12),
          
//           // Item Code and Qty row
//           Row(
//             children: [
//               Expanded(
//                 flex: 2,
//                 child: TextField(
//                   controller: item.code.isNotEmpty ? TextEditingController(text: item.code) : null,
//                   decoration: const InputDecoration(
//                     labelText: "Item Code",
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                     isDense: true,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: TextField(
//                   controller: item.qty.isNotEmpty ? TextEditingController(text: item.qty) : null,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     labelText: "Qty",
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                     isDense: true,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
          
//           // Requirement/Specs
//           TextField(
//             maxLines: 2,
//             decoration: const InputDecoration(
//               labelText: "Requirement / Specs",
//               hintText: "Enter details...",
//               hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
//               border: OutlineInputBorder(),
//               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//               isDense: true,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------------- COMMON UI ----------------

//   Widget _card({required String title, required IconData icon, required Widget child}) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: const BorderSide(color: Color(0xFFE2E8F0)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, size: 20, color: const Color(0xFF3B82F6)),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF64748B),
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             child,
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _rowFields(Widget a, Widget b) {
//     return Row(
//       children: [
//         Expanded(child: a),
//         const SizedBox(width: 12),
//         Expanded(child: b),
//       ],
//     );
//   }

//   Widget _textField({required String label, String? value, String? hint}) {
//     return TextField(
//       controller: value != null ? TextEditingController(text: value) : null,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
//         border: const OutlineInputBorder(),
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//         isDense: true,
//       ),
//     );
//   }

//   Widget _dateField({required String label, String? hint}) {
//     return TextField(
//       readOnly: true,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
//         suffixIcon: const Icon(Icons.calendar_today, size: 18),
//         border: const OutlineInputBorder(),
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//         isDense: true,
//       ),
//       onTap: () {
//         // TODO: Show date picker
//       },
//     );
//   }

//   Widget _dropdown(String label, String value) {
//     return TextField(
//       readOnly: true,
//       controller: TextEditingController(text: value),
//       decoration: InputDecoration(
//         labelText: label,
//         suffixIcon: const Icon(Icons.arrow_drop_down),
//         border: const OutlineInputBorder(),
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//         isDense: true,
//       ),
//     );
//   }
// }

// // ---------------- MODEL ----------------

// class _PurchaseItem {
//   String name;
//   String code;
//   String qty;

//   _PurchaseItem({
//     required this.name,
//     required this.code,
//     required this.qty,
//   });
// }


import 'package:flutter/material.dart';

class PurchaseRequestScreen extends StatefulWidget {
  const PurchaseRequestScreen({super.key});

  @override
  State<PurchaseRequestScreen> createState() => _PurchaseRequestScreenState();
}

class _PurchaseRequestScreenState extends State<PurchaseRequestScreen> {
  final _remarksController = TextEditingController();
  final validUntilController = TextEditingController();
  final requiredDateController = TextEditingController();

  final List<_PurchaseItem> items = [
    _PurchaseItem(name: 'Mouse', code: 'IT001', qty: '0'),
  ];

  @override
  void dispose() {
    _remarksController.dispose();
    validUntilController.dispose();
    requiredDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Purchase Request",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              "Procurement Module / New Entry",
              style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Discard",
                style: TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          const SizedBox(width: 4),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.save, size: 16),
            label: const Text("Save", style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _sectionRequester(),
            const SizedBox(height: 12),
            _sectionLogistics(),
            const SizedBox(height: 12),
            _sectionMetadata(),
            const SizedBox(height: 12),
            _sectionItems(),
            const SizedBox(height: 12),
            _sectionRemarks(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ---------------- SECTIONS ----------------

  Widget _sectionRequester() {
    return _card(
      title: "REQUESTER DETAILS",
      icon: Icons.person_outline,
      child: _textField(label: "Requester Name", value: "Manu"),
    );
  }

  Widget _sectionLogistics() {
    return _card(
      title: "LOGISTICS",
      icon: Icons.local_shipping_outlined,
      child: Column(
        children: [
          _dropdown("Target Warehouse", "Delhi Warehouse"),
          const SizedBox(height: 12),
          _textField(label: "Warehouse Code", value: "WH-DEL"),
        ],
      ),
    );
  }

  Widget _sectionMetadata() {
    return _card(
      title: "DOCUMENT METADATA",
      icon: Icons.description_outlined,
      child: Column(
        children: [
          _rowFields(
            _textField(label: "Doc No", value: "PR-202601271556"),
            _textField(label: "Doc Date", value: "2026-01-27"),
          ),
          const SizedBox(height: 12),
          _rowFields(
            _dateField(
              label: "Valid Until",
              hint: "dd-mm-yyyy",
              controller: validUntilController,
            ),
            _dateField(
              label: "Required Date",
              hint: "dd-mm-yyyy",
              controller: requiredDateController,
            ),
          ),
          const SizedBox(height: 12),
          _textField(
            label: "Project Reference",
            hint: "e.g. PRJ-202X-001",
          ),
        ],
      ),
    );
  }

  Widget _sectionItems() {
    return _card(
      title: "ITEMS",
      icon: Icons.inventory_2_outlined,
      child: Column(
        children: [
          ...items.asMap().entries.map(
                (e) => _itemRow(e.key + 1, e.value),
              ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  items.add(_PurchaseItem(name: '', code: '', qty: '0'));
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                side: const BorderSide(color: Color(0xFF3B82F6)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add New Item"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionRemarks() {
    return _card(
      title: "REMARKS",
      icon: Icons.notes_outlined,
      child: TextField(
        controller: _remarksController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText:
              "Enter any additional instructions, approvals, or shipping notes here...",
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  // ---------------- ITEM ROW ----------------

  Widget _itemRow(int index, _PurchaseItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("#$index",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12)),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  setState(() => items.remove(item));
                },
              )
            ],
          ),
          DropdownButtonFormField<String>(
            value: item.name.isEmpty ? null : item.name,
            items: const [
              DropdownMenuItem(value: "Mouse", child: Text("Mouse")),
              DropdownMenuItem(value: "Keyboard", child: Text("Keyboard")),
            ],
            onChanged: (v) => setState(() => item.name = v ?? ''),
            decoration: const InputDecoration(
              labelText: "Item Description",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "Item Code",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => item.code = v,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Qty",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => item.qty = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const TextField(
            maxLines: 2,
            decoration: InputDecoration(
              labelText: "Requirement / Specs",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- COMMON ----------------

  Widget _card(
      {required String title,
      required IconData icon,
      required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: const Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _rowFields(Widget a, Widget b) {
    return Row(children: [
      Expanded(child: a),
      const SizedBox(width: 12),
      Expanded(child: b),
    ]);
  }

  Widget _textField({required String label, String? value, String? hint}) {
    return TextField(
      controller: value != null ? TextEditingController(text: value) : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _dropdown(String label, String value) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.arrow_drop_down),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _dateField(
      {required String label,
      String? hint,
      required TextEditingController controller}) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (!mounted || picked == null) return;
        controller.text =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      },
    );
  }
}

// ---------------- MODEL ----------------

class _PurchaseItem {
  String name;
  String code;
  String qty;

  _PurchaseItem({
    required this.name,
    required this.code,
    required this.qty,
  });
}
