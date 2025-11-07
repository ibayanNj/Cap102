import 'package:flutter/material.dart';
import 'package:faculty_evaluation_app/models/evaluation_criterion.dart';
import 'package:faculty_evaluation_app/utils/criterion_row.dart';
import 'package:faculty_evaluation_app/utils/category_score.dart';
import 'package:faculty_evaluation_app/utils/score_calculator.dart';

class EvaluationSectionCard extends StatelessWidget {
  final String sectionTitle;
  final List<EvaluationCriterion> criteria;
  final Map<String, int> ratings;
  final Function(String, int) onRatingChanged;
  final double weightPercentage;

  const EvaluationSectionCard({
    super.key,
    required this.sectionTitle,
    required this.criteria,
    required this.ratings,
    required this.onRatingChanged,
    required this.weightPercentage,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate scores for this category using ScoreCalculator
    List<int> individualRatings = ScoreCalculator.getCategoryRatings(
      criteria,
      ratings,
    );

    double rawScore = ScoreCalculator.calculateCategoryRawScore(
      criteria,
      ratings,
    );

    double meanScore = ScoreCalculator.calculateCategoryMean(criteria, ratings);

    double weightedMean = ScoreCalculator.calculateCategoryWeightedMean(
      criteria,
      ratings,
      weightPercentage,
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 32, 42, 68),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sectionTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ...criteria.map(
              (criterion) => CriterionRow(
                criterion: criterion,
                currentRating: ratings[criterion.id] ?? 0,
                onRatingChanged: (rating) {
                  onRatingChanged(criterion.id, rating);
                },
              ),
            ),
            if (individualRatings.isNotEmpty)
              CategoryScoreCard(
                categoryTitle: sectionTitle.split('(')[0].trim(),
                rawScore: rawScore,
                meanScore: meanScore,
                weightedMean: weightedMean,
                individualRatings: individualRatings,
                weightPercentage: weightPercentage,
              ),
          ],
        ),
      ),
    );
  }
}
