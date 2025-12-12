// import 'package:flutter/material.dart';
// import 'package:faculty_evaluation_app/presentation/analytics_dashboard.dart';

// class DeanDashboardPage extends StatelessWidget {
//   const DeanDashboardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(bottom: 12),
//               child: Text(
//                 'Welcome back, Dean!',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//               ),
//             ),
//             DataAnalyticsView(),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:faculty_evaluation_app/presentation/analytics_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:faculty_evaluation_app/models/academic_period_model.dart';

class DeanDashboardPage extends StatefulWidget {
  const DeanDashboardPage({super.key});

  @override
  State<DeanDashboardPage> createState() => _DeanDashboardPageState();
}

class _DeanDashboardPageState extends State<DeanDashboardPage> {
  AcademicPeriodModel? _activePeriod;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActivePeriod();
  }

  Future<void> _fetchActivePeriod() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('academic_periods')
          .select()
          .eq('is_active', true)
          .maybeSingle();

      setState(() {
        if (response != null) {
          _activePeriod = AcademicPeriodModel.fromJson(response);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching active period: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Welcome back, Dean!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            // Current Semester Card
            if (_isLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (_activePeriod != null)
              Card(
                elevation: 2,
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: Colors.blue.shade700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Semester',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_activePeriod!.schoolYear}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _activePeriod!.semester,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_activePeriod!.startDate.month}/${_activePeriod!.startDate.day}/${_activePeriod!.startDate.year} - ${_activePeriod!.endDate.month}/${_activePeriod!.endDate.day}/${_activePeriod!.endDate.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.orange.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          'No active academic period set',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const DataAnalyticsView(),
          ],
        ),
      ),
    );
  }
}
