// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class TopPerformingFacultyCard extends StatefulWidget {
//   const TopPerformingFacultyCard({super.key});

//   @override
//   State<TopPerformingFacultyCard> createState() =>
//       _TopPerformingFacultyCardState();
// }

// class _TopPerformingFacultyCardState extends State<TopPerformingFacultyCard> {
//   late final Future<List<Map<String, dynamic>>> _getTopFaculty;

//   Future<List<Map<String, dynamic>>> _fetchTopFacultyData() async {
//     try {
//       final supabase = Supabase.instance.client;

//       // Query to get average weighted scores per faculty
//       final response = await supabase
//           .from('evaluations')
//           .select('faculty_id, faculty_name, course_name, weighted_score')
//           .order('weighted_score', ascending: false);

//       // Group by faculty and calculate average
//       final Map<String, Map<String, dynamic>> facultyData = {};

//       for (var eval in response as List) {
//         final facultyId = eval['faculty_id'] as String;
//         final facultyName = eval['faculty_name'] as String;
//         final courseName = eval['course_name'] as String;
//         final weightedScore = (eval['weighted_score'] as num).toDouble();

//         if (facultyData.containsKey(facultyId)) {
//           // Add to existing faculty
//           facultyData[facultyId]!['total_score'] += weightedScore;
//           facultyData[facultyId]!['count'] += 1;
//           // Keep track of courses (you can modify this logic)
//           if (!facultyData[facultyId]!['courses'].contains(courseName)) {
//             facultyData[facultyId]!['courses'].add(courseName);
//           }
//         } else {
//           // New faculty entry
//           facultyData[facultyId] = {
//             'faculty_id': facultyId,
//             'name': facultyName,
//             'subject': courseName, // Main subject (first course)
//             'courses': [courseName],
//             'total_score': weightedScore,
//             'count': 1,
//           };
//         }
//       }

//       // Calculate averages and format data
//       final List<Map<String, dynamic>> topFaculty = facultyData.values.map((
//         data,
//       ) {
//         final avgScore = data['total_score'] / data['count'];
//         return {
//           'faculty_id': data['faculty_id'],
//           'name': data['name'],
//           'subject': data['subject'],
//           'rating': avgScore,
//           'evaluations': data['count'],
//           'courses': data['courses'],
//         };
//       }).toList();

//       // Sort by rating and get top 4
//       topFaculty.sort(
//         (a, b) => (b['rating'] as double).compareTo(a['rating'] as double),
//       );

//       return topFaculty.take(10).toList();
//     } catch (e) {
//       debugPrint("Error fetching top faculty: $e");
//       throw Exception('Failed to load faculty data');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _getTopFaculty = _fetchTopFacultyData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: _getTopFaculty,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SizedBox(
//             height: 300,
//             child: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (snapshot.hasError) {
//           return _buildMessage('Error: ${snapshot.error}', Colors.red);
//         }

//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return _buildMessage('No top-performing faculty found.');
//         }

