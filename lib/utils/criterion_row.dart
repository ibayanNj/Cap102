import 'package:flutter/material.dart';
import 'package:faculty_evaluation_app/models/evaluation_criterion.dart';

class CriterionRow extends StatelessWidget {
  final EvaluationCriterion criterion;
  final int currentRating;
  final Function(int) onRatingChanged;

  const CriterionRow({
    super.key,
    required this.criterion,
    required this.currentRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            criterion.text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 60),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    int starValue = index + 1;
                    bool isFilled = starValue <= currentRating;

                    return GestureDetector(
                      onTap: () => onRatingChanged(starValue),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          isFilled ? Icons.star : Icons.star_border,
                          color: isFilled
                              ? Colors.amber[600]
                              : Colors.grey[400],
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
