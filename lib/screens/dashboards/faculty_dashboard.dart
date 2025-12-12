// import 'package:flutter/material.dart';
// import '../../widgets/base_dashboard.dart';
// import 'package:faculty_evaluation_app/screens/faculty_pages/faculty_dashboard_page.dart';
// import '../faculty_pages/evaluations_page.dart';

// class FacultyDashboard extends StatelessWidget {
//   const FacultyDashboard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BaseDashboard(
//       role: 'Faculty',
//       userName: 'Prof. Joy V.',
//       sidebarItems: [
//         SidebarItem(icon: Icons.dashboard, title: 'Dashboard'),
//         SidebarItem(icon: Icons.rate_review, title: 'My Evaluations'),
//       ],
//       pages: [const FacultyDashboardPage(), const FacultyEvaluationsPage()],
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../widgets/base_dashboard.dart';
import 'package:faculty_evaluation_app/screens/faculty_pages/faculty_dashboard_page.dart';
import '../faculty_pages/evaluations_page.dart';
import 'package:faculty_evaluation_app/services/supabase_service.dart';

// class FacultyDashboard extends StatefulWidget {
//   const FacultyDashboard({super.key});

//   @override
//   State<FacultyDashboard> createState() => _FacultyDashboardState();
// }

// class _FacultyDashboardState extends State<FacultyDashboard> {
//   late Future<Map<String, dynamic>?> _profileFuture;

//   @override
//   void initState() {
//     super.initState();
//     _profileFuture = SupabaseService.getCurrentUserProfile();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>?>(
//       future: _profileFuture,
//       builder: (context, snapshot) {
//         // Error handling
//         if (snapshot.hasError) {
//           print('Error loading profile: ${snapshot.error}');
//           return Scaffold(
//             body: Center(child: Text('Error: ${snapshot.error}')),
//           );
//         }

//         // Loading state
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         print('Faculty profile data: ${snapshot.data}');

//         final role = snapshot.data?['role'] ?? 'Faculty';
//         final userName = snapshot.data?['full_name'] ?? 'User';

//         return BaseDashboard(
//           role: role,
//           userName: userName,
//           sidebarItems: [
//             SidebarItem(icon: Icons.dashboard, title: 'Dashboard'),
//             SidebarItem(icon: Icons.rate_review, title: 'My Evaluations'),
//           ],
//           pages: [const FacultyDashboardPage(), const FacultyEvaluationsPage()],
//         );
//       },
//     );
//   }
// }

class FacultyDashboard extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const FacultyDashboard({super.key, this.userData});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    // If userData is passed, use it directly, otherwise fetch from storage
    if (widget.userData != null) {
      _profileFuture = Future.value(widget.userData);
    } else {
      _profileFuture = SupabaseService.getCurrentUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Error loading profile: ${snapshot.error}');
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        debugPrint('Faculty profile data: ${snapshot.data}');

        final role = snapshot.data?['role'] ?? 'Faculty';
        final userName = snapshot.data?['full_name'] ?? 'User';

        return BaseDashboard(
          role: role,
          userName: userName,
          sidebarItems: [
            SidebarItem(icon: Icons.dashboard, title: 'Dashboard'),
            SidebarItem(icon: Icons.rate_review, title: 'My Evaluations'),
          ],
          pages: [const FacultyDashboardPage(), const FacultyEvaluationsPage()],
        );
      },
    );
  }
}
