import 'package:flutter/material.dart';
import '../../widgets/base_dashboard.dart';
import '../admin_pages/user_management_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDashboard(
      role: 'Administrator',
      userName: 'Admin User',
      sidebarItems: [
        SidebarItem(icon: Icons.supervisor_account, title: 'User Management'),
      ],
      pages: [const AdminUserManagementPage()],
    );
  }
}
