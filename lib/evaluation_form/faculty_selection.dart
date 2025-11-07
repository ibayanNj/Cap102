import 'package:flutter/material.dart';
import '../models/faculty_models.dart';

class FacultySelectionCard extends StatefulWidget {
  final Future<List<FacultyMember>> facultyFuture;
  final FacultyMember? selectedFacultyMember;
  final ValueChanged<FacultyMember?> onFacultyChanged;

  const FacultySelectionCard({
    super.key,
    required this.facultyFuture,
    required this.selectedFacultyMember,
    required this.onFacultyChanged,
  });

  @override
  State<FacultySelectionCard> createState() => _FacultySelectionCardState();
}

class _FacultySelectionCardState extends State<FacultySelectionCard> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FacultyMember>>(
      future: widget.facultyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        if (snapshot.hasError) {
          return Card(
            color: Colors.red.shade50,
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Error loading faculty: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
            ),
          );
        }

        final facultyMembers = snapshot.data ?? [];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 1.5,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Faculty',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<FacultyMember>(
                  value: widget.selectedFacultyMember,
                  decoration: InputDecoration(
                    labelText: 'Please select faculty to evaluate',
                    labelStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  dropdownColor: Colors.white,
                  items: facultyMembers.map((faculty) {
                    return DropdownMenuItem(
                      value: faculty,
                      child: Text(
                        faculty.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: widget.onFacultyChanged,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