//         final topFaculty = snapshot.data!;
//         return Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Top Performing Faculty',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Based on Weighted Score',
//                   style: TextStyle(fontSize: 13, color: Colors.black54),
//                 ),
//                 const SizedBox(height: 20),
//                 _buildBarChart(topFaculty),
//                 const SizedBox(height: 20),
//                 _buildFacultyList(topFaculty),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMessage(String message, [Color color = Colors.black54]) {
//     return Card(
//       elevation: 1,
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Center(
//           child: Text(message, style: TextStyle(color: color)),
//         ),
//       ),
//     );
//   }

//   Widget _buildBarChart(List<Map<String, dynamic>> data) {
//     return SizedBox(
//       height: 220,
//       child: BarChart(
//         BarChartData(
//           maxY: 5,
//           minY: 0,
//           barTouchData: BarTouchData(
//             enabled: true,
//             touchTooltipData: BarTouchTooltipData(
//               getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                 final faculty = data[group.x.toInt()];
//                 return BarTooltipItem(
//                   '${faculty['name']}\n',
//                   const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   children: [
//                     TextSpan(
//                       text: '${faculty['subject']}\n',
//                       style: const TextStyle(fontSize: 11),
//                     ),
//                     TextSpan(
//                       text: '⭐ ${rod.toY.toStringAsFixed(2)}/5.0\n',
//                       style: const TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                     TextSpan(
//                       text: '${faculty['evaluations']} evaluations',
//                       style: const TextStyle(fontSize: 11),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//           titlesData: FlTitlesData(
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 reservedSize: 32,
//                 getTitlesWidget: (value, _) => Text(
//                   value.toStringAsFixed(1),
//                   style: const TextStyle(fontSize: 11),
//                 ),
//               ),
//             ),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 reservedSize: 40,
//                 getTitlesWidget: (value, _) {
//                   if (value.toInt() >= 0 && value.toInt() < data.length) {
//                     final name = data[value.toInt()]['name'] as String;
//                     final last = name.split(' ').last;
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child: Text(
//                         last,
//                         style: const TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ),
//             rightTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             topTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//           ),
//           gridData: FlGridData(
//             show: true,
//             horizontalInterval: 1,
//             drawVerticalLine: false,
//             getDrawingHorizontalLine: (value) {
//               return FlLine(
//                 color: Colors.grey.shade300,
//                 strokeWidth: 1,
//                 dashArray: [5, 5],
//               );
//             },
//           ),
//           borderData: FlBorderData(
//             show: true,
//             border: Border(
//               bottom: BorderSide(color: Colors.grey.shade300),
//               left: BorderSide(color: Colors.grey.shade300),
//             ),
//           ),
//           barGroups: data.asMap().entries.map((entry) {
//             final rating = (entry.value['rating'] as num).toDouble();
//             return BarChartGroupData(
//               x: entry.key,
//               barRods: [
//                 BarChartRodData(
//                   toY: rating,
//                   gradient: LinearGradient(
//                     colors: [
//                       _getColorForRating(rating),
//                       _getColorForRating(rating).withOpacity(0.7),
//                     ],
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                   ),
//                   width: 32,
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(6),
//                   ),
//                   backDrawRodData: BackgroundBarChartRodData(
//                     show: true,
//                     toY: 5,
//                     color: Colors.grey.shade200,
//                   ),
//                 ),
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Widget _buildFacultyList(List<Map<String, dynamic>> data) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.leaderboard, size: 16, color: Colors.grey.shade600),
//               const SizedBox(width: 6),
//               Text(
//                 'Faculty Rankings',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           ...data.asMap().entries.map((entry) {
//             final faculty = entry.value;
//             final rating = (faculty['rating'] as num).toDouble();
//             final rank = entry.key + 1;

