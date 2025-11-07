import 'package:flutter/material.dart';
import 'package:faculty_evaluation_app/presentation/analytics_dashboard.dart';
import 'package:google_fonts/google_fonts.dart';

class ChairDashboardPage extends StatelessWidget {
  const ChairDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Optional welcome header
            Padding(
              padding: EdgeInsets.all(25),
              child: Text(
                'Welcome back, Chairperson!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Analytics content previously on a separate tab
            DataAnalyticsView(),
          ],
        ),
      ),
    );
  }
}
