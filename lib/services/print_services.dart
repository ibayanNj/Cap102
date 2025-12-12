// import 'dart:io';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/services.dart' show rootBundle;

// // Data Models
// class EvaluationData {
//   final String facultyName;
//   final String courseTaught;
//   final String dateTime;
//   final String buildingRoom;
//   final String semester;
//   final String schoolYear;

//   final Map<String, int> masteryRatings; // key: criterion, value: rating (1-5)
//   final Map<String, int> instructionalRatings;
//   final Map<String, int> communicationRatings;
//   final Map<String, int> evaluationRatings;
//   final Map<String, int> managementRatings;

//   final String comments;
//   final String evaluatorName;
//   final String evaluatorSignature;
//   final String facultySignature;
//   final String date;

//   EvaluationData({
//     required this.facultyName,
//     required this.courseTaught,
//     required this.dateTime,
//     required this.buildingRoom,
//     required this.semester,
//     required this.schoolYear,
//     required this.masteryRatings,
//     required this.instructionalRatings,
//     required this.communicationRatings,
//     required this.evaluationRatings,
//     required this.managementRatings,
//     required this.comments,
//     required this.evaluatorName,
//     required this.evaluatorSignature,
//     required this.facultySignature,
//     required this.date,
//   });
// }

// class SectionData {
//   final String title;
//   final List<String> criteria;
//   final Map<String, int> ratings;
//   final double weight;

//   SectionData({
//     required this.title,
//     required this.criteria,
//     required this.ratings,
//     required this.weight,
//   });

//   double get totalScore {
//     return ratings.values.fold(0, (sum, rating) => sum + rating).toDouble();
//   }

//   double get mean {
//     if (ratings.isEmpty) return 0;
//     return totalScore / ratings.length;
//   }

//   double get weightedMean {
//     return mean * weight;
//   }
// }

// // PDF Generator Service
// class ClassObservationPDFGenerator {
//   static late pw.Font notoFont;

//   static Future<void> loadFonts() async {
//     final fontData = await rootBundle.load("fonts/NotoSans-Regular.ttf");
//     notoFont = pw.TtfFont(fontData);
//   }

//   static final List<String> masteryCriteria = [
//     'Presents lesson logically',
//     'Relates lesson to local/national issues',
//     'Provides explanation beyond the content of the book',
//     'Teaches independent of notes',
//   ];

//   static final List<String> instructionalCriteria = [
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

//   static final List<String> communicationCriteria = [
//     'Speaks in a well-modulated voice',
//     'Uses language appropriate to the level of the class',
//     'Pronounces words correctly',
//     'Observes correct grammar in both speaking and writing',
//     'Encourages students to speak and write',
//     'Listens attentively to student\'s response',
//   ];

//   static final List<String> evaluationCriteria = [
//     'Evaluates student\'s achievement based in the day\'s lesson',
//     'Utilizes appropriate assessment tools and techniques',
//   ];

//   static final List<String> managementCriteria = [
//     'Maintains discipline (e.g. Keeps students on task)',
//     'Manages time profitably through curriculum-related activities',
//     'Maximizes use of resources',
//     'Maintains good rapport with the students',
//     'Shows respect for individual student\'s limitations',
//   ];

//   static Future<pw.Document> generatePDF(EvaluationData data) async {
//     await loadFonts();
//     final pdf = pw.Document();

//     final sections = [
//       SectionData(
//         title: 'A. Mastery of Subject-Matter (25%)',
//         criteria: masteryCriteria,
//         ratings: data.masteryRatings,
//         weight: 0.25,
//       ),
//       SectionData(
//         title: 'B. Instructional Skills (25%)',
//         criteria: instructionalCriteria,
//         ratings: data.instructionalRatings,
//         weight: 0.25,
//       ),
//       SectionData(
//         title: 'C. Communication Skills (20%)',
//         criteria: communicationCriteria,
//         ratings: data.communicationRatings,
//         weight: 0.20,
//       ),
//       SectionData(
//         title: 'D. Evaluation Techniques (15%)',
//         criteria: evaluationCriteria,
//         ratings: data.evaluationRatings,
//         weight: 0.15,
//       ),
//       SectionData(
//         title: 'E. Classroom Management Skills (15%)',
//         criteria: managementCriteria,
//         ratings: data.managementRatings,
//         weight: 0.15,
//       ),
//     ];

