// lib/evaluation_form/controllers/evaluation_controller.dart
import 'package:faculty_evaluation_app/models/evaluation_criterion.dart';
import 'package:faculty_evaluation_app/models/faculty_models.dart';

class EvaluationController {
  final Map<String, int> ratings = {};
  FacultyMember? selectedFacultyMember;

  double calculateCategoryRawScore(List<EvaluationCriterion> criteria) {
    return criteria.fold(0, (sum, c) => sum + (ratings[c.id] ?? 0));
  }

  double calculateTotalScore(List<List<EvaluationCriterion>> allCriteria) {
    return allCriteria.fold(
      0,
      (sum, category) => sum + calculateCategoryRawScore(category),
    );
  }

  int getRatingForCriterion(String criterionId) => ratings[criterionId] ?? 0;

  String getRatingLabel(int rating) {
    switch (rating) {
      case 5:
        return 'Outstanding';
      case 4:
        return 'Very Satisfactory';
      case 3:
        return 'Satisfactory';
      case 2:
        return 'Fair';
      case 1:
        return 'Poor';
      default:
        return 'Not rated';
    }
  }

  void setRating(String criterionId, int value) {
    ratings[criterionId] = value;
  }
}
