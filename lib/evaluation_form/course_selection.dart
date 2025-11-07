import 'package:flutter/material.dart';
import 'package:faculty_evaluation_app/models/course_model.dart'; // Adjust path if needed

class CourseSelectionDropdown extends StatelessWidget {
  const CourseSelectionDropdown({
    super.key,
    required this.coursesFuture,
    required this.selectedCourse,
    required this.onChanged,
  });

  final Future<List<Course>> coursesFuture;
  final Course? selectedCourse;
  final void Function(Course? newValue) onChanged;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: coursesFuture,
      builder: (context, snapshot) {
        // State 1: Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          // You can return a styled "Loading..." box
          return const Center(child: CircularProgressIndicator());
        }

        // State 2: Error
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          // Return a disabled field showing an error
          return TextFormField(
            enabled: false,
            decoration: InputDecoration(
              labelText: "Could not load courses",
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          );
        }

        // State 3: Success! Build the dropdown.
        final courses = snapshot.data!;

        return DropdownButtonFormField<Course>(
          // This is the style you requested
          decoration: InputDecoration(
            labelText: "Course(s) Taught/Topic",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
            ),
          ),
          value: selectedCourse,
          hint: const Text('Select a course'),
          isExpanded: true,
          onChanged: onChanged, // Pass the callback directly
          // This builds the list of items
          items: courses.map((Course course) {
            return DropdownMenuItem<Course>(
              value: course,
              child: Text(course.name),
            );
          }).toList(),
        );
      },
    );
  }
}
