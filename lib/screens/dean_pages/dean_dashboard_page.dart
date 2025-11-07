import 'package:flutter/material.dart';
import 'package:faculty_evaluation_app/presentation/analytics_dashboard.dart';

class DeanDashboardPage extends StatelessWidget {
  const DeanDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Welcome back, Dean!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            DataAnalyticsView(),
          ],
        ),
      ),
    );
  }
}
