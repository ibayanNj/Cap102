import 'package:flutter/material.dart';
import 'package:faculty_evaluation_app/models/evaluation_criterion.dart';

class DesignConstants {
  static const Color primaryColor = Color(0xFF203A44);
  static const Color accentBlue = Color.fromARGB(255, 33, 150, 243);

  static const double borderRadius = 14.0;
  static const double cardBorderRadius = 20.0;
  static const double iconSize = 24.0;
  static const double padding = 16.0;
  static const double cardPadding = 24.0;

  static const EdgeInsets symmetricPadding = EdgeInsets.symmetric(
    vertical: 12,
    horizontal: 16,
  );

  static BoxDecoration cardDecoration({
    Color? gradientStart,
    Color? gradientEnd,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          gradientStart ?? Colors.white,
          gradientEnd ?? Colors.grey.shade50,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(cardBorderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static InputDecoration buildInputDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null
          ? Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primaryColor),
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// services/evaluation_calculator.dart
class EvaluationCalculator {
  static const Map<String, double> categoryWeights = {
    'mastery': 0.25,
    'instructional': 0.25,
    'communication': 0.20,
    'evaluation': 0.15,
    'classroom': 0.15,
  };

  static double calculateCategoryScore(
    List<EvaluationCriterion> criteria,
    Map<String, int> ratings,
  ) {
    double sum = 0;
    for (var criterion in criteria) {
      sum += ratings[criterion.id] ?? 0;
    }
    return sum;
  }

  static double calculateCategoryMean(double rawScore, int criteriaCount) {
    return criteriaCount > 0 ? rawScore / criteriaCount : 0;
  }

  static Map<String, double> calculateAllScores(
    Map<String, List<EvaluationCriterion>> categories,
    Map<String, int> ratings,
  ) {
    final scores = <String, double>{};
    double totalRaw = 0;
    double totalWeighted = 0;
    int totalCriteria = 0;

    categories.forEach((key, criteria) {
      final raw = calculateCategoryScore(criteria, ratings);
      final mean = calculateCategoryMean(raw, criteria.length);
      final weighted = mean * (categoryWeights[key] ?? 0);

      scores['${key}Raw'] = raw;
      scores['${key}Mean'] = mean;
      scores['${key}Weighted'] = weighted;

      totalRaw += raw;
      totalWeighted += weighted;
      totalCriteria += criteria.length;
    });

    scores['totalRaw'] = totalRaw;
    scores['totalWeighted'] = totalWeighted;
    scores['totalCriteria'] = totalCriteria.toDouble();
    scores['totalMean'] = totalCriteria > 0 ? totalRaw / totalCriteria : 0;

    return scores;
  }

  static String getRatingLabel(int rating) {
    const labels = {
      5: 'Outstanding',
      4: 'Very Satisfactory',
      3: 'Satisfactory',
      2: 'Fair',
      1: 'Poor',
    };
    return labels[rating] ?? 'Not rated';
  }

  static Color getRatingColor(int rating) {
    const colors = {
      5: Colors.green,
      4: Colors.lightGreen,
      3: Colors.amber,
      2: Colors.orange,
      1: Colors.red,
    };
    return colors[rating] ?? Colors.grey;
  }
}

// widgets/reusable_card.dart
class ReusableCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBackgroundColor;
  final Widget child;
  final EdgeInsets padding;
  final Color? gradientStart;
  final Color? gradientEnd;
  final Border? border;

  const ReusableCard({
    required this.title,
    required this.icon,
    required this.child,
    this.iconBackgroundColor = DesignConstants.primaryColor,
    this.padding = const EdgeInsets.all(DesignConstants.cardPadding),
    this.gradientStart,
    this.gradientEnd,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: DesignConstants.symmetricPadding,
      decoration: DesignConstants.cardDecoration(
        gradientStart: gradientStart,
        gradientEnd: gradientEnd,
      ).copyWith(border: border),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconBackgroundColor,
                    size: DesignConstants.iconSize,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: DesignConstants.primaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

// widgets/rating_scale_item.dart
class RatingScaleItem extends StatelessWidget {
  final int stars;
  final String label;
  final String range;
  final Color color;

  const RatingScaleItem({
    required this.stars,
    required this.label,
    required this.range,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            '$stars -',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < stars ? Icons.star_rounded : Icons.star_border_rounded,
                color: Colors.amber[600],
                size: 12,
              );
            }),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label ($range)',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// widgets/criterion_rating_row.dart
class CriterionRatingRow extends StatelessWidget {
  final EvaluationCriterion criterion;
  final int currentRating;
  final ValueChanged<int> onRatingChanged;

  const CriterionRatingRow({
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
                    color: isFilled ? Colors.amber[600] : Colors.grey[400],
                    size: 32,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
