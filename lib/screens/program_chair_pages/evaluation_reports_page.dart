import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EvaluationReportsView extends StatefulWidget {
  const EvaluationReportsView({super.key});

  @override
  State<EvaluationReportsView> createState() => _EvaluationReportsViewState();
}

class _EvaluationReportsViewState extends State<EvaluationReportsView> {
  late Future<List<Map<String, dynamic>>> _facultySummaryFuture;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _facultySummaryFuture = _fetchFacultySummary();
  }

  Future<List<Map<String, dynamic>>> _fetchFacultySummary() async {
    try {
      // Get all evaluations grouped by faculty
      final response = await supabase
          .from('evaluations')
          .select(
            'faculty_id, faculty_name, weighted_score, total_score, mastery_score, instructional_score, communication_score, evaluation_score, classroom_score, course_id',
          )
          .order('faculty_name', ascending: true);

      // Group by faculty and calculate averages
      final Map<String, List<Map<String, dynamic>>> groupedByFaculty = {};

      for (var evaluation in response as List) {
        final facultyId = evaluation['faculty_id'] as String;
        if (!groupedByFaculty.containsKey(facultyId)) {
          groupedByFaculty[facultyId] = [];
        }
        groupedByFaculty[facultyId]!.add(evaluation);
      }

      // Calculate averages for each faculty
      final List<Map<String, dynamic>> summary = [];

      groupedByFaculty.forEach((facultyId, evaluations) {
        final count = evaluations.length;
        final avgWeightedScore =
            evaluations
                .map((e) => (e['weighted_score'] as num?)?.toDouble() ?? 0.0)
                .reduce((a, b) => a + b) /
            count;
        final avgTotalScore =
            evaluations
                .map((e) => (e['total_score'] as num?)?.toDouble() ?? 0.0)
                .reduce((a, b) => a + b) /
            count;
        final avgMasteryScore =
            evaluations
                .map((e) => (e['mastery_score'] as num?)?.toDouble() ?? 0.0)
                .reduce((a, b) => a + b) /
            count;
        final avgInstructionalScore =
            evaluations
                .map(
                  (e) => (e['instructional_score'] as num?)?.toDouble() ?? 0.0,
                )
                .reduce((a, b) => a + b) /
            count;
        final avgCommunicationScore =
            evaluations
                .map(
                  (e) => (e['communication_score'] as num?)?.toDouble() ?? 0.0,
                )
                .reduce((a, b) => a + b) /
            count;
        final avgEvaluationScore =
            evaluations
                .map((e) => (e['evaluation_score'] as num?)?.toDouble() ?? 0.0)
                .reduce((a, b) => a + b) /
            count;
        final avgClassroomScore =
            evaluations
                .map((e) => (e['classroom_score'] as num?)?.toDouble() ?? 0.0)
                .reduce((a, b) => a + b) /
            count;

        summary.add({
          'faculty_id': facultyId,
          'faculty_name': evaluations.first['faculty_name'],
          'avg_weighted_score': avgWeightedScore,
          'avg_total_score': avgTotalScore,
          'avg_mastery_score': avgMasteryScore,
          'avg_instructional_score': avgInstructionalScore,
          'avg_communication_score': avgCommunicationScore,
          'avg_evaluation_score': avgEvaluationScore,
          'avg_classroom_score': avgClassroomScore,
          'course_id': evaluations.first['course_id'],
        });
      });

      // Sort by avg_weighted_score descending
      summary.sort(
        (a, b) => (b['avg_weighted_score'] as double).compareTo(
          a['avg_weighted_score'] as double,
        ),
      );

      return summary;
    } catch (e) {
      debugPrint('Error fetching faculty summary: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Faculty Evaluation Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 32, 42, 68),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _facultySummaryFuture = _fetchFacultySummary();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _facultySummaryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _facultySummaryFuture = _fetchFacultySummary();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assessment_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('No evaluation reports found'),
                        Text(
                          'Submit evaluations to see reports here',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final facultyList = snapshot.data!;

                return ListView.builder(
                  itemCount: facultyList.length,
                  itemBuilder: (context, index) {
                    final faculty = facultyList[index];
                    final avgScore = (faculty['avg_weighted_score'] ?? 0.0)
                        .toDouble();

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getScoreColor(avgScore),
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          faculty['faculty_name'] ?? 'Unknown Faculty',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              faculty['course_id'] ?? 'No courses',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 80,
                                  child: Text(
                                    'Avg Rating:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < avgScore.round()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber[600],
                                      size: 18,
                                    );
                                  }),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  avgScore.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) {
      return Colors.amber[700]!; // Darker amber for high scores
    } else if (score >= 80) {
      return Colors.amber[500]!; // Standard amber
    } else if (score >= 70) {
      return Colors.amber[300]!; // Lighter amber
    } else {
      return Colors.amber[100]!; // Very light for lower scores
    }
  }
}
