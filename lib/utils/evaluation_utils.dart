import 'package:flutter/material.dart';
import 'package:faculty_evaluation_app/models/evaluation_criterion.dart';

class EvaluationUtils {
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

  static Color getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.yellow[700]!;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String generateCommentsAndSuggestions(
    Map<String, int> ratings,
    List<EvaluationCriterion> masteryOfSubjectCriteria,
    List<EvaluationCriterion> instructionalSkillsCriteria,
    List<EvaluationCriterion> communicationSkillsCriteria,
    List<EvaluationCriterion> evaluationTechniquesCriteria,
    List<EvaluationCriterion> classroomManagementCriteria,
  ) {
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
    final int rounded = average.round();

    String overall;
    if (average >= 4.5) {
      overall =
          'Outstanding overall performance demonstrating exemplary teaching effectiveness and subject mastery.';
    } else if (average >= 3.5) {
      overall =
          'Very satisfactory performance with strong teaching practice and consistent delivery.';
    } else if (average >= 2.5) {
      overall =
          'Satisfactory performance meeting expectations, with opportunities for focused improvement.';
    } else if (average >= 1.5) {
      overall =
          'Fair performance; targeted support and development are recommended in key areas.';
    } else {
      overall =
          'Performance requires immediate attention; a structured improvement plan is advised.';
    }

    final List<String> strengths = [];
    final List<String> improvements = [];

    String nameFor(String id) {
      switch (id) {
        case 'logical_presentation':
          return 'logical lesson presentation';
        case 'relates_to_issues':
          return 'relating lessons to current issues';
        case 'beyond_content':
          return 'providing explanations beyond textbook content';
        case 'independent_teaching':
          return 'independent teaching';
        case 'motivation_techniques':
          return 'motivation techniques';
        case 'links_past_present':
          return 'linking past and present lessons';
        case 'varied_strategies':
          return 'using varied strategies';
        case 'varied_questions':
          return 'asking varied questions';
        case 'anticipates_difficulties':
          return 'anticipating student difficulties';
        case 'provides_reinforcement':
          return 'providing reinforcement';
        case 'multiple_sources':
          return 'using multiple sources';
        case 'encourages_speaking':
          return 'encouraging student expression';
        case 'integrates_values':
          return 'integrating values into lessons';
        case 'free_expression':
          return 'supporting free expression';
        case 'well_modulated_voice':
          return 'clear, well‑modulated voice';
        case 'appropriate_language':
          return 'appropriate language for the class';
        case 'correct_pronunciation':
          return 'correct pronunciation';
        case 'correct_grammar':
          return 'correct grammar';
        case 'listens_attentively':
          return 'active listening';
        case 'evaluates_achievement':
          return 'evaluating achievement based on the lesson';
        case 'appropriate_assessment':
          return 'appropriate assessment tools';
        case 'maintains_discipline':
          return 'maintaining discipline';
        case 'manages_time':
          return 'time management';
        case 'maximizes_resources':
          return 'maximizing resources';
        case 'good_rapport':
          return 'good rapport with students';
        case 'respects_limitations':
          return 'respecting individual limitations';
        default:
          return 'this area';
      }
    }

    void collect(List<EvaluationCriterion> list) {
      for (final c in list) {
        final int r = ratings[c.id] ?? 0;
        if (r >= 4) strengths.add(nameFor(c.id));
        if (r > 0 && r <= 2) improvements.add(nameFor(c.id));
      }
    }

    collect(masteryOfSubjectCriteria);
    collect(instructionalSkillsCriteria);
    collect(communicationSkillsCriteria);
    collect(evaluationTechniquesCriteria);
    collect(classroomManagementCriteria);

    final String strengthsLine = strengths.isEmpty
        ? ''
        : 'Strengths include: ${strengths.take(4).join(', ')}.';
    final String improvementsLine = improvements.isEmpty
        ? ''
        : 'Recommended focus areas: ${improvements.take(4).join(', ')}.';

    return [
      'Overall (${average.toStringAsFixed(2)}/5 → ${getRatingLabel(rounded)}): $overall',
      strengthsLine,
      improvementsLine,
    ].where((s) => s.isNotEmpty).join('\n\n');
  }
}
