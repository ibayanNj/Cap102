import 'package:flutter/material.dart';

class FacultySelectionCard extends StatefulWidget {
  const FacultySelectionCard({super.key});

  @override
  State<FacultySelectionCard> createState() => _FacultySelectionCardState();
}

class _FacultySelectionCardState extends State<FacultySelectionCard> {
  String? selectedSemester;
  String? selectedFacultyMember;
  late TextEditingController schoolYearController;
  late TextEditingController courseController;
  late TextEditingController roomController;
  late TextEditingController dateTimeController;

  final List<String> semesters = const ['1st Semester', '2nd Semester'];
  final List<FacultyMember> availableFacultyMembers = const [
    FacultyMember(name: 'Dr. John Smith', subjectTaught: 'Mathematics'),
    FacultyMember(name: 'Dr. Sarah Johnson', subjectTaught: 'Physics'),
    FacultyMember(name: 'Prof. Emily Davis', subjectTaught: 'Literature'),
  ];

  @override
  void initState() {
    super.initState();
    schoolYearController = TextEditingController();
    courseController = TextEditingController();
    roomController = TextEditingController();
    dateTimeController = TextEditingController();
  }

  @override
  void dispose() {
    schoolYearController.dispose();
    courseController.dispose();
    roomController.dispose();
    dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                icon: Icons.edit_calendar_rounded,
                title: 'Faculty Evaluation Details',
              ),
              const SizedBox(height: 24),
              _buildEvaluationDetails(),
              const SizedBox(height: 32),
              _buildFacultySelectionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF203A44).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF203A44), size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF203A44),
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEvaluationDetails() {
    return Column(
      children: [
        _buildDropdownField(
          label: 'Semester',
          value: selectedSemester,
          items: semesters,
          onChanged: (val) => setState(() => selectedSemester = val),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: schoolYearController,
          label: 'School Year',
          hint: '2025–2026',
          icon: Icons.calendar_month_rounded,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: courseController,
          label: 'Course Taught',
          hint: 'e.g., Advanced Mathematics',
          icon: Icons.book_rounded,
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        _buildTextField(
          controller: roomController,
          label: 'Building & Room',
          hint: 'e.g., Building A, Room 101',
          icon: Icons.location_on_rounded,
        ),
      ],
    );
  }

  Widget _buildFacultySelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.person_search_rounded,
          title: 'Select Faculty to Evaluate',
        ),
        const SizedBox(height: 16),
        _buildFacultyDropdown(),
        const SizedBox(height: 16),
        if (selectedFacultyMember != null) _buildSelectedFacultyCard(),
      ],
    );
  }

  Widget _buildFacultyDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedFacultyMember,
      decoration: InputDecoration(
        labelText: 'Faculty Member',
        hintText: 'Select a faculty member',
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF203A44).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.person_rounded, color: Color(0xFF203A44)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF203A44), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: availableFacultyMembers.map((member) {
        return DropdownMenuItem<String>(
          value: member.name,
          child: _buildDropdownItem(member),
        );
      }).toList(),
      onChanged: (value) => setState(() => selectedFacultyMember = value),
      isExpanded: true,
    );
  }

  Widget _buildDropdownItem(FacultyMember member) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF203A44),
                const Color(0xFF203A44).withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Text(
              member.subjectTaught,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedFacultyCard() {
    final member = availableFacultyMembers.firstWhere(
      (m) => m.name == selectedFacultyMember,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Faculty',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${member.name} • ${member.subjectTaught}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF203A44),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF203A44), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null
            ? Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF203A44).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF203A44)),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF203A44), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

class FacultyMember {
  final String name;
  final String subjectTaught;

  const FacultyMember({required this.name, required this.subjectTaught});
}
