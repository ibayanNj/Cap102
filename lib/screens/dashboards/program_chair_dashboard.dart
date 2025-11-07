import 'package:flutter/material.dart';
import '../../widgets/base_dashboard.dart';
import '../program_chair_pages/chair_dashboard_page.dart';
import 'package:faculty_evaluation_app/screens/evaluation_form.dart';
import 'package:faculty_evaluation_app/screens/program_chair_pages/evaluation_reports_page.dart';

class ProgramChairDashboard extends StatelessWidget {
  const ProgramChairDashboard({super.key});

  static const String _role = 'Program Chair';
  static const String _userName = 'Aster Vivien C. Vargas';

  @override
  Widget build(BuildContext context) {
    final sidebarItems = <SidebarItem>[
      SidebarItem(icon: Icons.dashboard, title: 'Dashboard'),
      SidebarItem(icon: Icons.assessment, title: 'Evaluation Reports'),
      SidebarItem(icon: Icons.rate_review, title: 'New Evaluation'),
    ];

    final pages = const <Widget>[
      ChairDashboardPage(),
      EvaluationReportsView(),
      EvaluationFormView(),
    ];

    return BaseDashboard(
      role: _role,
      userName: _userName,
      sidebarItems: sidebarItems,
      pages: pages,
    );
  }
}
