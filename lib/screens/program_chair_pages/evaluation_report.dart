import 'package:flutter/material.dart';
import 'package:faculty_evaluation_app/models/faculty_models.dart';
import 'package:faculty_evaluation_app/utils/evaluation_utils.dart';

class EvaluationReportView extends StatelessWidget {
  final FacultyMember facultyMember;
  final Map<String, int> ratings;
  final double totalScore;
  final double averageScore;
  final String comments;
  final DateTime evaluationDate;
  final String semester;
  final String schoolYear;
  final String courseTaught;
  final String room;

  const EvaluationReportView({
    super.key,
    required this.facultyMember,
    required this.ratings,
    required this.totalScore,
    required this.averageScore,
    required this.comments,
    required this.evaluationDate,
    required this.semester,
    required this.schoolYear,
    required this.courseTaught,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluation Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _handlePrint(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _handleShare(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFacultyInfoCard(),
            const SizedBox(height: 16),
            _buildScoresCard(),
            const SizedBox(height: 16),
            _buildCommentsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Faculty Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', facultyMember.name),
            // _buildInfoRow('Subject', facultyMember.subjectTaught),
            // _buildInfoRow('Email', facultyMember.email),
            _buildInfoRow('Semester', semester),
            _buildInfoRow('School Year', schoolYear),
            _buildInfoRow('Course', courseTaught),
            _buildInfoRow('Room', room),
            _buildInfoRow(
              'Evaluation Date',
              '${evaluationDate.day}/${evaluationDate.month}/${evaluationDate.year}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoresCard() {
    final roundedAverage = averageScore.round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evaluation Scores',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Total Score', totalScore.toStringAsFixed(1)),
            _buildInfoRow('Average Score', averageScore.toStringAsFixed(2)),
            _buildInfoRow(
              'Rating',
              EvaluationUtils.getRatingLabel(roundedAverage),
            ),
            const SizedBox(height: 8),
            _buildStarRating(roundedAverage),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comments & Suggestions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 12),
            Text(comments, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      children: [
        const SizedBox(
          width: 120,
          child: Text(
            'Rating',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
          ),
        ),
        ...List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber[600],
            size: 24,
          );
        }),
      ],
    );
  }

  Future<void> _handlePrint(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Printing feature coming soon')),
    );
  }

  Future<void> _handleShare(BuildContext context) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Share feature coming soon')));
  }
}
