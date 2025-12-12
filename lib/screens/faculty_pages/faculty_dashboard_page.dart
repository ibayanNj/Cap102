import 'package:flutter/material.dart';

class FacultyDashboardPage extends StatelessWidget {
  const FacultyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back, Professor!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Courses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildCourseCard(
              context,
              courseId: 'CC2109',
              courseName: 'Intro to Computing',
              schedule: 'MWF 9:00 AM - 10:30 AM',
              status: 'Evaluated',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildCourseCard(
              context,
              courseId: 'CS3201',
              courseName: 'Data Structures and Algorithms',
              schedule: 'TTh 1:00 PM - 2:30 PM',
              status: 'Evaluated',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildCourseCard(
              context,
              courseId: 'CS4102',
              courseName: 'Database Management Systems',
              schedule: 'MWF 2:00 PM - 3:30 PM',
              status: 'Evaluated',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildCourseCard(
              context,
              courseId: 'CS3305',
              courseName: 'Web Development',
              status: 'Evaluated',
              schedule: 'TTh 10:00 AM - 11:30 AM',
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildCourseCard(
              context,
              courseId: 'CS4208',
              courseName: 'Software Engineering',
              status: 'Evaluated',
              schedule: 'MWF 11:00 AM - 12:30 PM',
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context, {
    required String courseId,
    required String courseName,
    required String schedule,
    required String status,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to course details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseId,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      courseName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 16),
                        Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            schedule,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
