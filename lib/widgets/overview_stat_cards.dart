import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OverviewStatCards extends StatefulWidget {
  const OverviewStatCards({super.key});

  @override
  State<OverviewStatCards> createState() => _OverviewStatCardsState();
}

class _OverviewStatCardsState extends State<OverviewStatCards> {
  late Future<int> _facultyCountFuture;

  @override
  void initState() {
    super.initState();
    _facultyCountFuture = _getFacultyCount();
  }

  /// ✅ Works for Supabase Flutter v2+
  Future<int> _getFacultyCount() async {
    final supabase = Supabase.instance.client;

    try {
      // Returns a List<dynamic> directly
      final List<dynamic> data = await supabase.from('faculty').select('id');

      // Use the length of the returned list as the count
      return data.length;
    } catch (e) {
      debugPrint('Error fetching faculty count: $e');
      return 0;
    }
  }

  /// 🔹 Reusable Stat Card Widget
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    // Use a Container with a border instead of a Card with elevation
    return Container(
      margin: const EdgeInsets.all(8), // Keep the margin
      padding: const EdgeInsets.all(16), // Add padding
      decoration: BoxDecoration(
        // A simple border instead of shadow
        border: Border.all(color: Colors.grey.shade300, width: 1),
        // Softer rounded corners
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Simplified icon: no background circle
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          // Use Expanded to prevent text overflow issues
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    // Value is still prominent
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// 🧩 Faculty Count Card (Dynamic)
        Expanded(
          child: FutureBuilder<int>(
            future: _facultyCountFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildStatCard(
                  'Faculty Count',
                  'Loading...',
                  Icons.people,
                  Colors.black,
                );
              } else if (snapshot.hasError) {
                return _buildStatCard(
                  'Faculty Count',
                  'Error',
                  Icons.people,
                  Colors.red,
                );
              } else {
                final count = snapshot.data ?? 0;
                return _buildStatCard(
                  'Faculty Count',
                  count.toString(),
                  Icons.people,
                  Colors.black,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
