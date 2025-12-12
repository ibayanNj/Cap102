import 'package:faculty_evaluation_app/screens/admin_pages/add_courses.dart';
import 'package:flutter/material.dart';
import '../../widgets/base_dashboard.dart';
import '../admin_pages/user_management_page.dart';
import '../admin_pages/academic_period_management_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDashboard(
      role: 'Administrator',
      userName: 'Admin User',
      sidebarItems: [
        SidebarItem(icon: Icons.supervisor_account, title: 'User Management'),
        SidebarItem(icon: Icons.calendar_today, title: 'Academic Periods'),
        SidebarItem(icon: Icons.book, title: 'Manage Courses'),
      ],
      pages: [
        const AdminUserManagementPage(),
        const AcademicPeriodManagementPage(),
        const AdminAddCourseScreen(),
      ],
    );
  }
}
