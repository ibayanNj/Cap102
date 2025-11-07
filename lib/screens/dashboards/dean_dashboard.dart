import 'package:flutter/material.dart';
import '../../widgets/base_dashboard.dart';
import 'package:faculty_evaluation_app/screens/dean_pages/dean_dashboard_page.dart';
import 'package:faculty_evaluation_app/screens/evaluation_form.dart';
import 'package:faculty_evaluation_app/screens/program_chair_pages/evaluation_reports_page.dart';

class DeanDashboard extends StatelessWidget {
  const DeanDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDashboard(
      role: 'Dean',
      userName: 'Ma Concepcion Vera',
      sidebarItems: [
        SidebarItem(icon: Icons.dashboard, title: 'Dashboard'),
        SidebarItem(icon: Icons.assessment, title: 'Evaluation Reports'),
        SidebarItem(icon: Icons.rate_review, title: 'New Evaluation'),
      ],
      pages: [
        const DeanDashboardPage(),
        const EvaluationReportsView(),
        const EvaluationFormView(),
      ],
    );
  }
}
