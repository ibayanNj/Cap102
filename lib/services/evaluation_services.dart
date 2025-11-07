import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:faculty_evaluation_app/models/faculty_models.dart';

class EvaluationService {
  final _supabase = Supabase.instance.client;

  Future<List<FacultyMember>> fetchFacultyMembers() async {
    final response = await _supabase.from('faculty').select('id, name');
    return (response as List)
        .map((data) => FacultyMember.fromJson(data))
        .toList();
  }

  Future<String> submitEvaluation({
    required String facultyId,
    required Map<String, int> ratings,
    required Map<String, double> overallScores,
    required double totalScore,
    required double averageScore,
    required int roundedAverage,
    String? schoolYear,
    String? course,
    String? room,
    String? comments,
  }) async {
    final user = _supabase.auth.currentUser;

    final evaluationData = {
      'faculty_id': facultyId,
      'evaluator_id': user?.id,
      'school_year': schoolYear?.trim(),
      'course': course?.trim(),
      'room': room?.trim(),
      'comments': comments?.trim(),
      'total_score': totalScore,
      'average_score': averageScore,
      'rounded_average': roundedAverage,
      'total_weighted_score': overallScores['totalWeighted'],
      'total_mean_score': overallScores['totalMean'],
      'mastery_score': overallScores['masteryWeighted'],
      'instructional_score': overallScores['instructionalWeighted'],
      'communication_score': overallScores['communicationWeighted'],
      'evaluation_techniques_score': overallScores['evaluationWeighted'],
      'classroom_management_score': overallScores['classroomWeighted'],
      'created_at': DateTime.now().toIso8601String(),
    };

    final evaluationResponse = await _supabase
        .from('evaluations')
        .insert(evaluationData)
        .select('id')
        .single();

    final evaluationId = evaluationResponse['id'];

    final ratingsData = ratings.entries
        .map(
          (entry) => {
            'evaluation_id': evaluationId,
            'criterion_id': entry.key,
            'rating': entry.value,
          },
        )
        .toList();

    if (ratingsData.isNotEmpty) {
      await _supabase.from('evaluation_ratings').insert(ratingsData);
    }

    return evaluationId;
  }
}
