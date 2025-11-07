// import 'package:faculty_evaluation_app/models/evaluation_score.dart';
// import 'package:faculty_evaluation_app/models/evaluation_criterion.dart';

// class ScoreCalculator {
//   // Helper function to sum scores for a list of criteria
//   static double _calculateCategoryRawScore(
//     List<EvaluationCriterion> criteria,
//     Map<String, int> ratings,
//   ) {
//     double sum = 0;
//     for (var criterion in criteria) {
//       sum += ratings[criterion.id] ?? 0;
//     }
//     return sum;
//   }

//   // The main static method to perform all calculations
//   static EvaluationScores calculate({
//     required List<EvaluationCriterion> masteryOfSubjectCriteria,
//     required List<EvaluationCriterion> instructionalSkillsCriteria,
//     required List<EvaluationCriterion> communicationSkillsCriteria,
//     required List<EvaluationCriterion> evaluationTechniquesCriteria,
//     required List<EvaluationCriterion> classroomManagementCriteria,
//     required Map<String, int> ratings,
//   }) {
//     // Raw scores
//     double masteryRaw = _calculateCategoryRawScore(
//       masteryOfSubjectCriteria,
//       ratings,
//     );
//     double instructionalRaw = _calculateCategoryRawScore(
//       instructionalSkillsCriteria,
//       ratings,
//     );
//     double communicationRaw = _calculateCategoryRawScore(
//       communicationSkillsCriteria,
//       ratings,
//     );
//     double evaluationRaw = _calculateCategoryRawScore(
//       evaluationTechniquesCriteria,
//       ratings,
//     );
//     double classroomRaw = _calculateCategoryRawScore(
//       classroomManagementCriteria,
//       ratings,
//     );

//     // Counts
//     double masteryCount = masteryOfSubjectCriteria.length.toDouble();
//     double instructionalCount = instructionalSkillsCriteria.length.toDouble();
//     double communicationCount = communicationSkillsCriteria.length.toDouble();
//     double evaluationCount = evaluationTechniquesCriteria.length.toDouble();
//     double classroomCount = classroomManagementCriteria.length.toDouble();

//     // Means (with check for division by zero)
//     double masteryMean = masteryCount > 0 ? masteryRaw / masteryCount : 0.0;
//     double instructionalMean = instructionalCount > 0
//         ? instructionalRaw / instructionalCount
//         : 0.0;
//     double communicationMean = communicationCount > 0
//         ? communicationRaw / communicationCount
//         : 0.0;
//     double evaluationMean = evaluationCount > 0
//         ? evaluationRaw / evaluationCount
//         : 0.0;
//     double classroomMean = classroomCount > 0
//         ? classroomRaw / classroomCount
//         : 0.0;

//     // Weighted scores
//     double masteryWeighted = masteryMean * 0.25;
//     double instructionalWeighted = instructionalMean * 0.25;
//     double communicationWeighted = communicationMean * 0.20;
//     double evaluationWeighted = evaluationMean * 0.15;
//     double classroomWeighted = classroomMean * 0.15;

//     // Totals
//     double totalRaw =
//         masteryRaw +
//         instructionalRaw +
//         communicationRaw +
//         evaluationRaw +
//         classroomRaw;
//     double totalCriteria =
//         masteryCount +
//         instructionalCount +
//         communicationCount +
//         evaluationCount +
//         classroomCount;
//     double totalMean = totalCriteria > 0 ? totalRaw / totalCriteria : 0.0;
//     double totalWeighted =
//         masteryWeighted +
//         instructionalWeighted +
//         communicationWeighted +
//         evaluationWeighted +
//         classroomWeighted;

//     // Return the strongly-typed data model object
//     return EvaluationScores(
//       masteryRaw: masteryRaw,
//       masteryMean: masteryMean,
//       masteryWeighted: masteryWeighted,
//       instructionalRaw: instructionalRaw,
//       instructionalMean: instructionalMean,
//       instructionalWeighted: instructionalWeighted,
//       communicationRaw: communicationRaw,
//       communicationMean: communicationMean,
//       communicationWeighted: communicationWeighted,
//       evaluationRaw: evaluationRaw,
//       evaluationMean: evaluationMean,
//       evaluationWeighted: evaluationWeighted,
//       classroomRaw: classroomRaw,
//       classroomMean: classroomMean,
//       classroomWeighted: classroomWeighted,
//       totalRaw: totalRaw,
//       totalMean: totalMean,
//       totalWeighted: totalWeighted,
//       totalCriteria: totalCriteria,
//     );
//   }
// }
