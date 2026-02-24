import 'package:flutter/material.dart';

import 'service_call_report_screen.dart';
import 'service_type_screen.dart';
import '../viewmodel/service_call_viewmodel.dart';

class ServiceCallScreen extends StatefulWidget {
  const ServiceCallScreen({super.key});

  @override
  State<ServiceCallScreen> createState() => _ServiceCallScreenState();
}

class _ServiceCallScreenState extends State<ServiceCallScreen> {
  final ServiceCallViewModel _serviceCallViewModel = ServiceCallViewModel();
  bool _hasPrefetchedMasterData = false;

  @override
  void initState() {
    super.initState();
    print('SERVICE CALL SCREEN initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasPrefetchedMasterData) return;
      _hasPrefetchedMasterData = true;
      _prefetchMasterData();
    });
  }

  Future<void> _prefetchMasterData() async {
    print('SERVICE CALL SCREEN prefetch start');
    try {
      await Future.wait(<Future<void>>[
        _serviceCallViewModel.fetchContractData().then((_) {}),
        _serviceCallViewModel.fetchProjectData().then((_) {}),
        _serviceCallViewModel.fetchEmployeeData().then((_) {}),
        _serviceCallViewModel.fetchProblemTypeData().then((_) {}),
        _serviceCallViewModel.fetchProblemSubTypeData().then((_) {}),
      ]);
      print('SERVICE CALL SCREEN prefetch success');
    } catch (e) {
      print('SERVICE CALL SCREEN prefetch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('SERVICE CALL SCREEN build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Call'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   'Service Call',
            //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            // ),
            const SizedBox(height: 24),
            _actionButton(
              context: context,
              label: 'New Service Call',
              icon: Icons.add,
              onTap: () async {
                print('SERVICE CALL SCREEN: New Service Call tapped');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ServiceTypeScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _actionButton(
              context: context,
              label: 'View All Service Calls',
              icon: Icons.bar_chart,
              onTap: () async {
                print('SERVICE CALL SCREEN: View All Service Calls tapped');
                try {
                  final rows = await _serviceCallViewModel.fetchAllServiceCalls();
                  print(
                    'SERVICE CALL SCREEN: View All prefetch success (${rows.length})',
                  );
                } catch (e) {
                  print('SERVICE CALL SCREEN: View All prefetch error: $e');
                }
                if (!mounted) return;
                Navigator.push(
                  this.context,
                  MaterialPageRoute(
                    builder: (_) => const ServiceCallReportScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Future<void> Function() onTap,
  }) {
    return SizedBox(
      width: 280,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () async {
          await onTap();
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFF5B5CE2),
          elevation: 0,
        ),
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
