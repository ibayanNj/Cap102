import 'package:faculty_evaluation_app/models/evaluation_criterion.dart';

class ScoreCalculator {
  /// Calculates raw score for a category
  static double calculateCategoryRawScore(
    List<EvaluationCriterion> criteria,
    Map<String, int> ratings,
  ) {
    double raw = 0;
    for (var criterion in criteria) {
      raw += ratings[criterion.id] ?? 0;
    }
    return raw;
  }

  /// Calculates mean score for a category
  static double calculateCategoryMean(
    List<EvaluationCriterion> criteria,
    Map<String, int> ratings,
  ) {
    if (criteria.isEmpty) return 0;
    double raw = calculateCategoryRawScore(criteria, ratings);
    return raw / criteria.length;
  }

  /// Calculates weighted mean for a category
  static double calculateCategoryWeightedMean(
    List<EvaluationCriterion> criteria,
    Map<String, int> ratings,
    double weightPercentage,
  ) {
    double mean = calculateCategoryMean(criteria, ratings);
    return mean * (weightPercentage / 100);
  }

  /// Calculates overall scores across all categories
  static Map<String, double> calculateOverallScores({
    required List<EvaluationCriterion> masteryOfSubjectCriteria,
    required List<EvaluationCriterion> instructionalSkillsCriteria,
    required List<EvaluationCriterion> communicationSkillsCriteria,
    required List<EvaluationCriterion> evaluationTechniquesCriteria,
    required List<EvaluationCriterion> classroomManagementCriteria,
    required Map<String, int> ratings,
  }) {
    // Calculate raw scores for each category
    double masteryRaw = calculateCategoryRawScore(
      masteryOfSubjectCriteria,
      ratings,
    );
    double instructionalRaw = calculateCategoryRawScore(
      instructionalSkillsCriteria,
      ratings,
    );
    double communicationRaw = calculateCategoryRawScore(
      communicationSkillsCriteria,
      ratings,
    );
    double evaluationRaw = calculateCategoryRawScore(
      evaluationTechniquesCriteria,
      ratings,
    );
    double classroomRaw = calculateCategoryRawScore(
      classroomManagementCriteria,
      ratings,
    );

    // Calculate means
    double masteryMean = calculateCategoryMean(
      masteryOfSubjectCriteria,
      ratings,
    );
    double instructionalMean = calculateCategoryMean(
      instructionalSkillsCriteria,
      ratings,
    );
    double communicationMean = calculateCategoryMean(
      communicationSkillsCriteria,
      ratings,
    );
    double evaluationMean = calculateCategoryMean(
      evaluationTechniquesCriteria,
      ratings,
    );
    double classroomMean = calculateCategoryMean(
      classroomManagementCriteria,
      ratings,
    );

    // Calculate weighted means
    double masteryWeighted = masteryMean * 0.25;
    double instructionalWeighted = instructionalMean * 0.25;
    double communicationWeighted = communicationMean * 0.20;
    double evaluationWeighted = evaluationMean * 0.15;
    double classroomWeighted = classroomMean * 0.15;

    // Total weighted score
    double totalWeighted =
        masteryWeighted +
        instructionalWeighted +
        communicationWeighted +
        evaluationWeighted +
        classroomWeighted;

    // Overall mean for descriptive equivalent
    double totalRaw =
        masteryRaw +
        instructionalRaw +
        communicationRaw +
        evaluationRaw +
        classroomRaw;
    int totalCriteria =
        masteryOfSubjectCriteria.length +
        instructionalSkillsCriteria.length +
        communicationSkillsCriteria.length +
        evaluationTechniquesCriteria.length +
        classroomManagementCriteria.length;
    double totalMean = totalCriteria > 0 ? totalRaw / totalCriteria : 0;

    return {
      'masteryRaw': masteryRaw,
      'masteryMean': masteryMean,
      'masteryWeighted': masteryWeighted,
      'instructionalRaw': instructionalRaw,
      'instructionalMean': instructionalMean,
      'instructionalWeighted': instructionalWeighted,
      'communicationRaw': communicationRaw,
      'communicationMean': communicationMean,
      'communicationWeighted': communicationWeighted,
      'evaluationRaw': evaluationRaw,
      'evaluationMean': evaluationMean,
      'evaluationWeighted': evaluationWeighted,
      'classroomRaw': classroomRaw,
      'classroomMean': classroomMean,
      'classroomWeighted': classroomWeighted,
      'totalRaw': totalRaw,
      'totalMean': totalMean,
      'totalWeighted': totalWeighted,
      'totalCriteria': totalCriteria.toDouble(),
    };
  }

  /// Gets individual ratings for a category
  static List<int> getCategoryRatings(
    List<EvaluationCriterion> criteria,
    Map<String, int> ratings,
  ) {
    List<int> categoryRatings = [];
    for (var criterion in criteria) {
      int rating = ratings[criterion.id] ?? 0;
      if (rating > 0) {
        categoryRatings.add(rating);
      }
    }
    return categoryRatings;
  }
}
