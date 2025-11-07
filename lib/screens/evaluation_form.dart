import 'package:flutter/material.dart';
import 'package:faculty_evaluation_app/evaluation_form/rating_scale_card.dart';
import 'package:faculty_evaluation_app/evaluation_form/faculty_selection.dart';
import 'package:faculty_evaluation_app/evaluation_form/submit.dart';
import 'package:faculty_evaluation_app/utils/evaluation_section.dart';
import 'package:faculty_evaluation_app/models/evaluation_criterion.dart';
import 'package:faculty_evaluation_app/models/faculty_models.dart';
import 'package:faculty_evaluation_app/models/course_model.dart';
import 'package:faculty_evaluation_app/constants/evaluation_criteria.dart';
import 'package:faculty_evaluation_app/evaluation_form/instruction_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:faculty_evaluation_app/utils/score_calculator.dart';
import 'package:faculty_evaluation_app/utils/overall_score_card.dart';
import 'package:faculty_evaluation_app/evaluation_form/comments.dart';
import 'package:faculty_evaluation_app/evaluation_form/course_selection.dart';

class EvaluationFormView extends StatefulWidget {
  const EvaluationFormView({super.key});

  @override
  State<EvaluationFormView> createState() => _EvaluationFormViewState();
}

class _EvaluationFormViewState extends State<EvaluationFormView> {
  Map<String, int> ratings = {};
  String? selectedSemester;
  FacultyMember? selectedFacultyMember;
  Course? selectedCourse;

  final TextEditingController semester = TextEditingController();
  final TextEditingController schoolYearController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();

