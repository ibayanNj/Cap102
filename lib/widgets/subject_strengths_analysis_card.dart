import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubjectStrengthsAnalysisCard extends StatefulWidget {
  const SubjectStrengthsAnalysisCard({super.key});

  @override
  State<SubjectStrengthsAnalysisCard> createState() =>
      _SubjectStrengthsAnalysisCardState();
}

class _SubjectStrengthsAnalysisCardState
    extends State<SubjectStrengthsAnalysisCard> {
  // --- State Variables (Unchanged) ---
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSubjectData(); // Fetch data when the widget is first created
  }

  /// --- Helper function to parse color string (Unchanged) ---
  Color _parseColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', '').replaceFirst('0x', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  /// --- Fetches data from Supabase (Unchanged) ---
  Future<void> _fetchSubjectData() async {
    try {
      final supabase = Supabase.instance.client;
      final List<dynamic> data = await supabase
          .from('subject_strengths') // <-- YOUR TABLE NAME
          .select('name, avg_rating, faculty_count, strength, color_hex');

      final subjects = data.map((item) {
        return {
          'name': item['name'] as String,
          'avgRating': (item['avg_rating'] as num).toDouble(),
          'faculty': item['faculty_count'] as int,
          'strength': item['strength'] as String,
          'color': _parseColor(item['color_hex'] as String), // Parse color
        };
      }).toList();

      subjects.sort(
        (a, b) =>
            (b['avgRating'] as double).compareTo(a['avgRating'] as double),
      );

      if (mounted) {
        setState(() {
          _subjects = subjects;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Handle Loading and Error States (Simplified UI) ---
    if (_isLoading) {
      return const Card(
        child: SizedBox(
          height: 300,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null) {
      return Card(
        color: Colors.red.shade50,
        child: SizedBox(
          height: 300,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red.shade800),
              ),
            ),
          ),
        ),
      );
    }

    if (_subjects.isEmpty) {
      return const Card(
        child: SizedBox(
          height: 300,
          child: Center(child: Text('No data found.')),
        ),
      );
    }

    // --- Build Logic (Simplified) ---
    // Removed LayoutBuilder for simplicity
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withAlpha(30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 45),
            Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
              ), // 👈 Added extra top padding
              child: _buildBarChart(_subjects),
            ),
          ],
        ),
      ),
    );
  }

  /// --- SIMPLIFIED ---
  /// Uses simple text widgets instead of icons and colored boxes
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Faculty Strengths by Subject',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          'Average faculty ratings across departments',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> subjects) {
    const minBarWidth = 40.0;
    final totalBarWidth = subjects.length * (minBarWidth + 20.0);
    // Get the available screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine the chart width:
    // - If there are only a few bars, fill the screen.
    // - If there are many, make it scrollable.
    final chartWidth = totalBarWidth < screenWidth
        ? screenWidth
        : totalBarWidth;

    // Adjust height for mobile/tablet
    final chartHeight = screenWidth < 600 ? 220.0 : 300.0;

    return SizedBox(
      height: chartHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: chartWidth,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 5.2,
              minY: 0,
              barTouchData: _buildBarTouchData(),
              titlesData: _buildTitlesData(subjects),
              gridData: _buildGridData(),
              borderData: _buildBorderData(),
              barGroups: _buildBarGroups(subjects),
            ),
          ),
        ),
      ),
    );
  }

  /// --- SIMPLIFIED ---
  /// Tooltips are disabled for a minimal look
  BarTouchData _buildBarTouchData() {
    return BarTouchData(enabled: false);
  }

  /// --- SIMPLIFIED ---
  /// Shows simpler titles. Left axis shows whole numbers.
  /// Bottom axis shows only the first word of the subject.
  FlTitlesData _buildTitlesData(List<Map<String, dynamic>> subjects) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTitlesWidget: (value, meta) {
            if (value.toInt() >= 0 && value.toInt() < subjects.length) {
              final name = subjects[value.toInt()]['name'] as String;
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  name.split(' ').first, // Just the first word
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 25,
          interval: 1,
          getTitlesWidget: (value, meta) {
            // Show only whole numbers
            if (value == 0 ||
                value == 1 ||
                value == 2 ||
                value == 3 ||
                value == 4 ||
                value == 5) {
              return Text(
                value.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  /// --- SIMPLIFIED ---
  /// No grid lines
  FlGridData _buildGridData() {
    return FlGridData(show: false);
  }

  /// --- SIMPLIFIED ---
  /// No chart border
  FlBorderData _buildBorderData() {
    return FlBorderData(show: false);
  }

  /// --- SIMPLIFIED ---
  /// Uses a solid color (from your data) instead of a gradient
  /// and removes the background bar.
  List<BarChartGroupData> _buildBarGroups(List<Map<String, dynamic>> subjects) {
    return subjects.asMap().entries.map((entry) {
      final index = entry.key;
      final subject = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: subject['avgRating'] as double,
            color: subject['color'] as Color, // <-- Solid color
            width: 24, // Slightly slimmer
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: false, // <-- Hides background bar
            ),
          ),
        ],
      );
    }).toList();
  }
}