//     // Calculate overall mean
//     final overallMean = sections.fold<double>(
//       0,
//       (sum, section) => sum + section.weightedMean,
//     );

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat(
//           8.5 * PdfPageFormat.inch,
//           13 * PdfPageFormat.inch,
//         ),
//         margin: pw.EdgeInsets.only(
//           left: 0.7 * PdfPageFormat.inch, // 0.7 inch left margin
//           right: 0.7 * PdfPageFormat.inch, // 0.7 inch right margin
//           top: 20, // top margin in points
//           bottom: 20, // bottom margin in points
//         ),
//         build: (context) {
//           return pw.Column(
//             // Removed Center and SizedBox.expand
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               _buildHeader(data),
//               pw.SizedBox(height: 4), // Reduced from 8
//               _buildInstructions(),
//               pw.SizedBox(height: 4), // Reduced from 8
//               ...sections.map(
//                 (section) => pw.Column(
//                   children: [
//                     _buildSection(section, notoFont),
//                     pw.SizedBox(height: 4), // Reduced from 8
//                   ],
//                 ),
//               ),
//               _buildOverallMean(overallMean),
//               pw.SizedBox(height: 4), // Reduced from 8
//               _buildComments(data.comments),
//               pw.SizedBox(height: 8), // Reduced from 13
//               _buildSignatures(data),
//             ],
//           );
//         },
//       ),
//     );
//     return pdf;
//   }

//   static pw.Widget _buildHeader(EvaluationData data) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text(
//           'College of Information and Communications Technology',
//           style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
//         ),
//         pw.SizedBox(height: 10),
//         pw.Center(
//           child: pw.Column(
//             children: [
//               pw.Text(
//                 'CLASS OBSERVATION FORM',
//                 style: pw.TextStyle(
//                   fontSize: 10,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//               pw.Text(
//                 '(Lecture Classes)',
//                 style: pw.TextStyle(
//                   fontSize: 10,
//                   fontStyle: pw.FontStyle.italic,
//                 ),
//               ),
//               pw.Text(
//                 '${data.semester}, School Year ${data.schoolYear}',
//                 style: pw.TextStyle(
//                   fontSize: 10,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         pw.SizedBox(height: 15),
//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//           children: [
//             pw.Text(
//               'Faculty: ${data.facultyName}',
//               style: pw.TextStyle(fontSize: 10),
//             ),
//             pw.Text(
//               'Date/Time: ${data.dateTime}',
//               style: pw.TextStyle(fontSize: 10),
//             ),
//           ],
//         ),
//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//           children: [
//             pw.Text(
//               'Course(s) Taught/Topic: ${data.courseTaught}',
//               style: pw.TextStyle(fontSize: 10),
//             ),
//             pw.Text(
//               'Bldg/Room: ${data.buildingRoom}',
//               style: pw.TextStyle(fontSize: 10),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   static pw.Widget _buildInstructions() {
//     return pw.Text(
//       'Instructions: This instrument is used to evaluate the teaching effectiveness of the faculty. Check the column under the number that corresponds to your rating for the faculty concerned using the scale coded as follows:\n5 - Outstanding (4.51-5.0)  4 - Very Satisfactory (3.51-4.50)  3 - Satisfactory (2.51-3.50)  2 - Fair (1.51-2.50)  1 - Poor (1.0-1.50)',
//       style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
//     );
//   }

//   static pw.Widget _buildSection(SectionData sectionData, pw.Font notoFont) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Container(
//           color: PdfColors.grey300,
//           padding: pw.EdgeInsets.all(4),
//           child: pw.Text(
//             sectionData.title,
//             style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
//           ),
//         ),
//         pw.Table(
//           border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
//           columnWidths: {
//             0: pw.FlexColumnWidth(5),
//             1: pw.FixedColumnWidth(23),
//             2: pw.FixedColumnWidth(23),
//             3: pw.FixedColumnWidth(23),
//             4: pw.FixedColumnWidth(23),
//             5: pw.FixedColumnWidth(23),
//           },
//           children: [
//             // Header row
//             pw.TableRow(
//               children: [
//                 pw.Padding(
//                   padding: pw.EdgeInsets.all(3),
//                   child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
//                 ),
//                 ...List.generate(5, (index) {
//                   return pw.Center(
//                     child: pw.Padding(
//                       padding: pw.EdgeInsets.all(3),
//                       child: pw.Text(
//                         '(${5 - index})',
//                         style: pw.TextStyle(
//                           fontSize: 8,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//               ],
//             ),
//             // Criteria rows
//             ...sectionData.criteria.asMap().entries.map((entry) {
//               // ...criteria.asMap().entries.map((entry) {
//               int idx = entry.key + 1;
//               String criterion = entry.value;
//               int rating = sectionData.ratings[criterion] ?? 0;

//               return pw.TableRow(
//                 children: [
//                   pw.Padding(
//                     padding: pw.EdgeInsets.all(3),
//                     child: pw.Text(
//                       '$idx    $criterion',
//                       style: pw.TextStyle(fontSize: 8),
//                     ),
//                   ),
//                   ...List.generate(5, (index) {
//                     int ratingValue = 5 - index;
//                     return pw.Center(
//                       child: pw.Padding(
//                         padding: pw.EdgeInsets.all(3),
//                         child: pw.Text(
//                           rating == ratingValue ? '✓' : '', // Your logic
//                           style: pw.TextStyle(
//                             font: pw
//                                 .Font.zapfDingbats(), // <-- This line is the solution
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//                 ],
//               );
//             }),
//             // Total Score row
//             pw.TableRow(
//               children: [
//                 pw.Container(
//                   padding: pw.EdgeInsets.all(3),
//                   color: PdfColors.grey200,
//                   child: pw.Text(
//                     'Total Score/Mean/Wtd. Mean',
//                     style: pw.TextStyle(
//                       fontSize: 8,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 pw.Container(
//                   color: PdfColors.grey200,
//                   child: pw.Center(
//                     child: pw.Padding(
//                       padding: pw.EdgeInsets.all(3),
//                       child: pw.Text(
//                         sectionData.totalScore.toStringAsFixed(0),
//                         style: pw.TextStyle(
//                           fontSize: 8,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 pw.Container(
//                   color: PdfColors.grey200,
//                   child: pw.Center(
//                     child: pw.Padding(
//                       padding: pw.EdgeInsets.all(3),
//                       child: pw.Text(
//                         sectionData.mean.toStringAsFixed(2),
//                         style: pw.TextStyle(
//                           fontSize: 8,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 pw.Container(
//                   color: PdfColors.grey200,
//                   child: pw.Center(
//                     child: pw.Padding(
//                       padding: pw.EdgeInsets.all(3),
//                       child: pw.Text(
//                         sectionData.weightedMean.toStringAsFixed(2),
//                         style: pw.TextStyle(
//                           fontSize: 8,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 pw.Container(color: PdfColors.grey200, child: pw.SizedBox()),
//                 pw.Container(color: PdfColors.grey200, child: pw.SizedBox()),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   static pw.Widget _buildOverallMean(double overallMean) {
//     String getDescriptiveEquivalent(double mean) {
//       if (mean >= 4.51) return 'Outstanding';
//       if (mean >= 3.51) return 'Very Satisfactory';
//       if (mean >= 2.51) return 'Satisfactory';
//       if (mean >= 1.51) return 'Fair';
//       return 'Poor';
//     }

//     return pw.Container(
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: PdfColors.black, width: 0.5),
//         color: PdfColors.grey200,
//       ),
//       padding: pw.EdgeInsets.all(8),
//       child: pw.Center(
//         child: pw.Text(
//           'Overall MEAN: ${overallMean.toStringAsFixed(2)} - ${getDescriptiveEquivalent(overallMean)}',
//           style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
//         ),
//       ),
//     );
//   }

