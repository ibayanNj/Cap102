class FacultyMember {
  final String id;
  final String name;

  FacultyMember({required this.id, required this.name});

  factory FacultyMember.fromJson(Map<String, dynamic> json) {
    return FacultyMember(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  String toString() => name;
}
