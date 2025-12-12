// lib/services/evaluation_adapter.dart
import 'package:faculty_evaluation_app/services/print_services.dart';
import 'package:faculty_evaluation_app/constants/evaluation_criteria.dart';

class EvaluationAdapter {
  /// Convert database evaluation to PDF format
  static EvaluationData fromDatabase(Map<String, dynamic> dbData) {
    // Get criterion text from IDs
    Map<String, int> masteryRatings = _convertRatingsToText(
      dbData['ratings'] as Map<String, dynamic>? ?? {},
      EvaluationCriteria.masteryOfSubjectCriteria,
    );

    Map<String, int> instructionalRatings = _convertRatingsToText(
      dbData['ratings'] as Map<String, dynamic>? ?? {},
      EvaluationCriteria.instructionalSkillsCriteria,
    );

    Map<String, int> communicationRatings = _convertRatingsToText(
      dbData['ratings'] as Map<String, dynamic>? ?? {},
      EvaluationCriteria.communicationSkillsCriteria,
    );

    Map<String, int> evaluationRatings = _convertRatingsToText(
      dbData['ratings'] as Map<String, dynamic>? ?? {},
      EvaluationCriteria.evaluationTechniquesCriteria,
    );

    Map<String, int> managementRatings = _convertRatingsToText(
      dbData['ratings'] as Map<String, dynamic>? ?? {},
      EvaluationCriteria.classroomManagementCriteria,
    );

    return EvaluationData(
      facultyName: dbData['faculty_name'] ?? 'N/A',
      courseTaught: dbData['course_name'] ?? 'N/A',
      dateTime: _formatDateTime(dbData['created_at']),
      buildingRoom: dbData['room'] ?? 'N/A',
      semester: dbData['semester'] ?? 'N/A',
      schoolYear: dbData['school_year'] ?? 'N/A',
      masteryRatings: masteryRatings,
      instructionalRatings: instructionalRatings,
      communicationRatings: communicationRatings,
      evaluationRatings: evaluationRatings,
      managementRatings: managementRatings,
      comments: dbData['comments'] ?? '',
      evaluatorName: dbData['evaluator_name'] ?? 'N/A',
      evaluatorSignature: '',
      facultySignature: '',
      date: _formatDate(dbData['created_at']),
    );
  }

  /// Convert criterion IDs to criterion text with ratings
  static Map<String, int> _convertRatingsToText(
    Map<String, dynamic> ratings,
    List<dynamic> criteria,
  ) {
    Map<String, int> result = {};

    for (var criterion in criteria) {
      // Handle both EvaluationCriterion objects and Map
      String id = criterion is Map ? criterion['id'] : criterion.id;
      String text = criterion is Map ? criterion['text'] : criterion.text;

      if (ratings.containsKey(id)) {
        int rating = ratings[id] is int
            ? ratings[id]
            : int.tryParse(ratings[id].toString()) ?? 0;
        result[text] = rating;
      }
    }

    return result;
  }

  /// Format DateTime string to time range
  static String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';

    try {
      DateTime dt = DateTime.parse(dateTime.toString());
      String hour = dt.hour.toString().padLeft(2, '0');
      String minute = dt.minute.toString().padLeft(2, '0');

      // Create a 1.5 hour time range
      DateTime endTime = dt.add(const Duration(hours: 1, minutes: 30));
      String endHour = endTime.hour.toString().padLeft(2, '0');
      String endMinute = endTime.minute.toString().padLeft(2, '0');

      return '$hour:$minute -- $endHour:$endMinute';
    } catch (e) {
      return 'N/A';
    }
  }

  /// Format date
  static String _formatDate(dynamic dateTime) {
    if (dateTime == null) return 'N/A';

    try {
      DateTime dt = DateTime.parse(dateTime.toString());
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
