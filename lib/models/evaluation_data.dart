class EvaluationData {
  final String facultyName;
  final String courseTaught;
  final String dateTime;
  final String buildingRoom;
  final String semester;
  final String schoolYear;

  final Map<String, int> masteryRatings;
  final Map<String, int> instructionalRatings;
  final Map<String, int> communicationRatings;
  final Map<String, int> evaluationRatings;
  final Map<String, int> managementRatings;

  final String comments;
  final String evaluatorName;
  final String evaluatorSignature;
  final String facultySignature;
  final String date;

  EvaluationData({
    required this.facultyName,
    required this.courseTaught,
    required this.dateTime,
    required this.buildingRoom,
    required this.semester,
    required this.schoolYear,
    required this.masteryRatings,
    required this.instructionalRatings,
    required this.communicationRatings,
    required this.evaluationRatings,
    required this.managementRatings,
    required this.comments,
    required this.evaluatorName,
    required this.evaluatorSignature,
    required this.facultySignature,
    required this.date,
  });

  // Convert from JSON
  factory EvaluationData.fromJson(Map<String, dynamic> json) {
    return EvaluationData(
      facultyName: json['facultyName'] ?? '',
      courseTaught: json['courseTaught'] ?? '',
      dateTime: json['dateTime'] ?? '',
      buildingRoom: json['buildingRoom'] ?? '',
      semester: json['semester'] ?? '',
      schoolYear: json['schoolYear'] ?? '',
      masteryRatings: Map<String, int>.from(json['masteryRatings'] ?? {}),
      instructionalRatings: Map<String, int>.from(
        json['instructionalRatings'] ?? {},
      ),
      communicationRatings: Map<String, int>.from(
        json['communicationRatings'] ?? {},
      ),
      evaluationRatings: Map<String, int>.from(json['evaluationRatings'] ?? {}),
      managementRatings: Map<String, int>.from(json['managementRatings'] ?? {}),
      comments: json['comments'] ?? '',
      evaluatorName: json['evaluatorName'] ?? '',
      evaluatorSignature: json['evaluatorSignature'] ?? '',
      facultySignature: json['facultySignature'] ?? '',
      date: json['date'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'facultyName': facultyName,
      'courseTaught': courseTaught,
      'dateTime': dateTime,
      'buildingRoom': buildingRoom,
      'semester': semester,
      'schoolYear': schoolYear,
      'masteryRatings': masteryRatings,
      'instructionalRatings': instructionalRatings,
      'communicationRatings': communicationRatings,
      'evaluationRatings': evaluationRatings,
      'managementRatings': managementRatings,
      'comments': comments,
      'evaluatorName': evaluatorName,
      'evaluatorSignature': evaluatorSignature,
      'facultySignature': facultySignature,
      'date': date,
    };
  }
}
