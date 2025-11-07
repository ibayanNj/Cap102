import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SemesterTrendChart extends StatefulWidget {
  const SemesterTrendChart({super.key});

  @override
  State<SemesterTrendChart> createState() => _SemesterTrendChartState();
}

class _SemesterTrendChartState extends State<SemesterTrendChart> {
  bool _isLoading = true;
  String? _error;

  List<String> _semesters = [];
  Map<String, List<double>> _trendData = {};
  List<String> _programs = [];

  @override
  void initState() {
    super.initState();
    _fetchTrendData();
  }

  Future<void> _fetchTrendData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final supabase = Supabase.instance.client;

      // Fetch evaluations with weighted scores grouped by semester and program
      final response = await supabase
          .from('evaluations')
          .select('semester, school_year, course_name, weighted_score')
          .order('school_year')
          .order('semester');

      // Process data
      final Map<String, Map<String, List<double>>> semesterProgramScores = {};
      final Set<String> uniqueSemesters = {};
      final Set<String> uniquePrograms = {};

      for (var record in response) {
        final semester = '${record['semester']} ${record['school_year']}';
        final courseName = record['course_name'] as String? ?? 'Unknown';
        final score = (record['weighted_score'] as num?)?.toDouble() ?? 0.0;

        // Determine program from course name
        String program = _determineProgram(courseName);

        uniqueSemesters.add(semester);
        uniquePrograms.add(program);

        semesterProgramScores.putIfAbsent(semester, () => {});
        semesterProgramScores[semester]!.putIfAbsent(program, () => []);
        semesterProgramScores[semester]![program]!.add(score);
      }

      // Sort semesters chronologically
      final sortedSemesters = uniqueSemesters.toList()..sort(_compareSemesters);
      final sortedPrograms = uniquePrograms.toList()..sort();

      // Calculate average scores per semester per program
      final Map<String, List<double>> trendData = {};

      // Add overall trend
      trendData['Overall'] = [];
      for (var semester in sortedSemesters) {
        final allScores = semesterProgramScores[semester]!.values
            .expand((scores) => scores)
            .toList();
        final avg = allScores.isEmpty
            ? 0.0
            : allScores.reduce((a, b) => a + b) / allScores.length;
        trendData['Overall']!.add(avg);
      }

      // Add program-specific trends
      for (var program in sortedPrograms) {
        trendData[program] = [];
        for (var semester in sortedSemesters) {
          final scores = semesterProgramScores[semester]![program] ?? [];
          final avg = scores.isEmpty
              ? 0.0
              : scores.reduce((a, b) => a + b) / scores.length;
          trendData[program]!.add(avg);
        }
      }

