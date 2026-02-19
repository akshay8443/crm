// import 'package:flutter/material.dart';
// import '../../service_calls/view/service_call_screen.dart';
// import '../../auth/view/login_screen.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const _SideMenu(),
//       appBar: AppBar(
//         title: const Text("Dashboard"),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LoginScreen()),
//                   (_) => false,
//                 );
//               },
//               child: const Text("Logout"),
//             ),
//           )
//         ],
//       ),
//       body: Container(
//         width: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFF9C27B0),
//               Color(0xFF3F51B5),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: _dashboardCard(),
//         ),
//       ),
//     );
//   }

//   Widget _dashboardCard() {
//     return Card(
//       margin: const EdgeInsets.all(20),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             Text(
//               "🎨 Design Document",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "Contains architecture diagrams, UI wireframes, and system design.",
//               style: TextStyle(fontSize: 14),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// class _SideMenu extends StatelessWidget {
//   const _SideMenu();

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Column(
//         children: [
//           Container(
//             height: 160,
//             width: double.infinity,
//             color: Colors.deepPurple,
//             padding: const EdgeInsets.all(16),
//             alignment: Alignment.bottomLeft,
//             child: const Text(
//               "DOCUMENTS\nMENU",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           _menuItem(
//             context,
//             title: "Purchase Request",
//             onTap: () {},
//           ),

//           _menuItem(
//             context,
//             title: "Inventory Transfer Request",
//             onTap: () {},
//           ),

//           _menuItem(
//             context,
//             title: "Service Call",
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const ServiceCallScreen(),
//                 ),
//               );
//             },
//           ),

//           _menuItem(
//             context,
//             title: "Goods Issue Request",
//             onTap: () {},
//           ),

//           _menuItem(
//             context,
//             title: "AP Down Payment Request",
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _menuItem(
//     BuildContext context, {
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: const Icon(Icons.chevron_right),
//       title: Text(title),
//       onTap: () {
//         Navigator.pop(context); // close drawer
//         onTap();
//       },
//     );
//   }
// }

import 'package:crm_app/features/purchase_request/view/purchase_request_screen.dart';
import 'package:flutter/material.dart';
import '../../service_calls/view/service_call_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const _SideMenu(),
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {
                // ✅ PROPER LOGOUT
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: const Text("Logout"),
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF3F51B5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(child: _dashboardCard()),
      ),
    );
  }

  Widget _dashboardCard() {
    return Card(
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🎨 Design Document",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Contains architecture diagrams, UI wireframes, and system design.",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
class _SideMenu extends StatelessWidget {
  const _SideMenu();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            color: Colors.deepPurple,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.bottomLeft,
            child: const Text(
              "DOCUMENTS\nMENU",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          _menuItem(context, title: "Purchase Request", onTap: () {
            Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const PurchaseRequestScreen(),
  ),
);

          }),
          _menuItem(context, title: "Inventory Transfer Request", onTap: () {}),
          _menuItem(
            context,
            title: "Service Call",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ServiceCallScreen(),
                ),
              );
            },
          ),
          _menuItem(context, title: "Goods Issue Request", onTap: () {}),
          _menuItem(context, title: "AP Down Payment Request", onTap: () {}),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: const Icon(Icons.chevron_right),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
