import 'package:flutter/material.dart';

import 'service_call_report_screen.dart';
import 'service_type_screen.dart';

class ServiceCallScreen extends StatelessWidget {
  const ServiceCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              onTap: () {
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
              onTap: () {
                Navigator.push(
                  context,
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
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 280,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
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
