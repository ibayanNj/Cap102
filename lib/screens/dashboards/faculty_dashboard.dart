import 'package:flutter/material.dart';
import '../../widgets/base_dashboard.dart';
import 'package:faculty_evaluation_app/screens/faculty_pages/faculty_dashboard_page.dart';

import '../faculty_pages/evaluations_page.dart';

class FacultyDashboard extends StatelessWidget {
  const FacultyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDashboard(
      role: 'Faculty',
      userName: 'Prof. Joy V.',
      sidebarItems: [
        SidebarItem(icon: Icons.dashboard, title: 'Dashboard'),
        SidebarItem(icon: Icons.rate_review, title: 'My Evaluations'),
      ],
      pages: [const FacultyDashboardPage(), const FacultyEvaluationsPage()],
    );
  }
}
