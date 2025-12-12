// import 'package:flutter/material.dart';
// import '../../widgets/base_dashboard.dart';
// import 'package:faculty_evaluation_app/screens/dean_pages/dean_dashboard_page.dart';
// import 'package:faculty_evaluation_app/screens/evaluation_form.dart';
// import 'package:faculty_evaluation_app/screens/program_chair_pages/evaluation_reports_page.dart';
// import 'package:faculty_evaluation_app/services/supabase_service.dart';

// class DeanDashboard extends StatelessWidget {
//   const DeanDashboard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>?>(
//       future: SupabaseService.getCurrentUserProfile(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         final role = snapshot.data?['role'] ?? 'Dean';
//         final userName = snapshot.data?['full_name'] ?? 'User';

//         print('Profile data: ${snapshot.data}');

//         return BaseDashboard(
//           role: role,
//           userName: userName,
//           sidebarItems: [
//             SidebarItem(icon: Icons.dashboard, title: 'Dashboard'),
//             SidebarItem(icon: Icons.assessment, title: 'Evaluation Reports'),
//             SidebarItem(icon: Icons.rate_review, title: 'New Evaluation'),
//           ],
//           pages: [
//             const DeanDashboardPage(),
//             const EvaluationReportsView(),
//             const EvaluationFormView(),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../widgets/base_dashboard.dart';
import 'package:faculty_evaluation_app/screens/dean_pages/dean_dashboard_page.dart';
import 'package:faculty_evaluation_app/screens/evaluation_form.dart';
import 'package:faculty_evaluation_app/screens/program_chair_pages/evaluation_reports_page.dart';
import 'package:faculty_evaluation_app/services/supabase_service.dart';

class DeanDashboard extends StatefulWidget {
  const DeanDashboard({super.key});

  @override
  State<DeanDashboard> createState() => _DeanDashboardState();
}

class _DeanDashboardState extends State<DeanDashboard> {
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = SupabaseService.getCurrentUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        // Add error handling
        if (snapshot.hasError) {
          print('Error loading profile: ${snapshot.error}');
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        print('Profile data: ${snapshot.data}');

        final role = snapshot.data?['role'] ?? 'Dean';
        final userName = snapshot.data?['full_name'] ?? 'User';

        return BaseDashboard(
          role: role,
          userName: userName,
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
      },
    );
  }
}
