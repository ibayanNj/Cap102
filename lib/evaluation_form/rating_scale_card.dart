import 'package:flutter/material.dart';

class RatingScaleCard extends StatelessWidget {
  const RatingScaleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star_outline, color: Colors.amber[600]),
                const SizedBox(width: 8),
                const Text(
                  'Rating Scale',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRatingScaleItem(5, 'Outstanding', '4.51 - 5.0', Colors.green),
            _buildRatingScaleItem(
              4,
              'Very Satisfactory',
              '3.51 - 4.50',
              Colors.lightGreen,
            ),
            _buildRatingScaleItem(
              3,
              'Satisfactory',
              '2.51 - 3.50',
              Colors.yellow[700]!,
            ),
            _buildRatingScaleItem(2, 'Fair', '1.51 - 2.50', Colors.orange),
            _buildRatingScaleItem(1, 'Poor', '1.0 - 1.50', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingScaleItem(
    int stars,
    String label,
    String range,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$stars -',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < stars ? Icons.star : Icons.star_border,
                color: Colors.amber[600],
                size: 16,
              );
            }),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label ($range)',
              style: TextStyle(fontWeight: FontWeight.w500, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
