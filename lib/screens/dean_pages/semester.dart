import 'package:flutter/material.dart';

class ResponsiveSemesterSelector extends StatefulWidget {
  const ResponsiveSemesterSelector({super.key});

  @override
  State<ResponsiveSemesterSelector> createState() =>
      _ResponsiveSemesterSelectorState();
}

class _ResponsiveSemesterSelectorState
    extends State<ResponsiveSemesterSelector> {
  final Map<String, bool> _selectedSemesters = {
    'Fall 2024': true,
    'Spring 2024': true,
    'Fall 2023': true,
  };

  final Map<String, Color> _semesterColors = {
    'Fall 2024': Colors.blue,
    'Spring 2024': Colors.green,
    'Fall 2023': Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          // Make the card larger and more visible
          width: screenWidth * 0.95, // occupy 95% of screen width
          height: 220, // fixed height for a more substantial card
          child: Card(
            elevation: 5,
            shadowColor: Colors.black45,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isNarrow = constraints.maxWidth < 600;

                  final List<Widget> semesterChips = _selectedSemesters.keys
                      .map((semester) {
                        final isSelected = _selectedSemesters[semester]!;
                        return _buildSemesterChip(
                          semester,
                          isSelected,
                          _semesterColors[semester]!,
                        );
                      })
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Semester Comparison',
                        style: TextStyle(
                          fontSize: 20, // slightly larger
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: isNarrow
                            ? ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: semesterChips.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) =>
                                    semesterChips[index],
                              )
                            : Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: semesterChips,
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterChip(String semester, bool isSelected, Color color) {
    return FilterChip(
      label: Text(semester, style: const TextStyle(fontSize: 15)),
      selected: isSelected,
      backgroundColor: Colors.grey[200],
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      onSelected: (selected) {
        setState(() {
          _selectedSemesters[semester] = selected;
        });
      },
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
