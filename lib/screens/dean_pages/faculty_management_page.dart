import 'package:flutter/material.dart';

class DeanFacultyManagementPage extends StatelessWidget {
  const DeanFacultyManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildFacultyListItem(
                      'Dr. Jane Doe',
                      'Computer Science',
                      'jane.doe@university.edu',
                    ),
                    _buildFacultyListItem(
                      'Prof. Mike Johnson',
                      'Mathematics',
                      'mike.johnson@university.edu',
                    ),
                    _buildFacultyListItem(
                      'Dr. Sarah Wilson',
                      'Physics',
                      'sarah.wilson@university.edu',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyListItem(String name, String department, String email) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(name),
        subtitle: Text('$department • $email'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
