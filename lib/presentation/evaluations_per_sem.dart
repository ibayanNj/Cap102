import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EvaluationsPerSemesterCard extends StatefulWidget {
  const EvaluationsPerSemesterCard({super.key});

  @override
  State<EvaluationsPerSemesterCard> createState() =>
      _EvaluationsPerSemesterCardState();
}

class _EvaluationsPerSemesterCardState
    extends State<EvaluationsPerSemesterCard> {
  late final Future<List<Map<String, dynamic>>> _semesterData;
  bool showAvg = false;

  @override
  void initState() {
    super.initState();
    _semesterData = _fetchSemesterData();
  }

  Future<List<Map<String, dynamic>>> _fetchSemesterData() async {
    try {
      final supabase = Supabase.instance.client;

      // Fetch all evaluations with semester and academic year
      final response = await supabase
          .from('evaluations')
          .select('semester, school_year, created_at')
          .order('school_year', ascending: true)
          .order('semester', ascending: true);

      // Group by semester and academic year
      final Map<String, int> semesterCounts = {};

      for (var eval in response as List) {
        final semester = eval['semester'] as String? ?? 'Unknown';
        final academicYear = eval['school_year'] as String? ?? 'Unknown';
        final key = '$semester $academicYear';

        semesterCounts[key] = (semesterCounts[key] ?? 0) + 1;
      }

      // Convert to list and sort
      final List<Map<String, dynamic>> data = semesterCounts.entries.map((e) {
        return {'semester': e.key, 'count': e.value};
      }).toList();

      // Sort by academic year and semester
      data.sort((a, b) {
        final aStr = a['semester'] as String;
        final bStr = b['semester'] as String;
        return aStr.compareTo(bStr);
      });

      return data;
    } catch (e) {
      debugPrint("Error fetching semester data: $e");
      throw Exception('Failed to load semester data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _semesterData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 400,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _buildMessage('Error: ${snapshot.error}', Colors.red);
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildMessage('No evaluation data found.');
        }

        final semesterData = snapshot.data!;
        final totalEvaluations = semesterData.fold<int>(
          0,
          (sum, item) => sum + (item['count'] as int),
        );

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Evaluations Submitted Per Semester',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: $totalEvaluations evaluations',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${semesterData.length} Semesters',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.70,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 18,
                          left: 12,
                          top: 24,
                          bottom: 12,
                        ),
                        child: LineChart(
                          showAvg
                              ? _avgData(semesterData)
                              : _mainData(semesterData),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      height: 34,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            showAvg = !showAvg;
                          });
                        },
                        child: Text(
                          'avg',
                          style: TextStyle(
                            fontSize: 12,
                            color: showAvg
                                ? Colors.blue.withOpacity(0.5)
                                : Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSemesterList(semesterData),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bottomTitleWidgets(
    double value,
    TitleMeta meta,
    List<Map<String, dynamic>> data,
  ) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 10);

    if (value.toInt() >= 0 && value.toInt() < data.length) {
      final semester = data[value.toInt()]['semester'] as String;
      final parts = semester.split(' ');
      return Text(parts.isNotEmpty ? parts[0] : '', style: style);
    }
    return const Text('');
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 11);

    return Text(
      value.toInt().toString(),
      style: style,
      textAlign: TextAlign.left,
    );
  }

  LineChartData _mainData(List<Map<String, dynamic>> data) {
    final maxCount = data.fold<int>(
      0,
      (max, item) => (item['count'] as int) > max ? item['count'] as int : max,
    );

    final spots = data.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        (entry.value['count'] as int).toDouble(),
      );
    }).toList();

    List<Color> gradientColors = [Colors.cyan, Colors.blue];

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: (maxCount / 5).ceilToDouble(),
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) =>
                _bottomTitleWidgets(value, meta, data),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (maxCount / 5).ceilToDouble(),
            getTitlesWidget: _leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.shade400),
      ),
      minX: 0,
      maxX: (data.length - 1).toDouble(),
      minY: 0,
      maxY: (maxCount * 1.2).toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _avgData(List<Map<String, dynamic>> data) {
    final maxCount = data.fold<int>(
      0,
      (max, item) => (item['count'] as int) > max ? item['count'] as int : max,
    );

    final totalCount = data.fold<int>(
      0,
      (sum, item) => sum + (item['count'] as int),
    );
    final avgCount = totalCount / data.length;

    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), avgCount);
    }).toList();

    List<Color> gradientColors = [Colors.cyan, Colors.blue];

    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: (maxCount / 5).ceilToDouble(),
        getDrawingVerticalLine: (value) {
          return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) =>
                _bottomTitleWidgets(value, meta, data),
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: _leftTitleWidgets,
            reservedSize: 42,
            interval: (maxCount / 5).ceilToDouble(),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.shade400),
      ),
      minX: 0,
      maxX: (data.length - 1).toDouble(),
      minY: 0,
      maxY: (maxCount * 1.2).toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(
                begin: gradientColors[0],
                end: gradientColors[1],
              ).lerp(0.2)!,
              ColorTween(
                begin: gradientColors[0],
                end: gradientColors[1],
              ).lerp(0.2)!,
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(
                  begin: gradientColors[0],
                  end: gradientColors[1],
                ).lerp(0.2)!.withOpacity(0.1),
                ColorTween(
                  begin: gradientColors[0],
                  end: gradientColors[1],
                ).lerp(0.2)!.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterList(List<Map<String, dynamic>> data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                'Semester Details',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...data.asMap().entries.map((entry) {
            final index = entry.key;
            final semester = entry.value['semester'] as String;
            final count = entry.value['count'] as int;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getColorForIndex(index),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      semester,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getColorForIndex(index).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getColorForIndex(index).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getColorForIndex(index),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMessage(String message, [Color color = Colors.black54]) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(message, style: TextStyle(color: color)),
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.teal.shade600,
      Colors.pink.shade600,
      Colors.indigo.shade600,
      Colors.amber.shade600,
    ];
    return colors[index % colors.length];
  }
}