//   static pw.Widget _buildComments(String comments) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text(
//           'Comments/Suggestions:',
//           style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
//         ),
//         pw.SizedBox(height: 5),
//         pw.Container(
//           decoration: pw.BoxDecoration(
//             border: pw.Border.all(color: PdfColors.black, width: 0.5),
//           ),
//           padding: pw.EdgeInsets.all(8),
//           height: 60,
//           child: pw.Text(comments, style: pw.TextStyle(fontSize: 9)),
//         ),
//       ],
//     );
//   }

//   static pw.Widget _buildSignatures(EvaluationData data) {
//     return pw.Column(
//       children: [
//         pw.SizedBox(height: 20),
//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.end,
//           children: [
//             pw.Column(
//               children: [
//                 pw.Text(
//                   data.evaluatorName,
//                   style: pw.TextStyle(
//                     fontSize: 10,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//                 pw.Container(
//                   width: 200,
//                   decoration: pw.BoxDecoration(
//                     border: pw.Border(
//                       bottom: pw.BorderSide(color: PdfColors.black),
//                     ),
//                   ),
//                   child: pw.SizedBox(height: 1),
//                 ),
//                 pw.Text(
//                   'Signature over printed name of Evaluator/Observer',
//                   style: pw.TextStyle(
//                     fontSize: 8,
//                     fontStyle: pw.FontStyle.italic,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         pw.SizedBox(height: 20),
//         pw.Text('Concurred:', style: pw.TextStyle(fontSize: 10)),
//         pw.SizedBox(height: 10),
//         pw.Center(
//           child: pw.Column(
//             children: [
//               pw.Text(
//                 data.facultyName,
//                 style: pw.TextStyle(
//                   fontSize: 10,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//               pw.Container(
//                 width: 200,
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border(
//                     bottom: pw.BorderSide(color: PdfColors.black),
//                   ),
//                 ),
//                 child: pw.SizedBox(height: 1),
//               ),
//               pw.Text(
//                 'Signature over printed name of Faculty',
//                 style: pw.TextStyle(
//                   fontSize: 8,
//                   fontStyle: pw.FontStyle.italic,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         pw.SizedBox(height: 20),
//         pw.Center(
//           child: pw.Column(
//             children: [
//               pw.Text(data.date, style: pw.TextStyle(fontSize: 10)),
//               pw.Container(
//                 width: 150,
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border(
//                     bottom: pw.BorderSide(color: PdfColors.black),
//                   ),
//                 ),
//                 child: pw.SizedBox(height: 1),
//               ),
//               pw.Text('D a t e', style: pw.TextStyle(fontSize: 8)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   static Future<void> sharePDF(EvaluationData data) async {
//     final pdf = await generatePDF(data);
//     await Printing.sharePdf(
//       bytes: await pdf.save(),
//       filename:
//           'classroom_observation_${data.facultyName.replaceAll(' ', '_')}.pdf',
//     );
//   }

//   static Future<void> printPDF(EvaluationData data) async {
//     final pdf = await generatePDF(data);
//     await Printing.layoutPdf(onLayout: (format) async => pdf.save());
//   }

//   static Future<String> savePDF(EvaluationData data) async {
//     final pdf = await generatePDF(data);
//     final output = await getApplicationDocumentsDirectory();
//     final file = File(
//       '${output.path}/classroom_observation_${DateTime.now().millisecondsSinceEpoch}.pdf',
//     );

//     await file.writeAsBytes(await pdf.save());
//     return file.path;
//   }

//   static Future<void> previewPDF(EvaluationData data) async {
//     final pdf = await generatePDF(data);
//     await Printing.layoutPdf(onLayout: (format) async => pdf.save());
//   }
// }

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

// Data Models
class EvaluationData {
  final String facultyName;
  final String courseTaught;
  final String dateTime;
  final String buildingRoom;
  final String semester;
  final String schoolYear;

  final Map<String, int> masteryRatings; // key: criterion, value: rating (1-5)
  final Map<String, int> instructionalRatings;
  final Map<String, int> communicationRatings;
  final Map<String, int> evaluationRatings;
  final Map<String, int> managementRatings;

  final String comments;
  final String evaluatorName;
  final String evaluatorSignature;
  final String facultySignature;
  final String date;

  EvaluationData({
    required this.facultyName,
    required this.courseTaught,
    required this.dateTime,
    required this.buildingRoom,
    required this.semester,
    required this.schoolYear,
    required this.masteryRatings,
    required this.instructionalRatings,
    required this.communicationRatings,
    required this.evaluationRatings,
    required this.managementRatings,
    required this.comments,
    required this.evaluatorName,
    required this.evaluatorSignature,
    required this.facultySignature,
    required this.date,
  });
}

class SectionData {
  final String title;
  final List<String> criteria;
  final Map<String, int> ratings;
  final double weight;

  SectionData({
    required this.title,
    required this.criteria,
    required this.ratings,
    required this.weight,
  });

  double get totalScore {
    return ratings.values.fold(0, (sum, rating) => sum + rating).toDouble();
  }

  double get mean {
    if (ratings.isEmpty) return 0;
    return totalScore / ratings.length;
  }

  double get weightedMean {
    return mean * weight;
  }
}

// PDF Generator Service
class ClassObservationPDFGenerator {
  static late pw.Font notoFont;
  static late pw.ImageProvider catsuLogo;
  static late pw.ImageProvider tuvLogo;

  static Future<void> loadFonts() async {
    final fontData = await rootBundle.load("fonts/NotoSans-Regular.ttf");
    notoFont = pw.TtfFont(fontData);
  }

  static Future<void> loadLogos() async {
    // Load CatSU logo
    final catsuData = await rootBundle.load("assets/images/catsu_png.png");
    catsuLogo = pw.MemoryImage(catsuData.buffer.asUint8List());

    // Load TUV logo
    final tuvData = await rootBundle.load("assets/images/tuv_png.png");
    tuvLogo = pw.MemoryImage(tuvData.buffer.asUint8List());
  }

  static final List<String> masteryCriteria = [
    'Presents lesson logically',
    'Relates lesson to local/national issues',
    'Provides explanation beyond the content of the book',
    'Teaches independent of notes',
  ];

  static final List<String> instructionalCriteria = [
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

  static final List<String> communicationCriteria = [
    'Speaks in a well-modulated voice',
    'Uses language appropriate to the level of the class',
    'Pronounces words correctly',
    'Observes correct grammar in both speaking and writing',
    'Encourages students to speak and write',
    'Listens attentively to student\'s response',
  ];

  static final List<String> evaluationCriteria = [
    'Evaluates student\'s achievement based in the day\'s lesson',
    'Utilizes appropriate assessment tools and techniques',
  ];

  static final List<String> managementCriteria = [
    'Maintains discipline (e.g. Keeps students on task)',
    'Manages time profitably through curriculum-related activities',
    'Maximizes use of resources',
    'Maintains good rapport with the students',
    'Shows respect for individual student\'s limitations',
  ];

  static Future<pw.Document> generatePDF(EvaluationData data) async {
    await loadFonts();
    await loadLogos();

    final pdf = pw.Document();

    final sections = [
      SectionData(
        title: 'A. Mastery of Subject-Matter (25%)',
        criteria: masteryCriteria,
        ratings: data.masteryRatings,
        weight: 0.25,
      ),
      SectionData(
        title: 'B. Instructional Skills (25%)',
        criteria: instructionalCriteria,
        ratings: data.instructionalRatings,
        weight: 0.25,
      ),
      SectionData(
        title: 'C. Communication Skills (20%)',
        criteria: communicationCriteria,
        ratings: data.communicationRatings,
        weight: 0.20,
      ),
      SectionData(
        title: 'D. Evaluation Techniques (15%)',
        criteria: evaluationCriteria,
        ratings: data.evaluationRatings,
        weight: 0.15,
      ),
      SectionData(
        title: 'E. Classroom Management Skills (15%)',
        criteria: managementCriteria,
        ratings: data.managementRatings,
        weight: 0.15,
      ),
    ];

    // Calculate overall mean
    final overallMean = sections.fold<double>(
      0,
      (sum, section) => sum + section.weightedMean,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.legal,
        margin: pw.EdgeInsets.all(0.5 * PdfPageFormat.inch),
        // margin: pw.EdgeInsets.only(
        //   left: 0.7 * PdfPageFormat.inch,
        //   right: 0.7 * PdfPageFormat.inch,
        //   top: 0.5 * PdfPageFormat.inch,
        //   bottom: 0.5 * PdfPageFormat.inch,
        // ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildCatSUHeader(
                data.semester,
                data.schoolYear,
                catsuLogo,
                tuvLogo,
              ),
              pw.SizedBox(height: 8),
              _buildHeader(data),
              pw.SizedBox(height: 4),
              _buildInstructions(),
              pw.SizedBox(height: 4),
              ...sections.map(
                (section) => pw.Column(
                  children: [
                    _buildSection(section, notoFont),
                    pw.SizedBox(height: 4),
                  ],
                ),
              ),
              _buildOverallMean(overallMean),
              pw.SizedBox(height: 4),
              _buildComments(data.comments),
              pw.SizedBox(height: 8),
              _buildSignatures(data),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  static pw.Widget _buildCatSUHeader(
    String semester,
    String schoolYear,
    pw.ImageProvider catsuLogo,
    pw.ImageProvider tuvLogo,
  ) {
    return pw.Column(
      children: [
        // Top row with logos and text
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Left: CatSU Logo
            pw.Container(
              width: 35,
              height: 35,
              child: pw.Image(catsuLogo, fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(width: 15),

            pw.Expanded(
              child: pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Republic of the Philippines',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                    pw.Text(
                      'CATANDUANES STATE UNIVERSITY',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.Text(
                      'Virac, Catanduanes',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontStyle: pw.FontStyle.italic,
                        decoration: pw.TextDecoration.underline,
                        decorationColor: PdfColors.red,
                        decorationThickness: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            pw.SizedBox(width: 15),

            // Right: TUV Rheinland Logo
            pw.Container(
              width: 80,
              height: 80,
              child: pw.Image(tuvLogo, fit: pw.BoxFit.contain),
            ),
          ],
        ),

        pw.SizedBox(height: 8),

        // Blue line
        pw.Container(
          height: 3,
          decoration: const pw.BoxDecoration(color: PdfColors.blue800),
        ),

        pw.SizedBox(height: 4),

        // College line in italic
        pw.Container(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'College of Information and Communications Technology',
            style: pw.TextStyle(
              fontSize: 10,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.black,
            ),
          ),
        ),

        pw.SizedBox(height: 10),

        // Title section
        pw.Text(
          'CLASS OBSERVATION FORM',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '(Lecture Classes)',
          style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          '$semester, School Year $schoolYear',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  static pw.Widget _buildHeader(EvaluationData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Faculty: ${data.facultyName}',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              'Date/Time: ${data.dateTime}',
              style: pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Course(s) Taught/Topic: ${data.courseTaught}',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              'Bldg/Room: ${data.buildingRoom}',
              style: pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInstructions() {
    return pw.Text(
      'Instructions: This instrument is used to evaluate the teaching effectiveness of the faculty. Check the column under the number that corresponds to your rating for the faculty concerned using the scale coded as follows:\n5 - Outstanding (4.51-5.0)  4 - Very Satisfactory (3.51-4.50)  3 - Satisfactory (2.51-3.50)  2 - Fair (1.51-2.50)  1 - Poor (1.0-1.50)',
      style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
    );
  }

  static pw.Widget _buildSection(SectionData sectionData, pw.Font notoFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          color: PdfColors.grey300,
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(
            sectionData.title,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
          columnWidths: {
            0: pw.FlexColumnWidth(5),
            1: pw.FixedColumnWidth(23),
            2: pw.FixedColumnWidth(23),
            3: pw.FixedColumnWidth(23),
            4: pw.FixedColumnWidth(23),
            5: pw.FixedColumnWidth(23),
          },
          children: [
            // Header row
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(3),
                  child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                ),
                ...List.generate(5, (index) {
                  return pw.Center(
                    child: pw.Padding(
                      padding: pw.EdgeInsets.all(3),
                      child: pw.Text(
                        '(${5 - index})',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            // Criteria rows
            ...sectionData.criteria.asMap().entries.map((entry) {
              int idx = entry.key + 1;
              String criterion = entry.value;
              int rating = sectionData.ratings[criterion] ?? 0;

              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Text(
                      '$idx    $criterion',
                      style: pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  ...List.generate(5, (index) {
                    int ratingValue = 5 - index;
                    return pw.Center(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.all(3),
                        child: pw.Text(
                          rating == ratingValue ? '✓' : '',
                          style: pw.TextStyle(font: pw.Font.zapfDingbats()),
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
            // Total Score row
            pw.TableRow(
              children: [
                pw.Container(
                  padding: pw.EdgeInsets.all(3),
                  color: PdfColors.grey200,
                  child: pw.Text(
                    'Total Score/Mean/Wtd. Mean',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Container(
                  color: PdfColors.grey200,
                  child: pw.Center(
                    child: pw.Padding(
                      padding: pw.EdgeInsets.all(3),
                      child: pw.Text(
                        sectionData.totalScore.toStringAsFixed(0),
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                pw.Container(
                  color: PdfColors.grey200,
                  child: pw.Center(
                    child: pw.Padding(
                      padding: pw.EdgeInsets.all(3),
                      child: pw.Text(
                        sectionData.mean.toStringAsFixed(2),
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                pw.Container(
                  color: PdfColors.grey200,
                  child: pw.Center(
                    child: pw.Padding(
                      padding: pw.EdgeInsets.all(3),
                      child: pw.Text(
                        sectionData.weightedMean.toStringAsFixed(2),
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                pw.Container(color: PdfColors.grey200, child: pw.SizedBox()),
                pw.Container(color: PdfColors.grey200, child: pw.SizedBox()),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildOverallMean(double overallMean) {
    String getDescriptiveEquivalent(double mean) {
      if (mean >= 4.51) return 'Outstanding';
      if (mean >= 3.51) return 'Very Satisfactory';
      if (mean >= 2.51) return 'Satisfactory';
      if (mean >= 1.51) return 'Fair';
      return 'Poor';
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.5),
        color: PdfColors.grey200,
      ),
      padding: pw.EdgeInsets.all(8),
      child: pw.Center(
        child: pw.Text(
          'Overall MEAN: ${overallMean.toStringAsFixed(2)} - ${getDescriptiveEquivalent(overallMean)}',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ),
    );
  }

  static pw.Widget _buildComments(String comments) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Comments/Suggestions:',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 0.5),
          ),
          padding: pw.EdgeInsets.all(8),
          height: 60,
          child: pw.Text(comments, style: pw.TextStyle(fontSize: 9)),
        ),
      ],
    );
  }

  static pw.Widget _buildSignatures(EvaluationData data) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              children: [
                pw.Text(
                  data.evaluatorName,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Container(
                  width: 200,
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black),
                    ),
                  ),
                  child: pw.SizedBox(height: 1),
                ),
                pw.Text(
                  'Signature over printed name of Evaluator/Observer',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text('Concurred:', style: pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                data.facultyName,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                width: 200,
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.black),
                  ),
                ),
                child: pw.SizedBox(height: 1),
              ),
              pw.Text(
                'Signature over printed name of Faculty',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(data.date, style: pw.TextStyle(fontSize: 10)),
              pw.Container(
                width: 150,
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.black),
                  ),
                ),
                child: pw.SizedBox(height: 1),
              ),
              pw.Text('D a t e', style: pw.TextStyle(fontSize: 8)),
            ],
          ),
        ),
      ],
    );
  }

  static Future<void> sharePDF(EvaluationData data) async {
    final pdf = await generatePDF(data);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'classroom_observation_${data.facultyName.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<void> printPDF(EvaluationData data) async {
    final pdf = await generatePDF(data);
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static Future<String> savePDF(EvaluationData data) async {
    final pdf = await generatePDF(data);
    final output = await getApplicationDocumentsDirectory();
    final file = File(
      '${output.path}/classroom_observation_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static Future<void> previewPDF(EvaluationData data) async {
    final pdf = await generatePDF(data);
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
