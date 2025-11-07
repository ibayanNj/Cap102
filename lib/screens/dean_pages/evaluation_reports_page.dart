import 'package:flutter/material.dart';

class DeanEvaluationReportsPage extends StatelessWidget {
  const DeanEvaluationReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: EvaluationReportsView());
  }
}

class DataAnalyticsView extends StatelessWidget {
  const DataAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSemesterCardsMobile(),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          _buildTopPerformingFaculty(),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          _buildSubjectStrengthsAnalysis(),
        ],
      ),
    );
  }

  Widget _buildSemesterCardsMobile() {
    final semesters = [
      {
        'title': '1st Semester',
        'year': '2022-2023',
        'color': Colors.blue,
        'icon': Icons.school,
      },
      {
        'title': '2nd Semester',
        'year': '2023-2024',
        'color': Colors.orange,
        'icon': Icons.book,
      },
      {
        'title': '1st Semester',
        'year': '2024-2025',
        'color': Colors.green,
        'icon': Icons.calendar_today,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: semesters.map((sem) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: (sem['color'] as Color).withValues(
                      alpha: 0.1,
                    ),
                    child: Icon(
                      sem['icon'] as IconData,
                      color: sem['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sem['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: sem['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sem['year'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopPerformingFaculty() {
    final topFaculty = [
      {
        'name': 'Camille Quintanilla',
        'subject': 'ITP122',
        'rating': 4.8,
        'evaluations': 23,
      },
      {
        'name': 'Noel Jr. T. Ibayan',
        'subject': 'CC106',
        'rating': 4.7,
        'evaluations': 21,
      },
      {
        'name': 'Shane Tabuzo',
        'subject': 'Discrete Mathematics',
        'rating': 4.6,
        'evaluations': 19,
      },
    ];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Performing Faculty (Current Semester)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...topFaculty.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> faculty = entry.value;
              return _buildTopFacultyRow(
                index + 1,
                faculty['name'],
                faculty['subject'],
                faculty['rating'].toDouble(),
                faculty['evaluations'],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopFacultyRow(
    int rank,
    String name,
    String subject,
    double rating,
    int evaluations,
  ) {
    Color rankColor = rank == 1
        ? Colors.amber
        : rank == 2
        ? Colors.grey[400]!
        : Colors.brown[400]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        // ✅ Detect small screen width
        final isSmallScreen = constraints.maxWidth < 400;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: isSmallScreen
              ? Column(
                  // ✅ Stack vertically on small screens
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildRankCircle(rank, rankColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 42, top: 4),
                      child: Text(
                        subject,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 42, top: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber[600],
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$evaluations evals',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  // ✅ Horizontal layout for larger screens
                  children: [
                    _buildRankCircle(rank, rankColor),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            subject,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber[600],
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$evaluations evals',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildRankCircle(int rank, Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectStrengthsAnalysis() {
    final subjects = [
      {
        'name': 'Computer Science',
        'avgRating': 4.5,
        'faculty': 8,
        'strength': 'Problem-solving & Logic',
      },
      {
        'name': 'Information Technology',
        'avgRating': 4.3,
        'faculty': 7,
        'strength': 'Practical Application',
      },
      {
        'name': 'Information Systems',
        'avgRating': 4.2,
        'faculty': 5,
        'strength': 'Project Management',
      },
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Faculty Strengths by Subject Area',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...subjects.map(
              (subject) => _buildSubjectStrengthRow(
                subject['name'] as String,
                subject['avgRating'] as double,
                subject['faculty'] as int,
                subject['strength'] as String,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectStrengthRow(
    String subject,
    double avgRating,
    int facultyCount,
    String strength,
  ) {
    Color ratingColor = avgRating >= 4.5
        ? Colors.green
        : avgRating >= 4.0
        ? Colors.lightGreen
        : avgRating >= 3.5
        ? Colors.yellow[700]!
        : Colors.orange;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ratingColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ratingColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$facultyCount faculty members',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Key Strength:',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  strength,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < avgRating.round() ? Icons.star : Icons.star_border,
                    color: Colors.amber[600],
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                avgRating.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ratingColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SemesterTrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Sample data points for different subjects across 3 semesters
    final overallData = [3.8, 4.0, 4.2];
    final csData = [4.2, 4.4, 4.5];
    final itData = [3.9, 4.1, 4.3];
    final seData = [3.7, 4.0, 4.2];

    _drawTrendLine(canvas, size, overallData, Colors.blue, paint);
    _drawTrendLine(canvas, size, csData, Colors.green, paint);
    _drawTrendLine(canvas, size, itData, Colors.orange, paint);
    _drawTrendLine(canvas, size, seData, Colors.purple, paint);
  }

  void _drawTrendLine(
    Canvas canvas,
    Size size,
    List<double> data,
    Color color,
    Paint paint,
  ) {
    paint.color = color;
    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y =
          size.height -
          ((data[i] - 3.5) / 1.0) * size.height; // Scale from 3.5 to 4.5

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Keep the existing classes unchanged
class EvaluationReportsView extends StatelessWidget {
  const EvaluationReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Faculty Evaluation Reports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 32, 42, 68),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 32, 42, 68),
                      child: Text(
                        'F${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text('Faculty Member ${index + 1}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Subject Taught: Computer Science'),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 50,
                              child: Text(
                                'Rating:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < (4 - index % 2)
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber[600],
                                  size: 18,
                                );
                              }),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              (4.5 - (index * 0.2)).toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showDetailedReport(context, index + 1);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedReport(BuildContext context, int facultyNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Faculty Member $facultyNumber - Detailed Report'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Evaluation Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildReportItem('Mastery of Subject Matter', 4.2),
                _buildReportItem('Teaching Methodology', 4.0),
                _buildReportItem('Classroom Management', 4.5),
                _buildReportItem('Student Engagement', 3.8),
                const SizedBox(height: 15),
                const Text(
                  'Overall Rating:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    const SizedBox(width: 50, child: Text('Stars:')),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < 4 ? Icons.star : Icons.star_border,
                          color: Colors.amber[600],
                          size: 20,
                        );
                      }),
                    ),
                    const Text('4.1 - Very Satisfactory'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportItem(String category, double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(category, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating.round() ? Icons.star : Icons.star_border,
                      color: Colors.amber[600],
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
