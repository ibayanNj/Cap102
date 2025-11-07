import 'package:flutter/material.dart';

class OverallScoreCard extends StatelessWidget {
  final double totalWeightedScore;
  final double totalMeanScore;

  const OverallScoreCard({
    super.key,
    required this.totalWeightedScore,
    required this.totalMeanScore,
  });

  String _getRatingLabel(int rating) {
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
        return 'Not Rated';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return Colors.green.shade700;
      case 4:
        return Colors.blue.shade700;
      case 3:
        return Colors.orange.shade700;
      case 2:
        return Colors.orange.shade900;
      case 1:
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    int roundedAverage = totalMeanScore.round();
    return Center(
      child: Card(
        // You can add margin if you want space around the Card
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        elevation: 3,
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (totalWeightedScore > 0) ...[
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Overall MEAN/Desc. Equiv.:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        // This allows the text to wrap to a new line
                        // if the screen is extremely narrow
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      // ... your first container for the score
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.green.shade300,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        totalWeightedScore.toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      // ... your second container for the label
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getRatingColor(roundedAverage),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _getRatingColor(roundedAverage),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        _getRatingLabel(roundedAverage),
                        style: TextStyle(
                          color:
                              Colors.white, // Text color looks better as white
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else
                const Text(
                  'Please complete the evaluation to see your overall score.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
