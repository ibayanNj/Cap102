import 'package:faculty_evaluation_app/screens/dashboards/program_chair_dashboard.dart';
import 'package:flutter/material.dart';

class EvaluationSuccessPage extends StatelessWidget {
  final dynamic selectedFacultyMember;
  final double totalScore;
  final double averageScore;
  final int roundedAverage;
  final String Function(int) getRatingLabel;

  const EvaluationSuccessPage({
    super.key,
    required this.selectedFacultyMember,
    required this.totalScore,
    required this.averageScore,
    required this.roundedAverage,
    required this.getRatingLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluation Submitted'),
        backgroundColor: Colors.green[700],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24.0),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Evaluation Submitted Successfully!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),

                if (selectedFacultyMember != null) ...[
                  Text('Faculty: ${selectedFacultyMember.name}'),
                  Text('Subject: ${selectedFacultyMember.subjectTaught}'),
                  Text('Email: ${selectedFacultyMember.email}'),
                  const SizedBox(height: 8),
                ],

                Text('Total Score: ${totalScore.toStringAsFixed(1)}'),
                Text('Average Score: ${averageScore.toStringAsFixed(2)}'),
                Text('Overall Rating: ${getRatingLabel(roundedAverage)}'),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const SizedBox(width: 50, child: Text('Stars:')),
                    Row(
                      children: List.generate(5, (index) {
                        int starValue = index + 1;
                        bool isFilled = starValue <= roundedAverage;
                        return Icon(
                          isFilled ? Icons.star : Icons.star_border,
                          color: Colors.amber[600],
                          size: 24,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProgramChairDashboard(),
                        ),
                      );
                    },
                    child: const Text(
                      'Back to Dashboard',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
