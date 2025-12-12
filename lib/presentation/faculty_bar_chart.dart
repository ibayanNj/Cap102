import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FacultyBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const FacultyBarChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final barGroups = _generateBarGroups(data);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: 5,
          minY: 0,
          barTouchData: _buildBarTouchData(data),
          titlesData: _buildTitlesData(data),
          gridData: _buildGridData(),
          borderData: _buildBorderData(),
          barGroups: barGroups,
        ),
      ),
    );
  }

  // ✅ Generate bar groups once (performance optimized)
  List<BarChartGroupData> _generateBarGroups(List<Map<String, dynamic>> data) {
    return data.asMap().entries.map((entry) {
      final rating = (entry.value['rating'] as num).toDouble();
      final color = _getColorForRating(rating);

      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: rating,
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 32,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 5,
              color: Colors.grey.shade200,
            ),
          ),
        ],
      );
    }).toList();
  }

  // ✅ Touch tooltip builder
  BarTouchData _buildBarTouchData(List<Map<String, dynamic>> data) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final faculty = data[group.x.toInt()];
          return BarTooltipItem(
            '${faculty['name']}\n',
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: '${faculty['subject']}\n',
                style: const TextStyle(fontSize: 11),
              ),
              TextSpan(
                text: '⭐ ${rod.toY.toStringAsFixed(2)}/5.0\n',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: '${faculty['evaluations']} evaluations',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✅ Axis titles
  FlTitlesData _buildTitlesData(List<Map<String, dynamic>> data) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (value, _) => Text(
            value.toStringAsFixed(1),
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, _) {
            if (value.toInt() >= 0 && value.toInt() < data.length) {
              final name = data[value.toInt()]['name'] as String;
              final last = name.split(' ').last;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  last,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  // ✅ Grid styling
  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      horizontalInterval: 1,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (value) => FlLine(
        color: Colors.grey.shade300,
        strokeWidth: 1,
        dashArray: [5, 5],
      ),
    );
  }

  // ✅ Border styling
  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border(
        bottom: BorderSide(color: Colors.grey.shade300),
        left: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  // ✅ Efficient color mapping with memoization
  static final Map<double, Color> _colorCache = {};

  Color _getColorForRating(double rating) {
    return _colorCache.putIfAbsent(rating, () {
      if (rating >= 4.5) return Colors.green;
      if (rating >= 3.5) return Colors.lightGreen;
      if (rating >= 2.5) return Colors.orange;
      return Colors.redAccent;
    });
  }
}
