import 'package:faculty_evaluation_app/models/evaluation_criterion.dart';

class RatingUtils {
  static double calculateTotalScore(
    List<EvaluationCriterion> mastery,
    List<EvaluationCriterion> instructional,
    List<EvaluationCriterion> communication,
    List<EvaluationCriterion> evaluation,
    List<EvaluationCriterion> classroom,
    Map<String, int> ratings,
  ) {
    double total = 0;

    for (var list in [
      mastery,
      instructional,
      communication,
      evaluation,
      classroom,
    ]) {
      for (var criterion in list) {
        if (ratings.containsKey(criterion.id) &&
            ratings[criterion.id] != null) {
          total += ratings[criterion.id]!.toDouble();
        }
      }
    }

    return total;
  }

  static String getRatingLabel(int rating) {
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
}