      setState(() {
        _semesters = sortedSemesters;
        _trendData = trendData;
        _programs = ['Overall', ...sortedPrograms];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading trend data: $e';
        _isLoading = false;
      });
    }
  }

  String _determineProgram(String courseName) {
    final lowerCourseName = courseName.toLowerCase();
    if (lowerCourseName.contains('cs') ||
        lowerCourseName.contains('computer science')) {
      return 'Computer Science';
    } else if (lowerCourseName.contains('it') ||
        lowerCourseName.contains('information tech')) {
      return 'Information Tech';
    } else if (lowerCourseName.contains('se') ||
        lowerCourseName.contains('software eng')) {
      return 'Software Engineering';
    } else if (lowerCourseName.contains('itp') ||
        lowerCourseName.contains('integrative')) {
      return 'Information Tech'; // ITP courses belong to IT
    }
    return 'Other';
  }

  int _compareSemesters(String a, String b) {
    // Parse "1st Semester 2024-2025" format
    final regExp = RegExp(r'(\d+)(st|nd|rd|th) Semester (\d{4})-(\d{4})');
    final matchA = regExp.firstMatch(a);
    final matchB = regExp.firstMatch(b);

    if (matchA == null || matchB == null) return a.compareTo(b);

    final yearA = int.parse(matchA.group(3)!);
    final yearB = int.parse(matchB.group(3)!);
    final semA = int.parse(matchA.group(1)!);
    final semB = int.parse(matchB.group(1)!);

    if (yearA != yearB) return yearA.compareTo(yearB);
    return semA.compareTo(semB);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _error != null
                ? _buildError()
                : _semesters.isEmpty
                ? _buildEmptyState()
                : _buildChart(),
            if (!_isLoading && _error == null && _semesters.isNotEmpty) ...[
              const Divider(height: 24, thickness: 1, color: Color(0xFFE5E7EB)),
              _buildLegend(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Rating progression across semesters',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        if (!_isLoading)
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _fetchTrendData,
            tooltip: 'Refresh data',
          ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error ?? 'An error occurred',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchTrendData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No evaluation data available yet',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildChart() {
  //   final dataPointCount = _semesters.length;
  //   final chartWidth = (dataPointCount * 150.0).clamp(500.0, double.infinity);

  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: SizedBox(
  //       width: chartWidth,
  //       height: 300,
  //       child: LineChart(
  //         LineChartData(
  //           minY: 0.0,
  //           maxY: 5.0,
  //           minX: 0,
  //           maxX: (dataPointCount - 1).toDouble() + 0.5,
  //           lineTouchData: _buildLineTouchData(),
  //           gridData: _buildGridData(),
  //           titlesData: _buildTitlesData(),
  //           borderData: FlBorderData(show: false),
  //           lineBarsData: _buildLineBarsData(),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildChart() {
  //   final dataPointCount = _semesters.length;
  //   final chartWidth = (dataPointCount * 150.0).clamp(500.0, double.infinity);

  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: SizedBox(
  //       width: chartWidth,
  //       height: 300,
  //       child: LineChart(
  //         LineChartData(
  //           minY: 0.0,
  //           maxY: 5.0,
  //           minX: 0,
  //           maxX: (dataPointCount - 1).toDouble(),
  //           lineTouchData: _buildLineTouchData(),
  //           gridData: _buildGridData(),
  //           titlesData: _buildTitlesData(),
  //           borderData: FlBorderData(show: false),
  //           lineBarsData: _buildLineBarsData(),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dataPointCount = _semesters.length;
        final availableWidth = constraints.maxWidth;
        final isSmallScreen = availableWidth < 600;

        // Calculate minimum width needed for comfortable spacing
        final minWidthPerPoint = isSmallScreen ? 100.0 : 150.0;
        final calculatedWidth = dataPointCount * minWidthPerPoint;
        final needsScroll = calculatedWidth > availableWidth;
        final chartWidth = needsScroll ? calculatedWidth : availableWidth;
        final chartHeight = isSmallScreen ? 250.0 : 300.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            height: chartHeight,
            child: LineChart(
              LineChartData(
                minY: 0.0,
                maxY: 5.0,
                minX: 0,
                maxX: (dataPointCount).toDouble(),
                lineTouchData: _buildLineTouchData(),
                gridData: _buildGridData(),
                titlesData: _buildTitlesData(),
                borderData: FlBorderData(show: false),
                lineBarsData: _buildLineBarsData(),
              ),
            ),
          ),
        );
      },
    );
  }

  LineTouchData _buildLineTouchData() {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBorder: const BorderSide(color: Colors.transparent),
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final label = _programs[spot.barIndex];
            return LineTooltipItem(
              '$label: ${spot.y.toStringAsFixed(2)}',
              TextStyle(
                color: Colors.white,
                fontWeight: spot.barIndex == 0
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 12,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 0.5,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey.shade200,
          strokeWidth: 1,
          dashArray: [4, 4],
        );
      },
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        axisNameWidget: const Text(
          'Semester',
          style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < _semesters.length) {
              final semester = _semesters[index];
              Widget textWidget = Text(
                semester,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              );

              if (index == _semesters.length - 1) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, right: 10),
                    child: textWidget,
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: textWidget,
              );
            }
            return const Text('');
          },
        ),
      ),
      leftTitles: AxisTitles(
        axisNameWidget: const Text(
          'Mean Rating',
          style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 0.5,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<LineChartBarData> _buildLineBarsData() {
    const colors = [
      Color(0xFF3B82F6), // Blue - Overall
      Color(0xFF10B981), // Green
      Color(0xFFF59E0B), // Orange
      Color(0xFF8B5CF6), // Purple
      Color(0xFFEC4899), // Pink
      Color(0xFF14B8A6), // Teal
    ];

    final List<LineChartBarData> lines = [];

    for (int i = 0; i < _programs.length; i++) {
      final program = _programs[i];
      final scores = _trendData[program] ?? [];

      final spots = scores.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value);
      }).toList();

      if (spots.isNotEmpty) {
        lines.add(_buildLineChartBarData(spots, colors[i % colors.length]));
      }
    }

    return lines;
  }

  LineChartBarData _buildLineChartBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 1.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true, getDotPainter: _getDotPainter),
      belowBarData: BarAreaData(show: false),
      preventCurveOverShooting: false,
      curveSmoothness: 0.35,
    );
  }

  static FlDotPainter _getDotPainter(
    FlSpot spot,
    double percent,
    LineChartBarData barData,
    int index,
  ) {
    return FlDotCirclePainter(
      radius: 3,
      color: barData.color ?? Colors.blue,
      strokeWidth: 0,
    );
  }

  Widget _buildLegend() {
    const colors = [
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF14B8A6),
    ];

    return Wrap(
      spacing: 24,
      runSpacing: 8,
      children: _programs.asMap().entries.map((entry) {
        return _buildLegendItem(entry.value, colors[entry.key % colors.length]);
      }).toList(),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
