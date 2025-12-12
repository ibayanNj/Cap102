// models/academic_period_model.dart
class AcademicPeriodModel {
  final String id;
  final String schoolYear;
  final String semester;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? createdAt;

  AcademicPeriodModel({
    required this.id,
    required this.schoolYear,
    required this.semester,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    this.createdAt,
  });

  factory AcademicPeriodModel.fromJson(Map<String, dynamic> json) {
    return AcademicPeriodModel(
      id: json['id'] ?? '',
      schoolYear: json['school_year'] ?? '',
      semester: json['semester'] ?? '',
      isActive: json['is_active'] ?? false,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'school_year': schoolYear,
      'semester': semester,
      'is_active': isActive,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}
