class EvaluationReport {
  final String id;
  final String facultyId;
  final String facultyName;
  final String courseName;
  final String semester;
  final String schoolYear;
  final double totalScore;
  final double weightedScore;
  final String? comments;
  final DateTime submittedAt;

  // Category scores
  final double masteryScore;
  final double instructionalScore;
  final double communicationScore;
  final double evaluationScore;
  final double classroomScore;

  EvaluationReport({
    required this.id,
    required this.facultyId,
    required this.facultyName,
    required this.courseName,
    required this.semester,
    required this.schoolYear,
    required this.totalScore,
    required this.weightedScore,
    this.comments,
    required this.submittedAt,
    required this.masteryScore,
    required this.instructionalScore,
    required this.communicationScore,
    required this.evaluationScore,
    required this.classroomScore,
  });

  factory EvaluationReport.fromJson(Map<String, dynamic> json) {
    return EvaluationReport(
      id: json['id'] ?? '',
      facultyId: json['faculty_id'] ?? '',
      facultyName: json['faculty_name'] ?? 'Unknown Faculty',
      courseName: json['course_name'] ?? 'Unknown Course',
      semester: json['semester'] ?? '',
      schoolYear: json['school_year'] ?? '',
      totalScore: (json['total_score'] ?? 0).toDouble(),
      weightedScore: (json['weighted_score'] ?? 0).toDouble(),
      comments: json['comments'],
      submittedAt: DateTime.parse(json['submitted_at']),
      masteryScore: (json['mastery_score'] ?? 0).toDouble(),
      instructionalScore: (json['instructional_score'] ?? 0).toDouble(),
      communicationScore: (json['communication_score'] ?? 0).toDouble(),
      evaluationScore: (json['evaluation_score'] ?? 0).toDouble(),
      classroomScore: (json['classroom_score'] ?? 0).toDouble(),
    );
  }

  String getRatingLabel() {
    int rounded = weightedScore.round();
    switch (rounded) {
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
}
