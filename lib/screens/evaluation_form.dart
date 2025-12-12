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
  final supabase = Supabase.instance.client;

  Map<String, int> ratings = {};
  String? selectedSemester;
  FacultyMember? selectedFacultyMember;
  Course? selectedCourse;

  String? activeSemester;
  String? activeSchoolYear;
  String? activePeriodId;
  bool isLoadingPeriod = true;

  Future<void> _fetchActivePeriod() async {
    try {
      setState(() => isLoadingPeriod = true);

      final response = await supabase
          .from('academic_periods')
          .select('id, semester, school_year')
          .eq('is_active', true)
          .single();

      setState(() {
        activePeriodId = response['id'];
        activeSemester = response['semester'];
        activeSchoolYear = response['school_year'];
        isLoadingPeriod = false;
      });
    } catch (e) {
      setState(() => isLoadingPeriod = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching active period: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final TextEditingController roomController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();

  Future<List<Course>> _fetchCourses() async {
    final response = await supabase.from('courses').select('id, name');
    return (response as List).map((data) => Course.fromJson(data)).toList();
  }

  Future<List<FacultyMember>> _fetchFacultyMembers() async {
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
    _fetchActivePeriod();
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
                      if (isLoadingPeriod)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (activeSemester != null &&
                          activeSchoolYear != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Current Academic Period",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    activeSemester!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.school,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "S.Y. $activeSchoolYear",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "No active academic period set. Please contact your administrator.",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
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
                          semester: activeSemester!, // Use fetched value
                          schoolYear: activeSchoolYear!, // Use fetched value
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
              ].expand((widget) => [widget, const SizedBox(height: 20)]).toList()
              ..removeLast(), // Remove the last SizedBox after submit button
      ),
    );
  }
}
