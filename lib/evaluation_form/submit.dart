import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:faculty_evaluation_app/models/faculty_models.dart';
import 'package:faculty_evaluation_app/models/evaluation_criterion.dart';

Future<void> submitEvaluation({
  required BuildContext context,
  required Map<String, int> ratings,
  required FacultyMember? selectedFacultyMember,
  required String semester,
  required String schoolYear,
  required String courseName,
  required String courseId,
  required String room,
  required String comments,
  required List<EvaluationCriterion> masteryOfSubjectCriteria,
  required List<EvaluationCriterion> instructionalSkillsCriteria,
  required List<EvaluationCriterion> communicationSkillsCriteria,
  required List<EvaluationCriterion> evaluationTechniquesCriteria,
  required List<EvaluationCriterion> classroomManagementCriteria,
  required double totalScore,
  required double weightedScore,
  required VoidCallback onReset,
}) async {
  final supabase = Supabase.instance.client;

  // Validation
  if (selectedFacultyMember == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a faculty member')),
    );
    return;
  }

  if (semester.isEmpty || schoolYear.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in semester and school year')),
    );
    return;
  }

  // Check if all criteria are rated
  int totalCriteria =
      masteryOfSubjectCriteria.length +
      instructionalSkillsCriteria.length +
      communicationSkillsCriteria.length +
      evaluationTechniquesCriteria.length +
      classroomManagementCriteria.length;

  if (ratings.length < totalCriteria) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Please rate all criteria (${ratings.length}/$totalCriteria rated)',
        ),
      ),
    );
    return;
  }
  try {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Calculate category scores
    double masteryScore =
        masteryOfSubjectCriteria
            .map((c) => ratings[c.id] ?? 0)
            .reduce((a, b) => a + b) /
        masteryOfSubjectCriteria.length;

    double instructionalScore =
        instructionalSkillsCriteria
            .map((c) => ratings[c.id] ?? 0)
            .reduce((a, b) => a + b) /
        instructionalSkillsCriteria.length;

    double communicationScore =
        communicationSkillsCriteria
            .map((c) => ratings[c.id] ?? 0)
            .reduce((a, b) => a + b) /
        communicationSkillsCriteria.length;

    double evaluationScore =
        evaluationTechniquesCriteria
            .map((c) => ratings[c.id] ?? 0)
            .reduce((a, b) => a + b) /
        evaluationTechniquesCriteria.length;

    double classroomScore =
        classroomManagementCriteria
            .map((c) => ratings[c.id] ?? 0)
            .reduce((a, b) => a + b) /
        classroomManagementCriteria.length;

    // Prepare data
    final evaluationData = {
      // 'evaluator_id': currentUser.id,
      'faculty_id': selectedFacultyMember.id,
      'faculty_name': selectedFacultyMember.name,
      'course_id': courseId,
      'course_name': courseName,
      'semester': semester,
      'school_year': schoolYear,
      'room': room,
      'comments': comments,
      'total_score': totalScore,
      'weighted_score': weightedScore,
      'mastery_score': masteryScore,
      'instructional_score': instructionalScore,
      'communication_score': communicationScore,
      'evaluation_score': evaluationScore,
      'classroom_score': classroomScore,

      // Individual ratings - dynamically add based on list length
      for (int i = 0; i < masteryOfSubjectCriteria.length; i++)
        'mastery_${i + 1}': ratings[masteryOfSubjectCriteria[i].id] ?? 0,

      for (int i = 0; i < instructionalSkillsCriteria.length; i++)
        'instructional_${i + 1}':
            ratings[instructionalSkillsCriteria[i].id] ?? 0,

      for (int i = 0; i < communicationSkillsCriteria.length; i++)
        'communication_${i + 1}':
            ratings[communicationSkillsCriteria[i].id] ?? 0,

      for (int i = 0; i < evaluationTechniquesCriteria.length; i++)
        'evaluation_${i + 1}': ratings[evaluationTechniquesCriteria[i].id] ?? 0,

      for (int i = 0; i < classroomManagementCriteria.length; i++)
        'classroom_${i + 1}': ratings[classroomManagementCriteria[i].id] ?? 0,

      'submitted_at': DateTime.now().toIso8601String(),
    };

    // Insert into database
    await supabase.from('evaluations').insert(evaluationData);

    // Close loading dialog
    if (context.mounted) Navigator.of(context).pop();

    // Show success
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evaluation submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Reset form
    onReset();
  } catch (e) {
    // Close loading dialog
    if (context.mounted) Navigator.of(context).pop();

    // Show error
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting evaluation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
