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

import 'dart:async';

import 'package:crm_app/features/purchase_request/view/purchase_request_options_screen.dart';
import 'package:flutter/material.dart';
import '../../service_calls/view/service_call_screen.dart';
import '../../service_calls/viewmodel/service_call_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ServiceCallViewModel _serviceCallViewModel = ServiceCallViewModel();
  bool _hasPrefetchedServiceData = false;

  @override
  void initState() {
    super.initState();
    print('DASHBOARD: initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasPrefetchedServiceData) return;
      _hasPrefetchedServiceData = true;
      _prefetchServiceMasterData();
    });
  }

  Future<void> _prefetchServiceMasterData() async {
    print('DASHBOARD: prefetch service data start');
    try {
      await Future.wait<void>([
        _serviceCallViewModel.fetchContractData().then((_) {}),
        _serviceCallViewModel.fetchProjectData().then((_) {}),
        _serviceCallViewModel.fetchEmployeeData().then((_) {}),
        _serviceCallViewModel.fetchProblemTypeData().then((_) {}),
        _serviceCallViewModel.fetchProblemSubTypeData().then((_) {}),
      ]);
      print('DASHBOARD: prefetch service data success');
    } catch (error) {
      print('DASHBOARD: prefetch service data error: $error');
    }
  }

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
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: const Text("Logout"),
            ),
          ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: Image.asset(
                    "assets/images/tak.jpeg",
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Design Document",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
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

          _menuItem(
            context,
            title: "Purchase Request",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PurchaseRequestOptionsScreen(),
                ),
              );
            },
          ),
          _menuItem(context, title: "Inventory Transfer Request", onTap: () {}),
          _menuItem(
            context,
            title: "Service Call",
            onTap: () {
              print('DASHBOARD: Service Call menu tapped');
              final serviceCallViewModel = ServiceCallViewModel();
              unawaited(
                Future.wait<void>([
                      serviceCallViewModel.fetchContractData().then((_) {}),
                      serviceCallViewModel.fetchProjectData().then((_) {}),
                      serviceCallViewModel.fetchEmployeeData().then((_) {}),
                      serviceCallViewModel.fetchProblemTypeData().then((_) {}),
                      serviceCallViewModel.fetchProblemSubTypeData().then(
                        (_) {},
                      ),
                    ])
                    .then((_) {
                      print('DASHBOARD: Service APIs warmup success');
                    })
                    .catchError((error) {
                      print('DASHBOARD: Service APIs warmup error: $error');
                    }),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServiceCallScreen()),
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
