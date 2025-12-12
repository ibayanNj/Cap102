import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TopPerformingFacultyCard extends StatefulWidget {
  const TopPerformingFacultyCard({super.key});

  @override
  State<TopPerformingFacultyCard> createState() =>
      _TopPerformingFacultyCardState();
}

class _TopPerformingFacultyCardState extends State<TopPerformingFacultyCard> {
  late final Future<List<Map<String, dynamic>>> _getTopFaculty;

  Future<List<Map<String, dynamic>>> _fetchTopFacultyData() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('faculty_evaluations_view')
          .select('name, subject, rating, evaluations')
          .order('rating', ascending: false)
          .limit(4);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint("Error fetching top faculty: $e");
      throw Exception('Failed to load faculty data');
    }
  }

  @override
  void initState() {
    super.initState();
    _getTopFaculty = _fetchTopFacultyData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getTopFaculty,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _buildMessage('Error: ${snapshot.error}', Colors.red);
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildMessage('No top-performing faculty found.');
        }

        final topFaculty = snapshot.data!;
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
                const Text(
                  'Top Performing Faculty',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Current Semester',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                _buildBarChart(topFaculty),
                const SizedBox(height: 20),
                _buildFacultyList(topFaculty),
              ],
            ),
          ),
        );
      },
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

  Widget _buildBarChart(List<Map<String, dynamic>> data) {
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: 5,
          minY: 0,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) => Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  if (value.toInt() >= 0 && value.toInt() < data.length) {
                    final name = data[value.toInt()]['name'] as String;
                    final last = name.split(' ').last;
                    return Text(
                      last,
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: true, horizontalInterval: 1),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            final rating = (entry.value['rating'] as num).toDouble();
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: rating,
                  color: _getColorForRating(rating),
                  width: 28,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFacultyList(List<Map<String, dynamic>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.asMap().entries.map((entry) {
        final faculty = entry.value;
        final rating = (faculty['rating'] as num).toDouble();
        final rank = entry.key + 1;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                '$rank.',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${faculty['name']} — ${faculty['subject']}',
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${rating.toStringAsFixed(1)}/5',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColorForRating(double rating) {
    if (rating >= 4.5) return Colors.amber.shade600;
    if (rating >= 4.0) return Colors.green.shade400;
    if (rating >= 3.5) return Colors.blue.shade400;
    return Colors.red.shade400;
  }
}
