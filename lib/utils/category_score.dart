import 'package:flutter/material.dart';

class CategoryScoreCard extends StatelessWidget {
  final String categoryTitle;
  final double rawScore;
  final double meanScore;
  final double weightedMean;
  final List<int> individualRatings;
  final double weightPercentage;

  const CategoryScoreCard({
    super.key,
    required this.categoryTitle,
    required this.rawScore,
    required this.meanScore,
    required this.weightedMean,
    required this.individualRatings,
    required this.weightPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Total/Mean/Wtd.Mean: ',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              Text(
                rawScore > 0
                    ? '${rawScore.toStringAsFixed(0)} / '
                          '${meanScore.toStringAsFixed(2)} / '
                          '${weightedMean.toStringAsFixed(4)}'
                    : 'Not rated',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
