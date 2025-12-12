// import 'package:flutter/material.dart';

// class FacultyEvaluationsPage extends StatelessWidget {
//   const FacultyEvaluationsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeader(context),
//             const SizedBox(height: 24),
//             _buildContentSection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         const Flexible(
//           child: Text(
//             '📊 Faculty Evaluation Overview',
//             style: TextStyle(
//               fontSize: 26,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ),
//         ElevatedButton.icon(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.indigo,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           onPressed: () {},
//           icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
//           label: const Text('Refresh', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }
// }

// Widget _buildContentSection() {
//   return LayoutBuilder(
//     builder: (context, constraints) {
//       if (constraints.maxWidth < 800) {
//         return Column(
//           children: [_buildEvaluationHistoryCard(), const SizedBox(height: 20)],
//         );
//       }
//       return Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(flex: 2, child: _buildEvaluationHistoryCard()),
//           const SizedBox(width: 20),
//         ],
//       );
//     },
//   );
// }

// Widget _buildEvaluationHistoryCard() {
//   final items = [
//     (
//       '1st Semester 2024-2025 - Networking 1',
//       'Program Chair',
//       '4.8/5',
//       'Completed',
//       Colors.green,
//     ),
//   ];

//   return _buildCard(
//     title: '📘 Recent Evaluations',
//     child: ListView.separated(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: items.length,
//       separatorBuilder: (_, __) => const Divider(height: 8),
//       itemBuilder: (context, index) {
//         final (course, type, score, status, color) = items[index];
//         return ListTile(
//           leading: CircleAvatar(
//             backgroundColor: color.withValues(alpha: 0.15),
//             child: Icon(
//               status == 'Completed' ? Icons.check : Icons.pending,
//               color: color,
//             ),
//           ),
//           title: Text(
//             course,
//             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//           ),
//           subtitle: Text(type, style: const TextStyle(color: Colors.black54)),
//           trailing: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(score, style: const TextStyle(fontWeight: FontWeight.bold)),
//               Text(status, style: TextStyle(color: color, fontSize: 12)),
//             ],
//           ),
//         );
//       },
//     ),
//   );
// }

// Widget _buildCard({required String title, required Widget child}) {
//   return Container(
//     margin: const EdgeInsets.only(bottom: 12),
//     padding: const EdgeInsets.all(20),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(18),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black12,
//           blurRadius: 10,
//           offset: const Offset(2, 4),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16),
//         child,
//       ],
//     ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:faculty_evaluation_app/services/evaluation_service.dart';

class FacultyEvaluationsPage extends StatefulWidget {
  const FacultyEvaluationsPage({super.key});

  @override
  State<FacultyEvaluationsPage> createState() => _FacultyEvaluationsPageState();
}

class _FacultyEvaluationsPageState extends State<FacultyEvaluationsPage> {
  final EvaluationService _evaluationService = EvaluationService();
  List<Evaluation> _evaluations = [];
  EvaluationStats? _stats;
  bool _isLoading = true;
  String? _error;

