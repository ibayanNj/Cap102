import 'package:supabase_flutter/supabase_flutter.dart';

class EvaluationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch evaluations for a specific faculty by faculty_id (No auth required)
  /// Pass the faculty_id like '2019-2239123'
  Future<List<Evaluation>> fetchFacultyEvaluations(String facultyId) async {
    try {
      final response = await _supabase
          .from('evaluations')
          .select()
          .eq('faculty_id', facultyId)
          .order('submitted_at', ascending: false);

      return (response as List)
          .map((json) => Evaluation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch evaluations: $e');
    }
  }

  /// Fetch all evaluations (No filtering, no auth required)
  Future<List<Evaluation>> fetchAllEvaluations() async {
    try {
      final response = await _supabase
          .from('evaluations')
          .select()
          .order('submitted_at', ascending: false);

      return (response as List)
          .map((json) => Evaluation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch evaluations: $e');
    }
  }

  /// Fetch evaluations by faculty_id (for viewing specific faculty's evaluations)
  Future<List<Evaluation>> fetchEvaluationsByFacultyId(String facultyId) async {
    try {
      final response = await _supabase
          .from('evaluations')
          .select()
          .eq('faculty_id', facultyId)
          .order('submitted_at', ascending: false);

      return (response as List)
          .map((json) => Evaluation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch evaluations: $e');
    }
  }

  /// Calculate average weighted score
  Future<double> getAverageWeightedScore(String facultyId) async {
    try {
      final evaluations = await fetchFacultyEvaluations(facultyId);

      if (evaluations.isEmpty) return 0.0;

      final total = evaluations.fold<double>(
        0.0,
        (sum, eval) => sum + (eval.weightedScore ?? 0.0),
      );

      return total / evaluations.length;
    } catch (e) {
      throw Exception('Failed to calculate average: $e');
    }
  }

  /// Get evaluation statistics
  Future<EvaluationStats> getEvaluationStats(String facultyId) async {
    try {
      final evaluations = await fetchFacultyEvaluations(facultyId);

      if (evaluations.isEmpty) {
        return EvaluationStats(
          totalEvaluations: 0,
          averageWeightedScore: 0.0,
          averageMasteryScore: 0.0,
          averageInstructionalScore: 0.0,
          averageCommunicationScore: 0.0,
        );
      }

      final avgWeighted =
          evaluations.fold<double>(
            0.0,
            (sum, e) => sum + (e.weightedScore ?? 0.0),
          ) /
          evaluations.length;

      final avgMastery =
          evaluations.fold<double>(
            0.0,
            (sum, e) => sum + (e.masteryScore ?? 0.0),
          ) /
          evaluations.length;

      final avgInstructional =
          evaluations.fold<double>(
            0.0,
            (sum, e) => sum + (e.instructionalScore ?? 0.0),
          ) /
          evaluations.length;

      final avgCommunication =
          evaluations.fold<double>(
            0.0,
            (sum, e) => sum + (e.communicationScore ?? 0.0),
          ) /
          evaluations.length;

      return EvaluationStats(
        totalEvaluations: evaluations.length,
        averageWeightedScore: avgWeighted,
        averageMasteryScore: avgMastery,
        averageInstructionalScore: avgInstructional,
        averageCommunicationScore: avgCommunication,
      );
    } catch (e) {
      throw Exception('Failed to get stats: $e');
    }
  }
}

/// Evaluation Model matching your exact schema
class Evaluation {
  final String id;
  final String facultyId;
  final String courseId;
  final String semester;
  final String schoolYear;
  final String? room;
  final String? comments;
  final double? masteryScore;
  final double? instructionalScore;
  final double? communicationScore;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? evaluationScore;
  final double? classroomScore;
  final String? courseName;
  final String? facultyName;
  final DateTime? submittedAt;
  final double? totalScore;
  final double? weightedScore;
  final String? academicPeriodId;

  Evaluation({
    required this.id,
    required this.facultyId,
    required this.courseId,
    required this.semester,
    required this.schoolYear,
    this.room,
    this.comments,
    this.masteryScore,
    this.instructionalScore,
    this.communicationScore,
    this.createdAt,
    this.updatedAt,
    this.evaluationScore,
    this.classroomScore,
    this.courseName,
    this.facultyName,
    this.submittedAt,
    this.totalScore,
    this.weightedScore,
    this.academicPeriodId,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['id'] as String,
      facultyId: json['faculty_id'] as String,
      courseId: json['course_id'] as String,
      semester: json['semester'] as String,
      schoolYear: json['school_year'] as String,
      room: json['room'] as String?,
      comments: json['comments'] as String?,
      masteryScore: _parseDouble(json['mastery_score']),
      instructionalScore: _parseDouble(json['instructional_score']),
      communicationScore: _parseDouble(json['communication_score']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      evaluationScore: _parseDouble(json['evaluation_score']),
      classroomScore: _parseDouble(json['classroom_score']),
      courseName: json['course_name'] as String?,
      facultyName: json['faculty_name'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      totalScore: _parseDouble(json['total_score']),
      weightedScore: _parseDouble(json['weighted_score']),
      academicPeriodId: json['academic_period_id'] as String?,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String get performanceLevel {
    final score = weightedScore ?? totalScore ?? 0.0;
    if (score >= 4.5) return 'Outstanding';
    if (score >= 4.0) return 'Very Satisfactory';
    if (score >= 3.5) return 'Satisfactory';
    if (score >= 3.0) return 'Fair';
    return 'Needs Improvement';
  }
}

/// Statistics Model
class EvaluationStats {
  final int totalEvaluations;
  final double averageWeightedScore;
  final double averageMasteryScore;
  final double averageInstructionalScore;
  final double averageCommunicationScore;

  EvaluationStats({
    required this.totalEvaluations,
    required this.averageWeightedScore,
    required this.averageMasteryScore,
    required this.averageInstructionalScore,
    required this.averageCommunicationScore,
  });
}
