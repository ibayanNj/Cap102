// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:flutter/services.dart' show rootBundle;

// class EvaluationReportsView extends StatefulWidget {
//   const EvaluationReportsView({super.key});

//   @override
//   State<EvaluationReportsView> createState() => _EvaluationReportsViewState();
// }

// class _EvaluationReportsViewState extends State<EvaluationReportsView> {
//   final supabase = Supabase.instance.client;
//   bool _isLoading = false;
//   String _selectedSemester = '1st';
//   String _selectedSchoolYear = '2024-2025';

//   // Section criteria
//   static const List<String> sectionACriteria = [
//     'Presents lesson logically',
//     'Relates lesson to local/national issues',
//     'Provides explanation beyond the content of the book',
//     'Teaches independent of notes',
//   ];

//   static const List<String> sectionBCriteria = [
//     'Uses motivation techniques that elicit student\'s interest',
//     'Links the past with the present lesson',
//     'Uses varied strategies suited to the student\'s needs',
//     'Asks varied types of questions',
//     'Anticipates difficulties of students',
//     'Provides appropriate reinforcement to student\'s responses',
//     'Utilizes multiple sources of information',
//     'Encourages maximum student\'s participation',
//     'Integrates values in the lesson',
//     'Provides opportunities for free expression of ideas',
//   ];

//   static const List<String> sectionCCriteria = [
//     'Speaks in a well-modulated voice',
//     'Uses language appropriate to the level of the class',
//     'Pronounces words correctly',
//     'Observes correct grammar in both speaking and writing',
//     'Encourages students to speak and write',
//     'Listens attentively to student\'s response',
//   ];

//   static const List<String> sectionDCriteria = [
//     'Evaluates student\'s achievement based on the day\'s lesson',
//     'Utilizes appropriate assessment tools and techniques',
//   ];

//   static const List<String> sectionECriteria = [
//     'Maintains discipline (e.g. Keeps student\' task)',
//     'Manages time profitably through curriculum-related activities',
//     'Maximizes use of resources',
//     'Maintains good rapport with the students',
//     'Shows respect for individual student\'s limitations',
//   ];

//   Future<List<Map<String, dynamic>>> _fetchFacultyData() async {
//     try {
//       final response = await supabase
//           .from('evaluations')
//           .select(
//             'faculty_id, faculty_name, weighted_score, '
//             'mastery_1, mastery_2, mastery_3, mastery_4, '
//             'instructional_1, instructional_2, instructional_3, instructional_4, instructional_5, '
//             'instructional_6, instructional_7, instructional_8, instructional_9, instructional_10, '
//             'communication_1, communication_2, communication_3, communication_4, communication_5, communication_6, '
//             'evaluation_1, evaluation_2, '
//             'classroom_1, classroom_2, classroom_3, classroom_4, classroom_5, '
//             'course_id',
//           )
//           .order('created_at', ascending: false);

//       final Map<String, List<Map<String, dynamic>>> groupedByFaculty = {};

//       for (var evaluation in response as List) {
//         final facultyId = evaluation['faculty_id'] as String;
//         if (!groupedByFaculty.containsKey(facultyId)) {
//           groupedByFaculty[facultyId] = [];
//         }
//         groupedByFaculty[facultyId]!.add(evaluation);
//       }

//       final List<Map<String, dynamic>> facultyList = [];

//       groupedByFaculty.forEach((facultyId, evaluations) {
//         final count = evaluations.length;

//         // Calculate average for each criterion
//         double calculateCriterionAvg(String field) {
//           try {
//             return evaluations
//                     .map((e) => (e[field] as num?)?.toDouble() ?? 0.0)
//                     .reduce((a, b) => a + b) /
//                 count;
//           } catch (e) {
//             return 0.0;
//           }
//         }

//         String facultyName =
//             evaluations.first['faculty_name'] ?? 'Unknown Faculty';

//         // Calculate averages for all criteria
//         final Map<String, double> criteriaScores = {};

//         // Mastery criteria
//         for (int i = 1; i <= 4; i++) {
//           criteriaScores['mastery_$i'] = calculateCriterionAvg('mastery_$i');
//         }

//         // Instructional criteria
//         for (int i = 1; i <= 10; i++) {
//           criteriaScores['instructional_$i'] = calculateCriterionAvg(
//             'instructional_$i',
//           );
//         }

//         // Communication criteria
//         for (int i = 1; i <= 6; i++) {
//           criteriaScores['communication_$i'] = calculateCriterionAvg(
//             'communication_$i',
//           );
//         }

//         // Evaluation criteria
//         for (int i = 1; i <= 2; i++) {
//           criteriaScores['evaluation_$i'] = calculateCriterionAvg(
//             'evaluation_$i',
//           );
//         }

//         // Classroom criteria
//         for (int i = 1; i <= 5; i++) {
//           criteriaScores['classroom_$i'] = calculateCriterionAvg(
//             'classroom_$i',
//           );
//         }

//         // Calculate weighted score average
//         double avgWeightedScore = calculateCriterionAvg('weighted_score');

//         facultyList.add({
//           'faculty_id': facultyId,
//           'faculty_name': facultyName,
//           'evaluation_count': count,
//           'avg_weighted_score': avgWeightedScore,
//           'course_id': evaluations.first['course_id'],
//           ...criteriaScores,
//         });
//       });

//       return facultyList;
//     } catch (e) {
//       debugPrint('Error fetching faculty data: $e');
//       rethrow;
//     }
//   }

//   Future<void> _generatePDF() async {
//     setState(() => _isLoading = true);

//     try {
//       final facultyData = await _fetchFacultyData();
//       final pdf = pw.Document();

//       final arial = pw.Font.ttf(await rootBundle.load("fonts/arial.ttf"));
//       final theme = pw.ThemeData.withFont(base: arial);

//       final catsuLogo = pw.MemoryImage(
//         (await rootBundle.load('images/catsu_png.png')).buffer.asUint8List(),
//       );
//       final tuvLogo = pw.MemoryImage(
//         (await rootBundle.load('images/tuv_png.png')).buffer.asUint8List(),
//       );

//       // Page 1: Header + Sections A and B
//       pdf.addPage(
//         pw.Page(
//           theme: theme,
//           pageFormat: PdfPageFormat.a4.landscape,
//           margin: pw.EdgeInsets.only(
//             left: 0.7 * PdfPageFormat.inch,
//             right: 0.7 * PdfPageFormat.inch,
//             top: 20,
//             bottom: 20,
//           ),
//           build: (context) => pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               _buildHeader(
//                 _selectedSemester,
//                 _selectedSchoolYear,
//                 catsuLogo,
//                 tuvLogo,
//               ),
//               pw.SizedBox(height: 15),
//               _buildSection(
//                 'A. Mastery of Subject-Matter (25%)',
//                 sectionACriteria,
//                 facultyData,
//                 'mastery',
//                 4,
//                 0.25,
//               ),
//               pw.SizedBox(height: 15),
//               _buildSection(
//                 'B. Instructional Skills (25%)',
//                 sectionBCriteria,
//                 facultyData,
//                 'instructional',
//                 10,
//                 0.25,
//               ),
//             ],
//           ),
//         ),
//       );