  Future<List<Course>> _fetchCourses() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('courses').select('id, name');
    return (response as List).map((data) => Course.fromJson(data)).toList();
  }

  Future<List<FacultyMember>> _fetchFacultyMembers() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('faculty').select('id, name');
    return (response as List)
        .map((data) => FacultyMember.fromJson(data))
        .toList();
  }

  late Future<List<FacultyMember>> _facultyFuture;

  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _facultyFuture = _fetchFacultyMembers();
    _coursesFuture = _fetchCourses();
  }

  final List<EvaluationCriterion> masteryOfSubjectCriteria =
      EvaluationCriteria.masteryOfSubjectCriteria;
  final List<EvaluationCriterion> instructionalSkillsCriteria =
      EvaluationCriteria.instructionalSkillsCriteria;
  final List<EvaluationCriterion> communicationSkillsCriteria =
      EvaluationCriteria.communicationSkillsCriteria;
  final List<EvaluationCriterion> evaluationTechniquesCriteria =
      EvaluationCriteria.evaluationTechniquesCriteria;
  final List<EvaluationCriterion> classroomManagementCriteria =
      EvaluationCriteria.classroomManagementCriteria;

  void _handleRatingChanged(String criterionId, int rating) {
    setState(() {
      ratings[criterionId] = rating;
    });
  }

  Map<String, double> _calculateOverallScores() {
    return ScoreCalculator.calculateOverallScores(
      masteryOfSubjectCriteria: masteryOfSubjectCriteria,
      instructionalSkillsCriteria: instructionalSkillsCriteria,
      communicationSkillsCriteria: communicationSkillsCriteria,
      evaluationTechniquesCriteria: evaluationTechniquesCriteria,
      classroomManagementCriteria: classroomManagementCriteria,
      ratings: ratings,
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> overallScores = _calculateOverallScores();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Evaluation Form",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: selectedSemester,
                          decoration: InputDecoration(
                            labelText: "Semester",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "1st Semester",
                              child: Text("1st Semester"),
                            ),
                            DropdownMenuItem(
                              value: "2nd Semester",
                              child: Text("2nd Semester"),
                            ),
                          ],
                          onChanged: (value) {
                            selectedSemester = value!;
                          },
                          hint: const Text("Select Semester"),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: schoolYearController,
                          decoration: InputDecoration(
                            labelText: "School Year",
                            hintText: "e.g. 2025-2026",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // COURSE(S)
                        CourseSelectionDropdown(
                          coursesFuture: _coursesFuture,
                          selectedCourse: selectedCourse,
                          onChanged: (Course? newValue) {
                            setState(() {
                              selectedCourse = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 15),
                        // ROOM
                        TextField(
                          controller: roomController,
                          decoration: InputDecoration(
                            labelText: "Room",
                            hintText: "e.g. IT Lab 202",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FacultySelectionCard(
                    facultyFuture: _facultyFuture,
                    selectedFacultyMember: selectedFacultyMember,
                    onFacultyChanged: (value) {
                      setState(() {
                        selectedFacultyMember = value;
                      });
                    },
                  ),
                  const InstructionsCard(),
                  const RatingScaleCard(),
                  EvaluationSectionCard(
                    sectionTitle: 'A. Mastery of Subject - Matter (25%)',
                    criteria: masteryOfSubjectCriteria,
                    ratings: ratings,
                    onRatingChanged: _handleRatingChanged,
                    weightPercentage: 25,
                  ),
                  EvaluationSectionCard(
                    sectionTitle: 'B. Instructional Skills (25%)',
                    criteria: instructionalSkillsCriteria,
                    ratings: ratings,
                    onRatingChanged: _handleRatingChanged,
                    weightPercentage: 25,
                  ),
                  EvaluationSectionCard(
                    sectionTitle: 'C. Communication Skills (20%)',
                    criteria: communicationSkillsCriteria,
                    ratings: ratings,
                    onRatingChanged: _handleRatingChanged,
                    weightPercentage: 20,
                  ),
                  EvaluationSectionCard(
                    sectionTitle: 'D. Evaluation Techniques (15%)',
                    criteria: evaluationTechniquesCriteria,
                    ratings: ratings,
                    onRatingChanged: _handleRatingChanged,
                    weightPercentage: 15,
                  ),
                  EvaluationSectionCard(
                    sectionTitle: 'E. Classroom Management Skills (15%)',
                    criteria: classroomManagementCriteria,
                    ratings: ratings,
                    onRatingChanged: _handleRatingChanged,
                    weightPercentage: 15,
                  ),
                  OverallScoreCard(
                    totalWeightedScore: overallScores['totalWeighted']!,
                    totalMeanScore: overallScores['totalMean']!,
                  ),
                  CommentsCard(
                    commentsController: commentsController,
                    ratings: ratings,
                    mastery: masteryOfSubjectCriteria,
                    instructional: instructionalSkillsCriteria,
                    communication: communicationSkillsCriteria,
                    evaluation: evaluationTechniquesCriteria,
                    classroom: classroomManagementCriteria,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          submitEvaluation(
                            context: context,
                            ratings: ratings,
                            selectedFacultyMember: selectedFacultyMember,
                            semester: selectedSemester ?? '',
                            schoolYear: schoolYearController.text,
                            courseName: selectedCourse?.name ?? '',
                            courseId: selectedCourse?.id ?? '',
                            room: roomController.text,
                            comments: commentsController.text,
                            masteryOfSubjectCriteria: masteryOfSubjectCriteria,
                            instructionalSkillsCriteria:
                                instructionalSkillsCriteria,
                            communicationSkillsCriteria:
                                communicationSkillsCriteria,
                            evaluationTechniquesCriteria:
                                evaluationTechniquesCriteria,
                            classroomManagementCriteria:
                                classroomManagementCriteria,
                            totalScore: overallScores['totalMean']!,
                            weightedScore: overallScores['totalWeighted']!,
                            onReset: () {
                              setState(() {
                                ratings.clear();
                                selectedFacultyMember = null;
                                selectedCourse = null;
                                selectedSemester = null;
                                schoolYearController.clear();
                                roomController.clear();
                                commentsController.clear();
                              });
                            },
                          );
                        },
                        child: const Text('Submit Evaluation'),
                      ),
                    ),
                  ),
                ]
                .expand((widget) => [widget, const SizedBox(height: 20)])
                .toList()
              ..removeLast(), // Remove the last SizedBox after submit button
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:faculty_evaluation_app/evaluation_form/rating_scale_card.dart';
// import 'package:faculty_evaluation_app/evaluation_form/faculty_selection.dart';
// import 'package:faculty_evaluation_app/evaluation_form/submit.dart';
// import 'package:faculty_evaluation_app/utils/evaluation_section.dart';
// import 'package:faculty_evaluation_app/models/evaluation_criterion.dart';
// import 'package:faculty_evaluation_app/models/faculty_models.dart';
// import 'package:faculty_evaluation_app/models/course_model.dart';
// import 'package:faculty_evaluation_app/constants/evaluation_criteria.dart';
// import 'package:faculty_evaluation_app/evaluation_form/instruction_card.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:faculty_evaluation_app/utils/score_calculator.dart';
// import 'package:faculty_evaluation_app/utils/overall_score_card.dart';
// import 'package:faculty_evaluation_app/evaluation_form/comments.dart';
// import 'package:faculty_evaluation_app/evaluation_form/course_selection.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class EvaluationFormView extends StatefulWidget {
//   const EvaluationFormView({super.key});

//   @override
//   State<EvaluationFormView> createState() => _EvaluationFormViewState();
// }

// class _EvaluationFormViewState extends State<EvaluationFormView> {
//   Map<String, int> ratings = {};
//   String? selectedSemester;
//   FacultyMember? selectedFacultyMember;
//   Course? selectedCourse;

//   final TextEditingController semester = TextEditingController();
//   final TextEditingController schoolYearController = TextEditingController();
//   final TextEditingController roomController = TextEditingController();
//   final TextEditingController commentsController = TextEditingController();

//   Future<List<Course>> _fetchCourses() async {
//     final supabase = Supabase.instance.client;
//     final response = await supabase.from('courses').select('id, name');
//     return (response as List).map((data) => Course.fromJson(data)).toList();
//   }

//   Future<List<FacultyMember>> _fetchFacultyMembers() async {
//     final supabase = Supabase.instance.client;
//     final response = await supabase.from('faculty').select('id, name');
//     return (response as List)
//         .map((data) => FacultyMember.fromJson(data))
//         .toList();
//   }

//   late Future<List<FacultyMember>> _facultyFuture;
//   late Future<List<Course>> _coursesFuture;

//   @override
//   void initState() {
//     super.initState();
//     _facultyFuture = _fetchFacultyMembers();
//     _coursesFuture = _fetchCourses();

//     // Load saved form data
//     _loadFormData();

//     // Add listeners for auto-save on text changes
//     schoolYearController.addListener(_saveFormData);
//     roomController.addListener(_saveFormData);
//     commentsController.addListener(_saveFormData);
//   }

//   @override
//   void dispose() {
//     // Save data when leaving the page
//     _saveFormData();

//     // Remove listeners
//     schoolYearController.removeListener(_saveFormData);
//     roomController.removeListener(_saveFormData);
//     commentsController.removeListener(_saveFormData);

//     // Dispose controllers
//     semester.dispose();
//     schoolYearController.dispose();
//     roomController.dispose();
//     commentsController.dispose();
//     super.dispose();
//   }

//   // Load form data from SharedPreferences
//   Future<void> _loadFormData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       setState(() {
//         // Load basic fields
//         selectedSemester = prefs.getString('eval_selectedSemester');
//         schoolYearController.text = prefs.getString('eval_schoolYear') ?? '';
//         roomController.text = prefs.getString('eval_room') ?? '';
//         commentsController.text = prefs.getString('eval_comments') ?? '';

//         // Load ratings
//         final ratingsJson = prefs.getString('eval_ratings');
//         if (ratingsJson != null && ratingsJson.isNotEmpty) {
//           final decodedRatings = json.decode(ratingsJson);
//           ratings = Map<String, int>.from(decodedRatings);
//         }

//         // Load selected faculty
//         final facultyId = prefs.getString('eval_selectedFacultyId');
//         final facultyName = prefs.getString('eval_selectedFacultyName');
//         if (facultyId != null && facultyName != null) {
//           selectedFacultyMember = FacultyMember(
//             id: facultyId,
//             name: facultyName,
//           );
//         }

//         // Load selected course
//         final courseId = prefs.getString('eval_selectedCourseId');
//         final courseName = prefs.getString('eval_selectedCourseName');
//         if (courseId != null && courseName != null) {
//           selectedCourse = Course(id: courseId, name: courseName);
//         }
//       });
//     } catch (e) {
//       debugPrint('Error loading form data: $e');
//     }
//   }

//   // Save form data to SharedPreferences
//   Future<void> _saveFormData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       await prefs.setString('eval_selectedSemester', selectedSemester ?? '');
//       await prefs.setString('eval_schoolYear', schoolYearController.text);
//       await prefs.setString('eval_room', roomController.text);
//       await prefs.setString('eval_comments', commentsController.text);
//       await prefs.setString('eval_ratings', json.encode(ratings));

//       if (selectedFacultyMember != null) {
//         await prefs.setString(
//           'eval_selectedFacultyId',
//           selectedFacultyMember!.id,
//         );
//         await prefs.setString(
//           'eval_selectedFacultyName',
//           selectedFacultyMember!.name,
//         );
//       } else {
//         await prefs.remove('eval_selectedFacultyId');
//         await prefs.remove('eval_selectedFacultyName');
//       }

//       if (selectedCourse != null) {
//         await prefs.setString('eval_selectedCourseId', selectedCourse!.id);
//         await prefs.setString('eval_selectedCourseName', selectedCourse!.name);
//       } else {
//         await prefs.remove('eval_selectedCourseId');
//         await prefs.remove('eval_selectedCourseName');
//       }
//     } catch (e) {
//       debugPrint('Error saving form data: $e');
//     }
//   }

//   // Clear saved form data
//   Future<void> _clearFormData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('eval_selectedSemester');
//       await prefs.remove('eval_schoolYear');
//       await prefs.remove('eval_room');
//       await prefs.remove('eval_comments');
//       await prefs.remove('eval_ratings');
//       await prefs.remove('eval_selectedFacultyId');
//       await prefs.remove('eval_selectedFacultyName');
//       await prefs.remove('eval_selectedCourseId');
//       await prefs.remove('eval_selectedCourseName');
//     } catch (e) {
//       debugPrint('Error clearing form data: $e');
//     }
//   }

//   final List<EvaluationCriterion> masteryOfSubjectCriteria =
//       EvaluationCriteria.masteryOfSubjectCriteria;
//   final List<EvaluationCriterion> instructionalSkillsCriteria =
//       EvaluationCriteria.instructionalSkillsCriteria;
//   final List<EvaluationCriterion> communicationSkillsCriteria =
//       EvaluationCriteria.communicationSkillsCriteria;
//   final List<EvaluationCriterion> evaluationTechniquesCriteria =
//       EvaluationCriteria.evaluationTechniquesCriteria;
//   final List<EvaluationCriterion> classroomManagementCriteria =
//       EvaluationCriteria.classroomManagementCriteria;

//   void _handleRatingChanged(String criterionId, int rating) {
//     setState(() {
//       ratings[criterionId] = rating;
//     });
//     _saveFormData(); // Auto-save on rating change
//   }

//   Map<String, double> _calculateOverallScores() {
//     return ScoreCalculator.calculateOverallScores(
//       masteryOfSubjectCriteria: masteryOfSubjectCriteria,
//       instructionalSkillsCriteria: instructionalSkillsCriteria,
//       communicationSkillsCriteria: communicationSkillsCriteria,
//       evaluationTechniquesCriteria: evaluationTechniquesCriteria,
//       classroomManagementCriteria: classroomManagementCriteria,
//       ratings: ratings,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     Map<String, double> overallScores = _calculateOverallScores();

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(1.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children:
//             [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Evaluation Form",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         DropdownButtonFormField<String>(
//                           value: selectedSemester,
//                           decoration: InputDecoration(
//                             labelText: "Semester",
//                             filled: true,
//                             fillColor: Colors.white,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Colors.blueAccent,
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                           items: const [
//                             DropdownMenuItem(
//                               value: "1st Semester",
//                               child: Text("1st Semester"),
//                             ),
//                             DropdownMenuItem(
//                               value: "2nd Semester",
//                               child: Text("2nd Semester"),
//                             ),
//                           ],
//                           onChanged: (value) {
//                             setState(() {
//                               selectedSemester = value!;
//                             });
//                             _saveFormData(); // Auto-save on semester change
//                           },
//                           hint: const Text("Select Semester"),
//                         ),
//                         const SizedBox(height: 20),
//                         TextField(
//                           controller: schoolYearController,
//                           decoration: InputDecoration(
//                             labelText: "School Year",
//                             hintText: "e.g. 2025-2026",
//                             filled: true,
//                             fillColor: Colors.white,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Colors.blueAccent,
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         // COURSE(S)
//                         CourseSelectionDropdown(
//                           coursesFuture: _coursesFuture,
//                           selectedCourse: selectedCourse,
//                           onChanged: (Course? newValue) {
//                             setState(() {
//                               selectedCourse = newValue;
//                             });
//                             _saveFormData(); // Auto-save on course change
//                           },
//                         ),
//                         const SizedBox(height: 15),
//                         // ROOM
//                         TextField(
//                           controller: roomController,
//                           decoration: InputDecoration(
//                             labelText: "Room",
//                             hintText: "e.g. IT Lab 202",
//                             filled: true,
//                             fillColor: Colors.white,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Colors.blueAccent,
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   FacultySelectionCard(
//                     facultyFuture: _facultyFuture,
//                     selectedFacultyMember: selectedFacultyMember,
//                     onFacultyChanged: (value) {
//                       setState(() {
//                         selectedFacultyMember = value;
//                       });
//                       _saveFormData(); // Auto-save on faculty change
//                     },
//                   ),
//                   const InstructionsCard(),
//                   const RatingScaleCard(),
//                   EvaluationSectionCard(
//                     sectionTitle: 'A. Mastery of Subject - Matter (25%)',
//                     criteria: masteryOfSubjectCriteria,
//                     ratings: ratings,
//                     onRatingChanged: _handleRatingChanged,
//                     weightPercentage: 25,
//                   ),
//                   EvaluationSectionCard(
//                     sectionTitle: 'B. Instructional Skills (25%)',
//                     criteria: instructionalSkillsCriteria,
//                     ratings: ratings,
//                     onRatingChanged: _handleRatingChanged,
//                     weightPercentage: 25,
//                   ),
//                   EvaluationSectionCard(
//                     sectionTitle: 'C. Communication Skills (20%)',
//                     criteria: communicationSkillsCriteria,
//                     ratings: ratings,
//                     onRatingChanged: _handleRatingChanged,
//                     weightPercentage: 20,
//                   ),
//                   EvaluationSectionCard(
//                     sectionTitle: 'D. Evaluation Techniques (15%)',
//                     criteria: evaluationTechniquesCriteria,
//                     ratings: ratings,
//                     onRatingChanged: _handleRatingChanged,
//                     weightPercentage: 15,
//                   ),
//                   EvaluationSectionCard(
//                     sectionTitle: 'E. Classroom Management Skills (15%)',
//                     criteria: classroomManagementCriteria,
//                     ratings: ratings,
//                     onRatingChanged: _handleRatingChanged,
//                     weightPercentage: 15,
//                   ),
//                   OverallScoreCard(
//                     totalWeightedScore: overallScores['totalWeighted']!,
//                     totalMeanScore: overallScores['totalMean']!,
//                   ),
//                   CommentsCard(
//                     commentsController: commentsController,
//                     ratings: ratings,
//                     mastery: masteryOfSubjectCriteria,
//                     instructional: instructionalSkillsCriteria,
//                     communication: communicationSkillsCriteria,
//                     evaluation: evaluationTechniquesCriteria,
//                     classroom: classroomManagementCriteria,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           submitEvaluation(
//                             context: context,
//                             ratings: ratings,
//                             selectedFacultyMember: selectedFacultyMember,
//                             semester: selectedSemester ?? '',
//                             schoolYear: schoolYearController.text,
//                             courseName: selectedCourse?.name ?? '',
//                             courseId: selectedCourse?.id ?? '',
//                             room: roomController.text,
//                             comments: commentsController.text,
//                             masteryOfSubjectCriteria: masteryOfSubjectCriteria,
//                             instructionalSkillsCriteria:
//                                 instructionalSkillsCriteria,
//                             communicationSkillsCriteria:
//                                 communicationSkillsCriteria,
//                             evaluationTechniquesCriteria:
//                                 evaluationTechniquesCriteria,
//                             classroomManagementCriteria:
//                                 classroomManagementCriteria,
//                             totalScore: overallScores['totalMean']!,
//                             weightedScore: overallScores['totalWeighted']!,
//                             onReset: () {
//                               setState(() {
//                                 ratings.clear();
//                                 selectedFacultyMember = null;
//                                 selectedCourse = null;
//                                 selectedSemester = null;
//                                 schoolYearController.clear();
//                                 roomController.clear();
//                                 commentsController.clear();
//                               });
//                               _clearFormData(); // Clear saved data on reset
//                             },
//                           );
//                         },
//                         child: const Text('Submit Evaluation'),
//                       ),
//                     ),
//                   ),
//                 ]
//                 .expand((widget) => [widget, const SizedBox(height: 20)])
//                 .toList()
//               ..removeLast(), // Remove the last SizedBox after submit button
//       ),
//     );
//   }
// }
