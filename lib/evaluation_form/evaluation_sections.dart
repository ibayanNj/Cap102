import 'package:flutter/material.dart';
import 'package:faculty_evaluation_app/models/evaluation_criterion.dart';
import 'package:faculty_evaluation_app/controllers/evaluation_controller.dart';

class EvaluationSections extends StatelessWidget {
  final EvaluationController controller;
  final List<EvaluationCriterion> mastery;
  final List<EvaluationCriterion> instructional;
  final List<EvaluationCriterion> communication;
  final List<EvaluationCriterion> evaluation;
  final List<EvaluationCriterion> classroom;

  const EvaluationSections({
    super.key,
    required this.controller,
    required this.mastery,
    required this.instructional,
    required this.communication,
    required this.evaluation,
    required this.classroom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildEvaluationSectionCard(
          'A. Mastery of Subject - Matter (30%)',
          mastery,
        ),
        _buildEvaluationSectionCard(
          'B. Instructional Skills (25%)',
          instructional,
        ),
        _buildEvaluationSectionCard(
          'C. Communication Skills (20%)',
          communication,
        ),
        _buildEvaluationSectionCard(
          'D. Evaluation Techniques (15%)',
          evaluation,
        ),
        _buildEvaluationSectionCard(
          'E. Classroom Management Skills (10%)',
          classroom,
        ),
      ],
    );
  }

  Widget _buildEvaluationSectionCard(
    String title,
    List<EvaluationCriterion> criteria,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final criterion in criteria)
              ListTile(
                title: Text(criterion.text),
                trailing: DropdownButton<int>(
                  value: controller.ratings[criterion.id] ?? 0,
                  hint: const Text('Rate'),
                  items: List.generate(5, (i) => i + 1)
                      .map(
                        (rating) => DropdownMenuItem(
                          value: rating,
                          child: Text('$rating'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.setRating(criterion.id, value);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