//       // Page 2: Sections C, D, E and Overall
//       pdf.addPage(
//         pw.Page(
//           theme: theme,
//           pageFormat: PdfPageFormat.a4.landscape,
//           margin: pw.EdgeInsets.only(
//             left: 0.7 * PdfPageFormat.inch,
//             right: 0.7 * PdfPageFormat.inch,
//             top: 20,
//             bottom: 20,
//           ),
//           build: (context) => pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               _buildSection(
//                 'C. Communication Skills (20%)',
//                 sectionCCriteria,
//                 facultyData,
//                 'communication',
//                 6,
//                 0.20,
//               ),
//               pw.SizedBox(height: 15),
//               _buildSection(
//                 'D. Evaluation Techniques (15%)',
//                 sectionDCriteria,
//                 facultyData,
//                 'evaluation',
//                 2,
//                 0.15,
//               ),
//               pw.SizedBox(height: 15),
//               _buildSection(
//                 'E. Classroom Management Skills (15%)',
//                 sectionECriteria,
//                 facultyData,
//                 'classroom',
//                 5,
//                 0.15,
//               ),
//               pw.SizedBox(height: 15),
//               _buildOverallMeanTable(facultyData),
//               pw.Spacer(),
//               _buildFooter(),
//             ],
//           ),
//         ),
//       );