  // Set your faculty ID here (no authentication needed)
  final String facultyId =
      '2022-5987124'; // Change this to the faculty ID you want to view

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
  }

  Future<void> _loadEvaluations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final evaluations = await _evaluationService.fetchFacultyEvaluations(
        facultyId,
      );
      final stats = await _evaluationService.getEvaluationStats(facultyId);

      setState(() {
        _evaluations = evaluations;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _loadEvaluations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                _buildErrorCard()
              else
                _buildContentSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Text(
            '📊 Faculty Evaluation Overview',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isLoading ? null : _loadEvaluations,
          icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
          label: const Text('Refresh', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return _buildCard(
      title: '⚠️ Error',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _error ?? 'An unknown error occurred',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEvaluations,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            children: [
              _buildStatsCards(),
              const SizedBox(height: 20),
              _buildEvaluationHistoryCard(),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildEvaluationHistoryCard()),
            const SizedBox(width: 20),
            Expanded(flex: 1, child: _buildStatsCards()),
          ],
        );
      },
    );
  }

  Widget _buildStatsCards() {
    if (_stats == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _buildStatCard(
          title: 'Average Score',
          value: _stats!.averageWeightedScore.toStringAsFixed(2),
          subtitle: 'Weighted Score',
          icon: Icons.star,
          color: Colors.amber,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'Total Evaluations',
          value: _stats!.totalEvaluations.toString(),
          subtitle: 'Completed',
          icon: Icons.assessment,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'Mastery',
          value: _stats!.averageMasteryScore.toStringAsFixed(2),
          subtitle: 'Average Score',
          icon: Icons.school,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'Instructional',
          value: _stats!.averageInstructionalScore.toStringAsFixed(2),
          subtitle: 'Average Score',
          icon: Icons.menu_book,
          color: Colors.purple,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'Communication',
          value: _stats!.averageCommunicationScore.toStringAsFixed(2),
          subtitle: 'Average Score',
          icon: Icons.chat,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationHistoryCard() {
    if (_evaluations.isEmpty) {
      return _buildCard(
        title: '📘 Recent Evaluations',
        child: const Padding(
          padding: EdgeInsets.all(40.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.black26),
                SizedBox(height: 16),
                Text(
                  'No evaluations found',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _buildCard(
      title: '📘 Recent Evaluations',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _evaluations.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (context, index) {
          final eval = _evaluations[index];
          final score = eval.weightedScore ?? eval.totalScore ?? 0.0;
          final color = _getScoreColor(score);

          return InkWell(
            onTap: () => _showEvaluationDetails(eval),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eval.courseName ?? eval.courseId,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${eval.semester} • ${eval.schoolYear}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        if (eval.room != null && eval.room!.isNotEmpty)
                          Text(
                            'Room: ${eval.room}',
                            style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          score.toStringAsFixed(2),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        eval.performanceLevel,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 4.5) return Colors.green;
    if (score >= 4.0) return Colors.blue;
    if (score >= 3.5) return Colors.orange;
    if (score >= 3.0) return Colors.deepOrange;
    return Colors.red;
  }

  void _showEvaluationDetails(Evaluation eval) {
    final score = eval.weightedScore ?? eval.totalScore ?? 0.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                eval.courseName ?? eval.courseId,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getScoreColor(score).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                score.toStringAsFixed(2),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _getScoreColor(score),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailSection('Course Information', [
                _buildDetailRow('Course Code', eval.courseId),
                _buildDetailRow('Semester', eval.semester),
                _buildDetailRow('School Year', eval.schoolYear),
                if (eval.room != null && eval.room!.isNotEmpty)
                  _buildDetailRow('Room', eval.room!),
              ]),
              const Divider(height: 24),
              _buildDetailSection('Performance Scores', [
                _buildDetailRow('Overall Score', score.toStringAsFixed(2)),
                _buildDetailRow('Performance Level', eval.performanceLevel),
                if (eval.masteryScore != null)
                  _buildDetailRow(
                    'Mastery',
                    eval.masteryScore!.toStringAsFixed(2),
                  ),
                if (eval.instructionalScore != null)
                  _buildDetailRow(
                    'Instructional',
                    eval.instructionalScore!.toStringAsFixed(2),
                  ),
                if (eval.communicationScore != null)
                  _buildDetailRow(
                    'Communication',
                    eval.communicationScore!.toStringAsFixed(2),
                  ),
                if (eval.classroomScore != null)
                  _buildDetailRow(
                    'Classroom',
                    eval.classroomScore!.toStringAsFixed(2),
                  ),
                if (eval.evaluationScore != null)
                  _buildDetailRow(
                    'Evaluation',
                    eval.evaluationScore!.toStringAsFixed(2),
                  ),
              ]),
              if (eval.comments != null && eval.comments!.isNotEmpty) ...[
                const Divider(height: 24),
                _buildDetailSection('Comments', [
                  Text(eval.comments!, style: const TextStyle(fontSize: 14)),
                ]),
              ],
              const Divider(height: 24),
              _buildDetailSection('Dates', [
                if (eval.submittedAt != null)
                  _buildDetailRow('Submitted', _formatDate(eval.submittedAt!)),
                if (eval.createdAt != null)
                  _buildDetailRow('Created', _formatDate(eval.createdAt!)),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