//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 24,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       color: _getColorForRating(rating),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Center(
//                       child: Text(
//                         '$rank',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           faculty['name'],
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         Text(
//                           '${faculty['subject']} • ${rating.toStringAsFixed(2)}/5.0',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey.shade600,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(4),
//                       border: Border.all(color: Colors.grey.shade300),
//                     ),
//                     child: Text(
//                       '${faculty['evaluations']} evals',
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.grey.shade700,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   Color _getColorForRating(double rating) {
//     if (rating >= 4.5) return Colors.amber.shade600;
//     if (rating >= 4.0) return Colors.green.shade500;
//     if (rating >= 3.5) return Colors.blue.shade500;
//     if (rating >= 3.0) return Colors.orange.shade500;
//     return Colors.red.shade500;
//   }
// }

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
  int _currentPage = 0;
  static const int _itemsPerPage = 10;

  Future<List<Map<String, dynamic>>> _fetchTopFacultyData() async {
    try {
      final supabase = Supabase.instance.client;

      // Query to get average weighted scores per faculty
      final response = await supabase
          .from('evaluations')
          .select('faculty_id, faculty_name, course_name, weighted_score')
          .order('weighted_score', ascending: false);

      // Group by faculty and calculate average
      final Map<String, Map<String, dynamic>> facultyData = {};

      for (var eval in response as List) {
        final facultyId = eval['faculty_id'] as String;
        final facultyName = eval['faculty_name'] as String;
        final courseName = eval['course_name'] as String;
        final weightedScore = (eval['weighted_score'] as num).toDouble();

        if (facultyData.containsKey(facultyId)) {
          // Add to existing faculty
          facultyData[facultyId]!['total_score'] += weightedScore;
          facultyData[facultyId]!['count'] += 1;
          // Keep track of courses (you can modify this logic)
          if (!facultyData[facultyId]!['courses'].contains(courseName)) {
            facultyData[facultyId]!['courses'].add(courseName);
          }
        } else {
          // New faculty entry
          facultyData[facultyId] = {
            'faculty_id': facultyId,
            'name': facultyName,
            'subject': courseName, // Main subject (first course)
            'courses': [courseName],
            'total_score': weightedScore,
            'count': 1,
          };
        }
      }

      // Calculate averages and format data
      final List<Map<String, dynamic>> topFaculty = facultyData.values.map((
        data,
      ) {
        final avgScore = data['total_score'] / data['count'];
        return {
          'faculty_id': data['faculty_id'],
          'name': data['name'],
          'subject': data['subject'],
          'rating': avgScore,
          'evaluations': data['count'],
          'courses': data['courses'],
        };
      }).toList();

      // Sort by rating
      topFaculty.sort(
        (a, b) => (b['rating'] as double).compareTo(a['rating'] as double),
      );

      return topFaculty; // Return all faculty, we'll paginate in the UI
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

  List<Map<String, dynamic>> _getPaginatedData(
    List<Map<String, dynamic>> allData,
  ) {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, allData.length);

    if (startIndex >= allData.length) return [];

    return allData.sublist(startIndex, endIndex);
  }

  int _getTotalPages(int totalItems) {
    return (totalItems / _itemsPerPage).ceil();
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

        final allFaculty = snapshot.data!;
        final paginatedFaculty = _getPaginatedData(allFaculty);
        final totalPages = _getTotalPages(allFaculty.length);

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
                          'Top Performing Faculty',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Based on Weighted Score (${allFaculty.length} total)',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    _buildPaginationControls(totalPages),
                  ],
                ),
                const SizedBox(height: 20),
                _buildBarChart(paginatedFaculty),
                const SizedBox(height: 20),
                _buildFacultyList(
                  paginatedFaculty,
                  _currentPage * _itemsPerPage,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    final startRange = (_currentPage * _itemsPerPage) + 1;
    final endRange = ((_currentPage + 1) * _itemsPerPage);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$startRange-$endRange',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 20),
          onPressed: _currentPage > 0
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                }
              : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          splashRadius: 20,
        ),
        const SizedBox(width: 4),
        Text(
          '${_currentPage + 1}/$totalPages',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 20),
          onPressed: _currentPage < totalPages - 1
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          splashRadius: 20,
        ),
      ],
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
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final faculty = data[group.x.toInt()];
                return BarTooltipItem(
                  '${faculty['name']}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
          ),
          titlesData: FlTitlesData(
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
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 1,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
              left: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          barGroups: data.asMap().entries.map((entry) {
            final rating = (entry.value['rating'] as num).toDouble();
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: rating,
                  gradient: LinearGradient(
                    colors: [
                      _getColorForRating(rating),
                      _getColorForRating(rating).withOpacity(0.7),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 32,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 5,
                    color: Colors.grey.shade200,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFacultyList(List<Map<String, dynamic>> data, int startRank) {
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
              Icon(Icons.leaderboard, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                'Faculty Rankings',
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
            final faculty = entry.value;
            final rating = (faculty['rating'] as num).toDouble();
            final rank = startRank + entry.key + 1;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getColorForRating(rating),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          faculty['name'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${faculty['subject']} • ${rating.toStringAsFixed(2)}/5.0',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      '${faculty['evaluations']} evals',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
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

  Color _getColorForRating(double rating) {
    if (rating >= 4.5) return Colors.amber.shade600;
    if (rating >= 4.0) return Colors.green.shade500;
    if (rating >= 3.5) return Colors.blue.shade500;
    if (rating >= 3.0) return Colors.orange.shade500;
    return Colors.red.shade500;
  }
}