//       await Printing.layoutPdf(onLayout: (format) async => pdf.save());
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   pw.Widget _buildHeader(
//     String semester,
//     String schoolYear,
//     pw.ImageProvider catsuLogo,
//     pw.ImageProvider tuvLogo,
//   ) {
//     return pw.Column(
//       children: [
//         pw.Row(
//           crossAxisAlignment: pw.CrossAxisAlignment.center,
//           children: [
//             pw.Container(
//               width: 50,
//               height: 50,
//               child: pw.Image(catsuLogo, fit: pw.BoxFit.contain),
//             ),
//             pw.SizedBox(width: 15),
//             pw.Expanded(
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     'Republic of the Philippines',
//                     style: pw.TextStyle(
//                       fontSize: 10,
//                       fontStyle: pw.FontStyle.italic,
//                     ),
//                   ),
//                   pw.Text(
//                     'CATANDUANES STATE UNIVERSITY',
//                     style: pw.TextStyle(
//                       fontSize: 14,
//                       fontWeight: pw.FontWeight.bold,
//                       color: PdfColors.grey800,
//                     ),
//                   ),
//                   pw.Text(
//                     'Virac, Catanduanes',
//                     style: pw.TextStyle(
//                       fontSize: 10,
//                       fontStyle: pw.FontStyle.italic,
//                       decoration: pw.TextDecoration.underline,
//                       decorationColor: PdfColors.red,
//                       decorationThickness: 2,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             pw.SizedBox(width: 15),
//             pw.Container(
//               width: 100,
//               height: 100,
//               child: pw.Image(tuvLogo, fit: pw.BoxFit.contain),
//             ),
//           ],
//         ),
//         pw.SizedBox(height: 8),
//         pw.Container(
//           height: 3,
//           decoration: const pw.BoxDecoration(color: PdfColors.blue800),
//         ),
//         pw.SizedBox(height: 4),
//         pw.Container(
//           alignment: pw.Alignment.centerLeft,
//           child: pw.Text(
//             'College of Information and Communications Technology',
//             style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
//           ),
//         ),
//         pw.SizedBox(height: 10),
//         pw.Text(
//           'SUMMARY OF FACULTY OBSERVATION',
//           style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
//           textAlign: pw.TextAlign.center,
//         ),
//         pw.SizedBox(height: 4),
//         pw.Text(
//           'LECTURE CLASS',
//           style: const pw.TextStyle(fontSize: 10),
//           textAlign: pw.TextAlign.center,
//         ),
//         pw.Text(
//           '$semester SEMESTER SCHOOL YEAR $schoolYear',
//           style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
//           textAlign: pw.TextAlign.center,
//         ),
//       ],
//     );
//   }

//   pw.Widget _buildSection(
//     String title,
//     List<String> criteria,
//     List<Map<String, dynamic>> facultyData,
//     String criterionPrefix,
//     int criterionCount,
//     double weight,
//   ) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text(
//           title,
//           style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
//         ),
//         pw.SizedBox(height: 5),
//         pw.Table(
//           border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
//           columnWidths: {0: const pw.FixedColumnWidth(150)},
//           children: [
//             // Header Row
//             pw.TableRow(
//               decoration: const pw.BoxDecoration(color: PdfColors.grey300),
//               children: [
//                 _buildCell('Criteria', bold: true, fontSize: 7),
//                 ...facultyData.map(
//                   (f) => _buildCell(
//                     (f['faculty_name'] as String).toUpperCase(),
//                     bold: true,
//                     fontSize: 6,
//                     center: true,
//                   ),
//                 ),
//               ],
//             ),
//             // Criteria Rows - showing individual criterion scores
//             ...List.generate(criterionCount, (index) {
//               return pw.TableRow(
//                 children: [
//                   _buildCell('${index + 1}. ${criteria[index]}', fontSize: 6),
//                   ...facultyData.map((f) {
//                     final score =
//                         (f['${criterionPrefix}_${index + 1}'] as num?)
//                             ?.toDouble() ??
//                         0.0;
//                     return _buildCell(
//                       score.toStringAsFixed(2),
//                       fontSize: 6,
//                       center: true,
//                     );
//                   }),
//                 ],
//               );
//             }),
//             // Total Row
//             pw.TableRow(
//               decoration: const pw.BoxDecoration(color: PdfColors.blue200),
//               children: [
//                 _buildCell('TOTAL:', bold: true, fontSize: 7, alignRight: true),
//                 ...facultyData.map((f) {
//                   double total = 0.0;
//                   for (int i = 1; i <= criterionCount; i++) {
//                     total +=
//                         (f['${criterionPrefix}_$i'] as num?)?.toDouble() ?? 0.0;
//                   }
//                   return _buildCell(
//                     total.toStringAsFixed(2),
//                     bold: true,
//                     fontSize: 6,
//                     center: true,
//                   );
//                 }),
//               ],
//             ),
//             // Mean Row
//             pw.TableRow(
//               decoration: const pw.BoxDecoration(color: PdfColors.blue300),
//               children: [
//                 _buildCell('MEAN:', bold: true, fontSize: 7, alignRight: true),
//                 ...facultyData.map((f) {
//                   double total = 0.0;
//                   for (int i = 1; i <= criterionCount; i++) {
//                     total +=
//                         (f['${criterionPrefix}_$i'] as num?)?.toDouble() ?? 0.0;
//                   }
//                   final mean = total / criterionCount;
//                   return _buildCell(
//                     mean.toStringAsFixed(2),
//                     fontSize: 6,
//                     center: true,
//                   );
//                 }),
//               ],
//             ),
//             // Weighted Mean Row
//             pw.TableRow(
//               decoration: const pw.BoxDecoration(color: PdfColors.blue300),
//               children: [
//                 _buildCell(
//                   'Wtd. Mean:',
//                   bold: true,
//                   fontSize: 7,
//                   alignRight: true,
//                 ),
//                 ...facultyData.map((f) {
//                   double total = 0.0;
//                   for (int i = 1; i <= criterionCount; i++) {
//                     total +=
//                         (f['${criterionPrefix}_$i'] as num?)?.toDouble() ?? 0.0;
//                   }
//                   final mean = total / criterionCount;
//                   final weightedMean = mean * weight;
//                   return _buildCell(
//                     weightedMean.toStringAsFixed(4),
//                     fontSize: 6,
//                     center: true,
//                   );
//                 }),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   pw.Widget _buildOverallMeanTable(List<Map<String, dynamic>> facultyData) {
//     return pw.Table(
//       border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
//       columnWidths: {0: const pw.FixedColumnWidth(150)},
//       children: [
//         pw.TableRow(
//           decoration: const pw.BoxDecoration(color: PdfColors.grey300),
//           children: [
//             _buildCell('Overall Mean/Desc.Equiv', bold: true, fontSize: 8),
//             ...facultyData.map((f) {
//               final overallMean =
//                   (f['avg_weighted_score'] as num?)?.toDouble() ?? 0.0;
//               return _buildCell(
//                 overallMean.toStringAsFixed(4),
//                 bold: true,
//                 fontSize: 7,
//                 center: true,
//               );
//             }),
//           ],
//         ),
//       ],
//     );
//   }

//   pw.Widget _buildCell(
//     String text, {
//     bool bold = false,
//     double fontSize = 8,
//     bool center = false,
//     bool alignRight = false,
//   }) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(4),
//       child: pw.Align(
//         alignment: alignRight
//             ? pw.Alignment.centerRight
//             : (center ? pw.Alignment.center : pw.Alignment.centerLeft),
//         child: pw.Text(
//           text,
//           style: pw.TextStyle(
//             fontSize: fontSize,
//             fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }

//   pw.Widget _buildFooter() {
//     return pw.Row(
//       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//       children: [
//         pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text('Prepared by:', style: const pw.TextStyle(fontSize: 8)),
//             pw.SizedBox(height: 20),
//             pw.Text(
//               'ASTER VIVIEN C. VARGAS, MSIT',
//               style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
//             ),
//             pw.Text(
//               'Department Chairperson, Computing Programs',
//               style: const pw.TextStyle(fontSize: 7),
//             ),
//           ],
//         ),
//         pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text('Noted:', style: const pw.TextStyle(fontSize: 8)),
//             pw.SizedBox(height: 20),
//             pw.Text(
//               'MARIA CONCEPCION S. VERA, DIT',
//               style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
//             ),
//             pw.Text('CICT Dean', style: const pw.TextStyle(fontSize: 7)),
//           ],
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Faculty Evaluation Reports',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Color.fromARGB(255, 32, 42, 68),
//                 ),
//               ),
//               Row(
//                 children: [
//                   // Semester Dropdown
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: DropdownButton<String>(
//                       value: _selectedSemester,
//                       underline: const SizedBox(),
//                       items: ['1st', '2nd'].map((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text('$value Semester'),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         if (newValue != null) {
//                           setState(() => _selectedSemester = newValue);
//                         }
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   // School Year Dropdown
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: DropdownButton<String>(
//                       value: _selectedSchoolYear,
//                       underline: const SizedBox(),
//                       items: ['2023-2024', '2024-2025', '2025-2026'].map((
//                         String value,
//                       ) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text('SY $value'),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         if (newValue != null) {
//                           setState(() => _selectedSchoolYear = newValue);
//                         }
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   ElevatedButton.icon(
//                     onPressed: _isLoading ? null : _generatePDF,
//                     icon: _isLoading
//                         ? const SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Icon(Icons.picture_as_pdf),
//                     label: Text(_isLoading ? 'Generating...' : 'Generate PDF'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 32, 42, 68),
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.assessment_outlined,
//                     size: 64,
//                     color: Colors.grey[400],
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Select semester and school year, then click Generate PDF',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'The PDF will include all faculty evaluations from the database',
//                     style: TextStyle(color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:flutter/services.dart' show rootBundle;

// class EvaluationReportsView extends StatefulWidget {
//   const EvaluationReportsView({super.key});

//   @override
//   State<EvaluationReportsView> createState() => _EvaluationReportsViewState();
// }

// class _EvaluationReportsViewState extends State<EvaluationReportsView> {
//   final supabase = Supabase.instance.client;
//   bool _isLoading = false;
//   String _selectedSemester = '1st';
//   String _selectedSchoolYear = '2024-2025';

//   // Section criteria
//   static const List<String> sectionACriteria = [
//     'Presents lesson logically',
//     'Relates lesson to local/national issues',
//     'Provides explanation beyond the content of the book',
//     'Teaches independent of notes',
//   ];

//   static const List<String> sectionBCriteria = [
//     'Uses motivation techniques that elicit student\'s interest',
//     'Links the past with the present lesson',
//     'Uses varied strategies suited to the student\'s needs',
//     'Asks varied types of questions',
//     'Anticipates difficulties of students',
//     'Provides appropriate reinforcement to student\'s responses',
//     'Utilizes multiple sources of information',
//     'Encourages maximum student\'s participation',
//     'Integrates values in the lesson',
//     'Provides opportunities for free expression of ideas',
//   ];

//   static const List<String> sectionCCriteria = [
//     'Speaks in a well-modulated voice',
//     'Uses language appropriate to the level of the class',
//     'Pronounces words correctly',
//     'Observes correct grammar in both speaking and writing',
//     'Encourages students to speak and write',
//     'Listens attentively to student\'s response',
//   ];

//   static const List<String> sectionDCriteria = [
//     'Evaluates student\'s achievement based on the day\'s lesson',
//     'Utilizes appropriate assessment tools and techniques',
//   ];

//   static const List<String> sectionECriteria = [
//     'Maintains discipline (e.g. Keeps student\' task)',
//     'Manages time profitably through curriculum-related activities',
//     'Maximizes use of resources',
//     'Maintains good rapport with the students',
//     'Shows respect for individual student\'s limitations',
//   ];

//   Future<List<Map<String, dynamic>>> _fetchFacultyData() async {
//     try {
//       final response = await supabase
//           .from('evaluations')
//           .select(
//             'faculty_id, faculty_name, weighted_score, '
//             'mastery_1, mastery_2, mastery_3, mastery_4, '
//             'instructional_1, instructional_2, instructional_3, instructional_4, instructional_5, '
//             'instructional_6, instructional_7, instructional_8, instructional_9, instructional_10, '
//             'communication_1, communication_2, communication_3, communication_4, communication_5, communication_6, '
//             'evaluation_1, evaluation_2, '
//             'classroom_1, classroom_2, classroom_3, classroom_4, classroom_5, '
//             'course_id',
//           )
//           .order('created_at', ascending: false);

//       final Map<String, List<Map<String, dynamic>>> groupedByFaculty = {};

//       for (var evaluation in response as List) {
//         final facultyId = evaluation['faculty_id'] as String;
//         if (!groupedByFaculty.containsKey(facultyId)) {
//           groupedByFaculty[facultyId] = [];
//         }
//         groupedByFaculty[facultyId]!.add(evaluation);
//       }

//       final List<Map<String, dynamic>> facultyList = [];

//       groupedByFaculty.forEach((facultyId, evaluations) {
//         final count = evaluations.length;

//         // Calculate average for each criterion
//         double calculateCriterionAvg(String field) {
//           try {
//             return evaluations
//                     .map((e) => (e[field] as num?)?.toDouble() ?? 0.0)
//                     .reduce((a, b) => a + b) /
//                 count;
//           } catch (e) {
//             return 0.0;
//           }
//         }

//         String facultyName =
//             evaluations.first['faculty_name'] ?? 'Unknown Faculty';

//         // Calculate averages for all criteria
//         final Map<String, double> criteriaScores = {};

//         // Mastery criteria
//         for (int i = 1; i <= 4; i++) {
//           criteriaScores['mastery_$i'] = calculateCriterionAvg('mastery_$i');
//         }

//         // Instructional criteria
//         for (int i = 1; i <= 10; i++) {
//           criteriaScores['instructional_$i'] = calculateCriterionAvg(
//             'instructional_$i',
//           );
//         }

//         // Communication criteria
//         for (int i = 1; i <= 6; i++) {
//           criteriaScores['communication_$i'] = calculateCriterionAvg(
//             'communication_$i',
//           );
//         }

//         // Evaluation criteria
//         for (int i = 1; i <= 2; i++) {
//           criteriaScores['evaluation_$i'] = calculateCriterionAvg(
//             'evaluation_$i',
//           );
//         }

//         // Classroom criteria
//         for (int i = 1; i <= 5; i++) {
//           criteriaScores['classroom_$i'] = calculateCriterionAvg(
//             'classroom_$i',
//           );
//         }

//         // Calculate weighted score average
//         double avgWeightedScore = calculateCriterionAvg('weighted_score');

//         facultyList.add({
//           'faculty_id': facultyId,
//           'faculty_name': facultyName,
//           'evaluation_count': count,
//           'avg_weighted_score': avgWeightedScore,
//           'course_id': evaluations.first['course_id'],
//           ...criteriaScores,
//         });
//       });

//       return facultyList;
//     } catch (e) {
//       debugPrint('Error fetching faculty data: $e');
//       rethrow;
//     }
//   }

//   Future<void> _generatePDF() async {
//     setState(() => _isLoading = true);

//     try {
//       final facultyData = await _fetchFacultyData();
//       final pdf = pw.Document();

//       final arial = pw.Font.ttf(await rootBundle.load("fonts/arial.ttf"));
//       final theme = pw.ThemeData.withFont(base: arial);

//       final catsuLogo = pw.MemoryImage(
//         (await rootBundle.load('images/catsu_png.png')).buffer.asUint8List(),
//       );
//       final tuvLogo = pw.MemoryImage(
//         (await rootBundle.load('images/tuv_png.png')).buffer.asUint8List(),
//       );

//       // Page 1: Header + Sections A and B
//       pdf.addPage(
//         pw.Page(
//           theme: theme,
//           pageFormat: PdfPageFormat.a4.landscape,
//           margin: pw.EdgeInsets.only(
//             left: 0.7 * PdfPageFormat.inch,
//             right: 0.7 * PdfPageFormat.inch,
//             top: 20,
//             bottom: 20,
//           ),
//           build: (context) => pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               _buildHeader(
//                 _selectedSemester,
//                 _selectedSchoolYear,
//                 catsuLogo,
//                 tuvLogo,
//               ),
//               pw.SizedBox(height: 15),
//               _buildSection(
//                 'A. Mastery of Subject-Matter (25%)',
//                 sectionACriteria,
//                 facultyData,
//                 'mastery',
//                 4,
//                 0.25,
//               ),
//               pw.SizedBox(height: 15),
//               _buildSection(
//                 'B. Instructional Skills (25%)',
//                 sectionBCriteria,
//                 facultyData,
//                 'instructional',
//                 10,
//                 0.25,
//               ),
//             ],
//           ),
//         ),
//       );

//       // Page 2: Sections C, D, E and Overall
//       pdf.addPage(
//         pw.Page(
//           theme: theme,
//           pageFormat: PdfPageFormat.a4.landscape,
//           margin: pw.EdgeInsets.only(
//             left: 0.7 * PdfPageFormat.inch,
//             right: 0.7 * PdfPageFormat.inch,
//             top: 20,
//             bottom: 20,
//           ),
//           build: (context) => pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               _buildSection(
//                 'C. Communication Skills (20%)',
//                 sectionCCriteria,
//                 facultyData,
//                 'communication',
//                 6,
//                 0.20,
//               ),
//               pw.SizedBox(height: 15),
//               _buildSection(
//                 'D. Evaluation Techniques (15%)',
//                 sectionDCriteria,
//                 facultyData,
//                 'evaluation',
//                 2,
//                 0.15,
//               ),
//               pw.SizedBox(height: 15),
//               _buildSection(
//                 'E. Classroom Management Skills (15%)',
//                 sectionECriteria,
//                 facultyData,
//                 'classroom',
//                 5,
//                 0.15,
//               ),
//               pw.SizedBox(height: 15),
//               _buildOverallMeanTable(facultyData),
//               pw.Spacer(),
//               _buildFooter(),
//             ],
//           ),
//         ),
//       );

//       await Printing.layoutPdf(onLayout: (format) async => pdf.save());
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   pw.Widget _buildHeader(
//     String semester,
//     String schoolYear,
//     pw.ImageProvider catsuLogo,
//     pw.ImageProvider tuvLogo,
//   ) {
//     return pw.Column(
//       children: [
//         pw.Row(
//           crossAxisAlignment: pw.CrossAxisAlignment.center,
//           children: [
//             pw.Container(
//               width: 50,
//               height: 50,
//               child: pw.Image(catsuLogo, fit: pw.BoxFit.contain),
//             ),
//             pw.SizedBox(width: 15),
//             pw.Expanded(
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     'Republic of the Philippines',
//                     style: pw.TextStyle(
//                       fontSize: 10,
//                       fontStyle: pw.FontStyle.italic,
//                     ),
//                   ),
//                   pw.Text(
//                     'CATANDUANES STATE UNIVERSITY',
//                     style: pw.TextStyle(
//                       fontSize: 14,
//                       fontWeight: pw.FontWeight.bold,
//                       color: PdfColors.grey800,
//                     ),
//                   ),
//                   pw.Text(
//                     'Virac, Catanduanes',
//                     style: pw.TextStyle(
//                       fontSize: 10,
//                       fontStyle: pw.FontStyle.italic,
//                       decoration: pw.TextDecoration.underline,
//                       decorationColor: PdfColors.red,
//                       decorationThickness: 2,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             pw.SizedBox(width: 15),
//             pw.Container(
//               width: 100,
//               height: 100,
//               child: pw.Image(tuvLogo, fit: pw.BoxFit.contain),
//             ),
//           ],
//         ),
//         pw.SizedBox(height: 8),
//         pw.Container(
//           height: 3,
//           decoration: const pw.BoxDecoration(color: PdfColors.blue800),
//         ),
//         pw.SizedBox(height: 4),
//         pw.Container(
//           alignment: pw.Alignment.centerLeft,
//           child: pw.Text(
//             'College of Information and Communications Technology',
//             style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
//           ),
//         ),
//         pw.SizedBox(height: 10),
//         pw.Text(
//           'SUMMARY OF FACULTY OBSERVATION (PART-TIME FACULTY)',
//           style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
//           textAlign: pw.TextAlign.center,
//         ),
//         pw.SizedBox(height: 4),
//         pw.Text(
//           'LECTURE CLASS',
//           style: const pw.TextStyle(fontSize: 10),
//           textAlign: pw.TextAlign.center,
//         ),
//         pw.Text(
//           '$semester SEMESTER SCHOOL YEAR $schoolYear',
//           style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
//           textAlign: pw.TextAlign.center,
//         ),
//       ],
//     );
//   }

//   pw.Widget _buildSection(
//     String title,
//     List<String> criteria,
//     List<Map<String, dynamic>> facultyData,
//     String criterionPrefix,
//     int criterionCount,
//     double weight,
//   ) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text(
//           title,
//           style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
//         ),
//         pw.SizedBox(height: 5),
//         pw.Table(
//           border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
//           columnWidths: {0: const pw.FixedColumnWidth(150)},
//           children: [
//             // Header Row
//             pw.TableRow(
//               decoration: const pw.BoxDecoration(color: PdfColors.grey300),
//               children: [
//                 _buildCell('Criteria', bold: true, fontSize: 7),
//                 ...facultyData.map(
//                   (f) => _buildCell(
//                     (f['faculty_name'] as String).toUpperCase(),
//                     bold: true,
//                     fontSize: 6,
//                     center: true,
//                   ),
//                 ),
//               ],
//             ),
//             // Criteria Rows - showing individual criterion scores
//             ...List.generate(criterionCount, (index) {
//               return pw.TableRow(
//                 children: [
//                   _buildCell('${index + 1}. ${criteria[index]}', fontSize: 6),
//                   ...facultyData.map((f) {
//                     final score =
//                         (f['${criterionPrefix}_${index + 1}'] as num?)
//                             ?.toDouble() ??
//                         0.0;
//                     return _buildCell(
//                       score.toStringAsFixed(2),
//                       fontSize: 6,
//                       center: true,
//                     );
//                   }),
//                 ],
//               );
//             }),
//             // Total Row
//             pw.TableRow(
//               decoration: const pw.BoxDecoration(color: PdfColors.blue200),
//               children: [
//                 _buildCell('TOTAL:', bold: true, fontSize: 7, alignRight: true),
//                 ...facultyData.map((f) {
//                   double total = 0.0;
//                   for (int i = 1; i <= criterionCount; i++) {
//                     total +=
//                         (f['${criterionPrefix}_$i'] as num?)?.toDouble() ?? 0.0;
//                   }
//                   return _buildCell(
//                     total.toStringAsFixed(2),
//                     bold: true,
//                     fontSize: 6,
//                     center: true,
//                   );
//                 }),
//               ],
//             ),
//             // Mean Row
//             pw.TableRow(
//               decoration: const pw.BoxDecoration(color: PdfColors.blue300),
//               children: [
//                 _buildCell('MEAN:', bold: true, fontSize: 7, alignRight: true),
//                 ...facultyData.map((f) {
//                   double total = 0.0;
//                   for (int i = 1; i <= criterionCount; i++) {
//                     total +=
//                         (f['${criterionPrefix}_$i'] as num?)?.toDouble() ?? 0.0;
//                   }
//                   final mean = total / criterionCount;
//                   return _buildCell(
//                     mean.toStringAsFixed(2),
//                     fontSize: 6,
//                     center: true,
//                   );
//                 }),
//               ],
//             ),
//             // Weighted Mean Row
//             pw.TableRow(
//               decoration: const pw.BoxDecoration(color: PdfColors.blue300),
//               children: [
//                 _buildCell(
//                   'Wtd. Mean:',
//                   bold: true,
//                   fontSize: 7,
//                   alignRight: true,
//                 ),
//                 ...facultyData.map((f) {
//                   double total = 0.0;
//                   for (int i = 1; i <= criterionCount; i++) {
//                     total +=
//                         (f['${criterionPrefix}_$i'] as num?)?.toDouble() ?? 0.0;
//                   }
//                   final mean = total / criterionCount;
//                   final weightedMean = mean * weight;
//                   return _buildCell(
//                     weightedMean.toStringAsFixed(4),
//                     fontSize: 6,
//                     center: true,
//                   );
//                 }),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   pw.Widget _buildOverallMeanTable(List<Map<String, dynamic>> facultyData) {
//     return pw.Table(
//       border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
//       columnWidths: {0: const pw.FixedColumnWidth(150)},
//       children: [
//         pw.TableRow(
//           decoration: const pw.BoxDecoration(color: PdfColors.grey300),
//           children: [
//             _buildCell('Overall Mean/Desc.Equiv', bold: true, fontSize: 8),
//             ...facultyData.map((f) {
//               final overallMean =
//                   (f['avg_weighted_score'] as num?)?.toDouble() ?? 0.0;
//               return _buildCell(
//                 overallMean.toStringAsFixed(4),
//                 bold: true,
//                 fontSize: 7,
//                 center: true,
//               );
//             }),
//           ],
//         ),
//       ],
//     );
//   }

//   pw.Widget _buildCell(
//     String text, {
//     bool bold = false,
//     double fontSize = 8,
//     bool center = false,
//     bool alignRight = false,
//   }) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(4),
//       child: pw.Align(
//         alignment: alignRight
//             ? pw.Alignment.centerRight
//             : (center ? pw.Alignment.center : pw.Alignment.centerLeft),
//         child: pw.Text(
//           text,
//           style: pw.TextStyle(
//             fontSize: fontSize,
//             fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }

//   pw.Widget _buildFooter() {
//     return pw.Row(
//       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//       children: [
//         pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text('Prepared by:', style: const pw.TextStyle(fontSize: 8)),
//             pw.SizedBox(height: 20),
//             pw.Text(
//               'ASTER VIVIEN C. VARGAS, MSIT',
//               style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
//             ),
//             pw.Text(
//               'Department Chairperson, Computing Programs',
//               style: const pw.TextStyle(fontSize: 7),
//             ),
//           ],
//         ),
//         pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text('Noted:', style: const pw.TextStyle(fontSize: 8)),
//             pw.SizedBox(height: 20),
//             pw.Text(
//               'MARIA CONCEPCION S. VERA, DIT',
//               style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
//             ),
//             pw.Text('CICT Dean', style: const pw.TextStyle(fontSize: 7)),
//           ],
//         ),
//       ],
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadFacultyCards();
//     _setupRealtimeSubscription();
//   }

//   List<Map<String, dynamic>> _facultyCards = [];
//   bool _isLoadingCards = true;

//   void _setupRealtimeSubscription() {
//     supabase
//         .channel('evaluations_channel')
//         .onPostgresChanges(
//           event: PostgresChangeEvent.insert,
//           schema: 'public',
//           table: 'evaluations',
//           callback: (payload) {
//             _loadFacultyCards();
//           },
//         )
//         .subscribe();
//   }

//   Future<void> _loadFacultyCards() async {
//     try {
//       final data = await _fetchFacultyData();
//       if (mounted) {
//         setState(() {
//           _facultyCards = data;
//           _isLoadingCards = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoadingCards = false);
//       }
//     }
//   }

//   String _getPerformanceLevel(double score) {
//     if (score >= 4.5) return 'Outstanding';
//     if (score >= 3.5) return 'Very Satisfactory';
//     if (score >= 2.5) return 'Satisfactory';
//     if (score >= 1.5) return 'Fair';
//     return 'Needs Improvement';
//   }

//   Color _getPerformanceColor(double score) {
//     if (score >= 4.5) return Colors.green.shade700;
//     if (score >= 3.5) return Colors.blue.shade700;
//     if (score >= 2.5) return Colors.orange.shade700;
//     if (score >= 1.5) return Colors.orange.shade900;
//     return Colors.red.shade700;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Faculty Evaluation Reports',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Color.fromARGB(255, 32, 42, 68),
//                 ),
//               ),
//               Row(
//                 children: [
//                   // Semester Dropdown
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: DropdownButton<String>(
//                       value: _selectedSemester,
//                       underline: const SizedBox(),
//                       items: ['1st', '2nd'].map((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text('$value Semester'),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         if (newValue != null) {
//                           setState(() => _selectedSemester = newValue);
//                         }
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   // School Year Dropdown
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: DropdownButton<String>(
//                       value: _selectedSchoolYear,
//                       underline: const SizedBox(),
//                       items: ['2023-2024', '2024-2025', '2025-2026'].map((
//                         String value,
//                       ) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text('SY $value'),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         if (newValue != null) {
//                           setState(() => _selectedSchoolYear = newValue);
//                         }
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   ElevatedButton.icon(
//                     onPressed: _isLoading ? null : _generatePDF,
//                     icon: _isLoading
//                         ? const SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Icon(Icons.picture_as_pdf),
//                     label: Text(_isLoading ? 'Generating...' : 'Generate PDF'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 32, 42, 68),
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: _isLoadingCards
//                 ? const Center(child: CircularProgressIndicator())
//                 : _facultyCards.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.assessment_outlined,
//                           size: 64,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 16),
//                         const Text(
//                           'No faculty evaluations found',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Faculty cards will appear here as evaluations are submitted',
//                           style: TextStyle(color: Colors.grey[600]),
//                         ),
//                       ],
//                     ),
//                   )

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class EvaluationReportsView extends StatefulWidget {
  const EvaluationReportsView({super.key});

  @override
  State<EvaluationReportsView> createState() => _EvaluationReportsViewState();
}

class _EvaluationReportsViewState extends State<EvaluationReportsView> {
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  String _selectedSemester = '1st';
  String _selectedSchoolYear = '2024-2025';

  // Section criteria
  static const List<String> sectionACriteria = [
    'Presents lesson logically',
    'Relates lesson to local/national issues',
    'Provides explanation beyond the content of the book',
    'Teaches independent of notes',
  ];

  static const List<String> sectionBCriteria = [
    'Uses motivation techniques that elicit student\'s interest',
    'Links the past with the present lesson',
    'Uses varied strategies suited to the student\'s needs',
    'Asks varied types of questions',
    'Anticipates difficulties of students',
    'Provides appropriate reinforcement to student\'s responses',
    'Utilizes multiple sources of information',
    'Encourages maximum student\'s participation',
    'Integrates values in the lesson',
    'Provides opportunities for free expression of ideas',
  ];

  static const List<String> sectionCCriteria = [
    'Speaks in a well-modulated voice',
    'Uses language appropriate to the level of the class',
    'Pronounces words correctly',
    'Observes correct grammar in both speaking and writing',
    'Encourages students to speak and write',
    'Listens attentively to student\'s response',
  ];

  static const List<String> sectionDCriteria = [
    'Evaluates student\'s achievement based on the day\'s lesson',
    'Utilizes appropriate assessment tools and techniques',
  ];

  static const List<String> sectionECriteria = [
    'Maintains discipline (e.g. Keeps student\' task)',
    'Manages time profitably through curriculum-related activities',
    'Maximizes use of resources',
    'Maintains good rapport with the students',
    'Shows respect for individual student\'s limitations',
  ];

  Future<List<Map<String, dynamic>>> _fetchFacultyData() async {
    try {
      final response = await supabase
          .from('evaluations')
          .select(
            'faculty_id, faculty_name, weighted_score, '
            'mastery_1, mastery_2, mastery_3, mastery_4, '
            'instructional_1, instructional_2, instructional_3, instructional_4, instructional_5, '
            'instructional_6, instructional_7, instructional_8, instructional_9, instructional_10, '
            'communication_1, communication_2, communication_3, communication_4, communication_5, communication_6, '
            'evaluation_1, evaluation_2, '
            'classroom_1, classroom_2, classroom_3, classroom_4, classroom_5, '
            'course_id',
          )
          .order('created_at', ascending: false);

      final Map<String, List<Map<String, dynamic>>> groupedByFaculty = {};

      for (var evaluation in response as List) {
        final facultyId = evaluation['faculty_id'] as String;
        if (!groupedByFaculty.containsKey(facultyId)) {
          groupedByFaculty[facultyId] = [];
        }
        groupedByFaculty[facultyId]!.add(evaluation);
      }

      final List<Map<String, dynamic>> facultyList = [];

      groupedByFaculty.forEach((facultyId, evaluations) {
        final count = evaluations.length;

        // Calculate average for each criterion
        double calculateCriterionAvg(String field) {
          try {
            return evaluations
                    .map((e) => (e[field] as num?)?.toDouble() ?? 0.0)
                    .reduce((a, b) => a + b) /
                count;
          } catch (e) {
            return 0.0;
          }
        }

        String facultyName =
            evaluations.first['faculty_name'] ?? 'Unknown Faculty';

        // Calculate averages for all criteria
        final Map<String, double> criteriaScores = {};

        // Mastery criteria
        for (int i = 1; i <= 4; i++) {
          criteriaScores['mastery_$i'] = calculateCriterionAvg('mastery_$i');
        }

        // Instructional criteria
        for (int i = 1; i <= 10; i++) {
          criteriaScores['instructional_$i'] = calculateCriterionAvg(
            'instructional_$i',
          );
        }

        // Communication criteria
        for (int i = 1; i <= 6; i++) {
          criteriaScores['communication_$i'] = calculateCriterionAvg(
            'communication_$i',
          );
        }

        // Evaluation criteria
        for (int i = 1; i <= 2; i++) {
          criteriaScores['evaluation_$i'] = calculateCriterionAvg(
            'evaluation_$i',
          );
        }

        // Classroom criteria
        for (int i = 1; i <= 5; i++) {
          criteriaScores['classroom_$i'] = calculateCriterionAvg(
            'classroom_$i',
          );
        }

        // Calculate weighted score average
        double avgWeightedScore = calculateCriterionAvg('weighted_score');

        facultyList.add({
          'faculty_id': facultyId,
          'faculty_name': facultyName,
          'evaluation_count': count,
          'avg_weighted_score': avgWeightedScore,
          'course_id': evaluations.first['course_id'],
          ...criteriaScores,
        });
      });

      return facultyList;
    } catch (e) {
      debugPrint('Error fetching faculty data: $e');
      rethrow;
    }
  }

  Future<void> _generatePDF() async {
    setState(() => _isLoading = true);

    try {
      final facultyData = await _fetchFacultyData();
      final pdf = pw.Document();

      final arial = pw.Font.ttf(await rootBundle.load("fonts/arial.ttf"));
      final theme = pw.ThemeData.withFont(base: arial);

      final catsuLogo = pw.MemoryImage(
        (await rootBundle.load('images/catsu_png.png')).buffer.asUint8List(),
      );
      final tuvLogo = pw.MemoryImage(
        (await rootBundle.load('images/tuv_png.png')).buffer.asUint8List(),
      );

      // Page 1: Header + Sections A and B
      pdf.addPage(
        pw.Page(
          theme: theme,
          pageFormat: PdfPageFormat.a4.landscape,
          margin: pw.EdgeInsets.only(
            left: 0.7 * PdfPageFormat.inch,
            right: 0.7 * PdfPageFormat.inch,
            top: 20,
            bottom: 20,
          ),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(
                _selectedSemester,
                _selectedSchoolYear,
                catsuLogo,
                tuvLogo,
              ),
              pw.SizedBox(height: 15),
              _buildSection(
                'A. Mastery of Subject-Matter (25%)',
                sectionACriteria,
                facultyData,
                'mastery',
                4,
                0.25,
              ),
              pw.SizedBox(height: 15),
              _buildSection(
                'B. Instructional Skills (25%)',
                sectionBCriteria,
                facultyData,
                'instructional',
                10,
                0.25,
              ),
            ],
          ),
        ),
      );

      // Page 2: Sections C, D, E and Overall
      pdf.addPage(
        pw.Page(
          theme: theme,
          pageFormat: PdfPageFormat.a4.landscape,
          margin: pw.EdgeInsets.only(
            left: 0.7 * PdfPageFormat.inch,
            right: 0.7 * PdfPageFormat.inch,
            top: 20,
            bottom: 20,
          ),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSection(
                'C. Communication Skills (20%)',
                sectionCCriteria,
                facultyData,
                'communication',
                6,
                0.20,
              ),
              pw.SizedBox(height: 15),
              _buildSection(
                'D. Evaluation Techniques (15%)',
                sectionDCriteria,
                facultyData,
                'evaluation',
                2,
                0.15,
              ),
              pw.SizedBox(height: 15),
              _buildSection(
                'E. Classroom Management Skills (15%)',
                sectionECriteria,
                facultyData,
                'classroom',
                5,
                0.15,
              ),
              pw.SizedBox(height: 15),
              _buildOverallMeanTable(facultyData),
              pw.Spacer(),
              _buildFooter(),
            ],
          ),
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  pw.Widget _buildHeader(
    String semester,
    String schoolYear,
    pw.ImageProvider catsuLogo,
    pw.ImageProvider tuvLogo,
  ) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: 50,
              height: 50,
              child: pw.Image(catsuLogo, fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(width: 15),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Republic of the Philippines',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                  pw.Text(
                    'CATANDUANES STATE UNIVERSITY',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                    ),
                  ),
                  pw.Text(
                    'Virac, Catanduanes',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                      decoration: pw.TextDecoration.underline,
                      decorationColor: PdfColors.red,
                      decorationThickness: 2,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 15),
            pw.Container(
              width: 100,
              height: 100,
              child: pw.Image(tuvLogo, fit: pw.BoxFit.contain),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          height: 3,
          decoration: const pw.BoxDecoration(color: PdfColors.blue800),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'College of Information and Communications Technology',
            style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'SUMMARY OF FACULTY OBSERVATION (PART-TIME FACULTY)',
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'LECTURE CLASS',
          style: const pw.TextStyle(fontSize: 10),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          '$semester SEMESTER SCHOOL YEAR $schoolYear',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  pw.Widget _buildSection(
    String title,
    List<String> criteria,
    List<Map<String, dynamic>> facultyData,
    String criterionPrefix,
    int criterionCount,
    double weight,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
          columnWidths: {0: const pw.FixedColumnWidth(150)},
          children: [
            // Header Row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _buildCell('Criteria', bold: true, fontSize: 7),
                ...facultyData.map(
                  (f) => _buildCell(
                    (f['faculty_name'] as String).toUpperCase(),
                    bold: true,
                    fontSize: 6,
                    center: true,
                  ),
                ),
              ],
            ),
            // Criteria Rows - showing individual criterion scores
            ...List.generate(criterionCount, (index) {
              return pw.TableRow(
                children: [
                  _buildCell('${index + 1}. ${criteria[index]}', fontSize: 6),
                  ...facultyData.map((f) {
                    final score =
                        (f['${criterionPrefix}_${index + 1}'] as num?)
                            ?.toDouble() ??
                        0.0;
                    return _buildCell(
                      score.toStringAsFixed(2),
                      fontSize: 6,
                      center: true,
                    );
                  }),
                ],
              );
            }),
            // Total Row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue200),
              children: [
                _buildCell('TOTAL:', bold: true, fontSize: 7, alignRight: true),
                ...facultyData.map((f) {
                  double total = 0.0;
                  for (int i = 1; i <= criterionCount; i++) {
                    total +=
                        (f['${criterionPrefix}_$i'] as num?)?.toDouble() ?? 0.0;
                  }
                  return _buildCell(
                    total.toStringAsFixed(2),
                    bold: true,
                    fontSize: 6,
                    center: true,
                  );
                }),
              ],
            ),
            // Mean Row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue300),
              children: [
                _buildCell('MEAN:', bold: true, fontSize: 7, alignRight: true),
                ...facultyData.map((f) {
                  double total = 0.0;
                  for (int i = 1; i <= criterionCount; i++) {
                    total +=
                        (f['${criterionPrefix}_$i'] as num?)?.toDouble() ?? 0.0;
                  }
                  final mean = total / criterionCount;
                  return _buildCell(
                    mean.toStringAsFixed(2),
                    fontSize: 6,
                    center: true,
                  );
                }),
              ],
            ),
            // Weighted Mean Row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue300),
              children: [
                _buildCell(
                  'Wtd. Mean:',
                  bold: true,
                  fontSize: 7,
                  alignRight: true,
                ),
                ...facultyData.map((f) {
                  double total = 0.0;
                  for (int i = 1; i <= criterionCount; i++) {
                    total +=
                        (f['${criterionPrefix}_$i'] as num?)?.toDouble() ?? 0.0;
                  }
                  final mean = total / criterionCount;
                  final weightedMean = mean * weight;
                  return _buildCell(
                    weightedMean.toStringAsFixed(4),
                    fontSize: 6,
                    center: true,
                  );
                }),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildOverallMeanTable(List<Map<String, dynamic>> facultyData) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {0: const pw.FixedColumnWidth(150)},
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildCell('Overall Mean/Desc.Equiv', bold: true, fontSize: 8),
            ...facultyData.map((f) {
              final overallMean =
                  (f['avg_weighted_score'] as num?)?.toDouble() ?? 0.0;
              return _buildCell(
                overallMean.toStringAsFixed(4),
                bold: true,
                fontSize: 7,
                center: true,
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCell(
    String text, {
    bool bold = false,
    double fontSize = 8,
    bool center = false,
    bool alignRight = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Align(
        alignment: alignRight
            ? pw.Alignment.centerRight
            : (center ? pw.Alignment.center : pw.Alignment.centerLeft),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Prepared by:', style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(height: 20),
            pw.Text(
              'ASTER VIVIEN C. VARGAS, MSIT',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Department Chairperson, Computing Programs',
              style: const pw.TextStyle(fontSize: 7),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Noted:', style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(height: 20),
            pw.Text(
              'MARIA CONCEPCION S. VERA, DIT',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('CICT Dean', style: const pw.TextStyle(fontSize: 7)),
          ],
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _loadFacultyCards();
    _setupRealtimeSubscription();
  }

  List<Map<String, dynamic>> _facultyCards = [];
  bool _isLoadingCards = true;

  void _setupRealtimeSubscription() {
    supabase
        .channel('evaluations_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'evaluations',
          callback: (payload) {
            _loadFacultyCards();
          },
        )
        .subscribe();
  }

  Future<void> _loadFacultyCards() async {
    try {
      final data = await _fetchFacultyData();
      if (mounted) {
        setState(() {
          _facultyCards = data;
          _isLoadingCards = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCards = false);
      }
    }
  }

  String _getPerformanceLevel(double score) {
    if (score >= 4.5) return 'Outstanding';
    if (score >= 3.5) return 'Very Satisfactory';
    if (score >= 2.5) return 'Satisfactory';
    if (score >= 1.5) return 'Fair';
    return 'Needs Improvement';
  }

  Color _getPerformanceColor(double score) {
    if (score >= 4.5) return Colors.green.shade700;
    if (score >= 3.5) return Colors.blue.shade700;
    if (score >= 2.5) return Colors.orange.shade700;
    if (score >= 1.5) return Colors.orange.shade900;
    return Colors.red.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section - Responsive
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Faculty Evaluation Reports',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 32, 42, 68),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dropdowns and button stacked on mobile
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedSemester,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: ['1st', '2nd'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text('$value Semester'),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() => _selectedSemester = newValue);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedSchoolYear,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: ['2023-2024', '2024-2025', '2025-2026'].map((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text('SY $value'),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() => _selectedSchoolYear = newValue);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _generatePDF,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.picture_as_pdf),
                          label: Text(
                            _isLoading ? 'Generating...' : 'Generate PDF',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              32,
                              42,
                              68,
                            ),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Faculty Evaluation Reports',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 32, 42, 68),
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        // Semester Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedSemester,
                            underline: const SizedBox(),
                            items: ['1st', '2nd'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text('$value Semester'),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() => _selectedSemester = newValue);
                              }
                            },
                          ),
                        ),
                        // School Year Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedSchoolYear,
                            underline: const SizedBox(),
                            items: ['2023-2024', '2024-2025', '2025-2026'].map((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text('SY $value'),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() => _selectedSchoolYear = newValue);
                              }
                            },
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _generatePDF,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.picture_as_pdf),
                          label: Text(
                            _isLoading ? 'Generating...' : 'Generate PDF',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              32,
                              42,
                              68,
                            ),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 20),
          // Cards Grid - Responsive
          Expanded(
            child: _isLoadingCards
                ? const Center(child: CircularProgressIndicator())
                : _facultyCards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assessment_outlined,
                          size: isMobile ? 48 : 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No faculty evaluations found',
                          style: TextStyle(fontSize: isMobile ? 14 : 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Faculty cards will appear here as evaluations are submitted',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: _facultyCards.length,
                    itemBuilder: (context, index) {
                      final faculty = _facultyCards[index];
                      final avgScore =
                          (faculty['avg_weighted_score'] as num?)?.toDouble() ??
                          0.0;
                      final performanceLevel = _getPerformanceLevel(avgScore);
                      final performanceColor = _getPerformanceColor(avgScore);

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: performanceColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: performanceColor
                                        .withOpacity(0.1),
                                    radius: 24,
                                    child: Icon(
                                      Icons.person,
                                      color: performanceColor,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          faculty['faculty_name'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                              255,
                                              32,
                                              42,
                                              68,
                                            ),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: performanceColor.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            performanceLevel,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: performanceColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Overall Score',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        avgScore.toStringAsFixed(2),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: performanceColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Evaluations',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.assignment_turned_in,
                                            size: 20,
                                            color: Colors.grey[700],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${faculty['evaluation_count']}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Divider(color: Colors.grey[300]),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildScoreIndicator(
                                    'Mastery',
                                    _calculateSectionAvg(faculty, 'mastery', 4),
                                  ),
                                  _buildScoreIndicator(
                                    'Instruction',
                                    _calculateSectionAvg(
                                      faculty,
                                      'instructional',
                                      10,
                                    ),
                                  ),
                                  _buildScoreIndicator(
                                    'Communication',
                                    _calculateSectionAvg(
                                      faculty,
                                      'communication',
                                      6,
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
          ),
        ],
      ),
    );
  }

  Widget _buildScoreIndicator(String label, double score) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          score.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 32, 42, 68),
          ),
        ),
      ],
    );
  }

  double _calculateSectionAvg(
    Map<String, dynamic> faculty,
    String prefix,
    int count,
  ) {
    double total = 0.0;
    for (int i = 1; i <= count; i++) {
      total += (faculty['${prefix}_$i'] as num?)?.toDouble() ?? 0.0;
    }
    return total / count;
  }

  @override
  void dispose() {
    supabase.removeChannel(supabase.channel('evaluations_channel'));
    super.dispose();
  }
}
