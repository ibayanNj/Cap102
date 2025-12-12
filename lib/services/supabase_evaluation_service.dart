// lib/services/supabase_evaluation_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:faculty_evaluation_app/services/print_services.dart';
import 'package:faculty_evaluation_app/services/evaluation_adapter.dart';

class SupabaseEvaluationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch a specific evaluation by ID (from your existing evaluations table)
  Future<EvaluationData?> getEvaluationById(String evaluationId) async {
    try {
      final response = await _supabase
          .from('evaluations')
          .select('''
            *,
            faculty:faculty_id(name),
            courses:course_id(name)
          ''')
          .eq('id', evaluationId)
          .single();

      // Transform the data to match PDF format
      return _transformToEvaluationData(response);
    } catch (e) {
      return null;
    }
  }

  /// Fetch all evaluations ordered by creation date
  Future<List<EvaluationData>> getAllEvaluations() async {
    try {
      final response = await _supabase
          .from('evaluations')
          .select('''
            *,
            faculty:faculty_id(name),
            courses:course_id(name)
          ''')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _transformToEvaluationData(json))
          .whereType<EvaluationData>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch evaluations by faculty ID
  Future<List<EvaluationData>> getEvaluationsByFaculty(String facultyId) async {
    try {
      final response = await _supabase
          .from('evaluations')
          .select('''
            *,
            faculty:faculty_id(name),
            courses:course_id(name)
          ''')
          .eq('faculty_id', facultyId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _transformToEvaluationData(json))
          .whereType<EvaluationData>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch evaluations by semester and school year
  Future<List<EvaluationData>> getEvaluationsBySemester({
    required String semester,
    required String schoolYear,
  }) async {
    try {
      final response = await _supabase
          .from('evaluations')
          .select('''
            *,
            faculty:faculty_id(name),
            courses:course_id(name)
          ''')
          .eq('semester', semester)
          .eq('school_year', schoolYear)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _transformToEvaluationData(json))
          .whereType<EvaluationData>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Transform database record to EvaluationData for PDF
  EvaluationData? _transformToEvaluationData(Map<String, dynamic> record) {
    try {
      // Extract faculty name from joined data
      String facultyName = 'N/A';
      if (record['faculty'] != null) {
        if (record['faculty'] is Map) {
          facultyName = record['faculty']['name'] ?? 'N/A';
        } else if (record['faculty'] is List &&
            (record['faculty'] as List).isNotEmpty) {
          facultyName = record['faculty'][0]['name'] ?? 'N/A';
        }
      }

      // Extract course name from joined data
      String courseName = 'N/A';
      if (record['courses'] != null) {
        if (record['courses'] is Map) {
          courseName = record['courses']['name'] ?? 'N/A';
        } else if (record['courses'] is List &&
            (record['courses'] as List).isNotEmpty) {
          courseName = record['courses'][0]['name'] ?? 'N/A';
        }
      }

      // Prepare data for adapter
      Map<String, dynamic> adaptedData = {
        'id': record['id'],
        'faculty_name': facultyName,
        'course_name': courseName,
        'room': record['room'],
        'semester': record['semester'],
        'school_year': record['school_year'],
        'ratings': record['ratings'] ?? {},
        'comments': record['comments'],
        'evaluator_name': record['evaluator_name'] ?? 'Evaluator',
        'created_at': record['created_at'],
      };

      return EvaluationAdapter.fromDatabase(adaptedData);
    } catch (e) {
      return null;
    }
  }
}
