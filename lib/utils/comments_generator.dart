import '../models/evaluation_criterion.dart';

class CommentsGenerator {
  static String generateComments({
    required List<EvaluationCriterion> masteryOfSubjectCriteria,
    required List<EvaluationCriterion> instructionalSkillsCriteria,
    required List<EvaluationCriterion> communicationSkillsCriteria,
    required List<EvaluationCriterion> evaluationTechniquesCriteria,
    required List<EvaluationCriterion> classroomManagementCriteria,
    required Map<String, int> ratings,
  }) {
    int totalCriteria =
        masteryOfSubjectCriteria.length +
        instructionalSkillsCriteria.length +
        communicationSkillsCriteria.length +
        evaluationTechniquesCriteria.length +
        classroomManagementCriteria.length;

    double totalScore = 0;
    void addFrom(List<EvaluationCriterion> list) {
      for (final c in list) {
        totalScore += (ratings[c.id] ?? 0).toDouble();
      }
    }

    addFrom(masteryOfSubjectCriteria);
    addFrom(instructionalSkillsCriteria);
    addFrom(communicationSkillsCriteria);
    addFrom(evaluationTechniquesCriteria);
    addFrom(classroomManagementCriteria);

    final double average = totalCriteria == 0 ? 0 : totalScore / totalCriteria;

    final List<String> strengths = [];
    final List<String> improvements = [];

    void collect(List<EvaluationCriterion> list) {
      for (final c in list) {
        final int r = ratings[c.id] ?? 0;
        if (r >= 4) strengths.add(_nameFor(c.id));
        if (r > 0 && r <= 2) improvements.add(_nameFor(c.id));
      }
    }

    collect(masteryOfSubjectCriteria);
    collect(instructionalSkillsCriteria);
    collect(communicationSkillsCriteria);
    collect(evaluationTechniquesCriteria);
    collect(classroomManagementCriteria);

    if (improvements.isEmpty) {
      return 'All areas demonstrate satisfactory or above performance. Continue maintaining current teaching standards.';
    }

    return improvements.take(4).join(', ');
  }

  static String _nameFor(String id) {
    switch (id) {
      case 'logical_presentation':
        return 'Enhance logical organization and sequencing of lesson content';
      case 'relates_to_issues':
        return 'Strengthen connections between lessons and current real-world issues';
      case 'beyond_content':
        return 'Provide deeper explanations that extend beyond textbook material';
      case 'independent_teaching':
        return 'Develop greater autonomy and confidence in independent teaching';
      case 'motivation_techniques':
        return 'Implement more varied and effective student motivation strategies';
      case 'links_past_present':
        return 'Improve integration of prior knowledge with new content';
      case 'varied_strategies':
        return 'Diversify instructional methods to accommodate different learning styles';
      case 'varied_questions':
        return 'Utilize a broader range of questioning techniques to promote critical thinking';
      case 'anticipates_difficulties':
        return 'Better anticipate and address potential student learning challenges';
      case 'provides_reinforcement':
        return 'Increase positive reinforcement and constructive feedback';
      case 'multiple_sources':
        return 'Incorporate diverse resources and materials beyond primary textbook';
      case 'encourages_speaking':
        return 'Create more opportunities for student expression and participation';
      case 'integrates_values':
        return 'Strengthen integration of character development and values education';
      case 'free_expression':
        return 'Foster a more supportive environment for student voice and opinions';
      case 'well_modulated_voice':
        return 'Improve voice projection, clarity, and modulation for better engagement';
      case 'appropriate_language':
        return 'Adjust language complexity to better match student comprehension levels';
      case 'correct_pronunciation':
        return 'Focus on accurate pronunciation and enunciation';
      case 'correct_grammar':
        return 'Ensure consistent use of proper grammar in verbal instruction';
      case 'listens_attentively':
        return 'Demonstrate more active listening and responsiveness to student input';
      case 'evaluates_achievement':
        return 'Align assessment practices more closely with learning objectives';
      case 'appropriate_assessment':
        return 'Utilize assessment tools that better measure student understanding';
      case 'maintains_discipline':
        return 'Strengthen classroom management and discipline strategies';
      case 'manages_time':
        return 'Improve time allocation and pacing throughout lessons';
      case 'maximizes_resources':
        return 'Make more efficient and creative use of available teaching resources';
      case 'good_rapport':
        return 'Build stronger professional relationships with students';
      case 'respects_limitations':
        return 'Show greater sensitivity to individual student needs and limitations';
      default:
        return 'Focus on professional development in this area';
    }
  }
}
