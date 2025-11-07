import '../models/evaluation_criterion.dart';

class EvaluationCriteria {
  static const List<EvaluationCriterion> masteryOfSubjectCriteria = [
    EvaluationCriterion(
      id: 'logical_presentation',
      text: '1. Presents lesson logically',
    ),
    EvaluationCriterion(
      id: 'relates_to_issues',
      text: '2. Relates lesson to local/national issues',
    ),
    EvaluationCriterion(
      id: 'beyond_content',
      text: '3. Provides explanation beyond the content of the book',
    ),
    EvaluationCriterion(
      id: 'independent_teaching',
      text: '4. Teaches independent of notes',
    ),
  ];

  static const List<EvaluationCriterion> instructionalSkillsCriteria = [
    EvaluationCriterion(
      id: 'motivation_techniques',
      text: '1. Uses motivation techniques that elicit student\'s interest',
    ),
    EvaluationCriterion(
      id: 'links_past_present',
      text: '2. Links the past with the present lesson',
    ),
    EvaluationCriterion(
      id: 'varied_strategies',
      text: '3. Use varied strategies suited to the student\'s needs',
    ),
    EvaluationCriterion(
      id: 'varied_questions',
      text: '4. Asks varied types of questions',
    ),
    EvaluationCriterion(
      id: 'anticipates_difficulties',
      text: '5. Anticipates difficulties of students',
    ),
    EvaluationCriterion(
      id: 'provides_reinforcement',
      text: '6. Provides appropriate reinforcement to student\'s responses',
    ),
    EvaluationCriterion(
      id: 'multiple_sources',
      text: '7. Utilizes multiple source of information',
    ),
    EvaluationCriterion(
      id: 'encourages_speaking',
      text: '8. Encourages students to speak and write',
    ),
    EvaluationCriterion(
      id: 'integrates_values',
      text: '9. Integrates values in the lesson',
    ),
    EvaluationCriterion(
      id: 'free_expression',
      text: '10. Provides opportunities for free expression of ideas',
    ),
  ];
  static const List<EvaluationCriterion> communicationSkillsCriteria = [
    EvaluationCriterion(
      id: 'well_modulated_voice',
      text: '1. Speaks in a well-modulated voice',
    ),
    EvaluationCriterion(
      id: 'appropriate_language',
      text: '2. Uses language appropriate to the level of the class',
    ),
    EvaluationCriterion(
      id: 'correct_pronunciation',
      text: '3. Pronounces words correctly',
    ),
    EvaluationCriterion(
      id: 'correct_grammar',
      text: '4. Observes correct grammar in both speaking and writing',
    ),
    EvaluationCriterion(
      id: 'encourages_communication',
      text: '5. Encourages students to speak and write',
    ),
    EvaluationCriterion(
      id: 'listens_attentively',
      text: '6. Listens attentively to student\'s response',
    ),
  ];

  static const List<EvaluationCriterion> evaluationTechniquesCriteria = [
    EvaluationCriterion(
      id: 'evaluates_achievement',
      text: '1. Evaluates student\'s achievement based in the day\'s lesson',
    ),
    EvaluationCriterion(
      id: 'appropriate_assessment',
      text: '2. Utilizes appropriate assessment tools and techniques',
    ),
  ];

  static const List<EvaluationCriterion> classroomManagementCriteria = [
    EvaluationCriterion(
      id: 'maintains_discipline',
      text: '1. Maintains discipline (e.g. Keeps student\'s task)',
    ),
    EvaluationCriterion(
      id: 'manages_time',
      text: '2. Manages time profitably through curriculum-related activities',
    ),
    EvaluationCriterion(
      id: 'maximizes_resources',
      text: '3. Maximizes use of resources',
    ),
    EvaluationCriterion(
      id: 'good_rapport',
      text: '4. Maintains good rapport with the students',
    ),
    EvaluationCriterion(
      id: 'respects_limitations',
      text: '5. Shows respect for individual student\'s limitation',
    ),
  ];

  static List<EvaluationCriterion> getAllCriteria() {
    return [
      ...masteryOfSubjectCriteria,
      ...instructionalSkillsCriteria,
      ...communicationSkillsCriteria,
      ...evaluationTechniquesCriteria,
      ...classroomManagementCriteria,
    ];
  }
}
