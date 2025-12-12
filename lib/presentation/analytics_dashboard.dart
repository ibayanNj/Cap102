import 'package:faculty_evaluation_app/presentation/evaluations_per_sem.dart';
import 'package:flutter/material.dart';
import 'package:faculty_evaluation_app/presentation/semester_trend_chart.dart';
import 'package:faculty_evaluation_app/presentation/top_performing_faculty_card.dart';

class DataAnalyticsView extends StatelessWidget {
  const DataAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // OverviewStatCards(),
          // const SizedBox(height: 20),
          TopPerformingFacultyCard(),
          const SizedBox(height: 20),
          SemesterTrendChart(),
          const SizedBox(height: 20),
          EvaluationsPerSemesterCard(),
        ],
      ),
    );
  }
}
