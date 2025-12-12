// import 'package:faculty_evaluation_app/screens/dashboards/program_chair_dashboard.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faculty Evaluation System',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 32, 42, 68),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 32, 42, 68),
        ),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      // home: ProgramChairDashboard(),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// import 'package:flutter/material.dart';
// import 'screens/login_screen.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     const primaryColor = Color(0xFF202A44);

//     return MaterialApp(
//       title: 'Faculty Evaluation System',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
//         primaryColor: primaryColor,
//         fontFamily: 'Poppins',
//         useMaterial3: true,
//       ),
//       home: const LoginScreen(),
//     );
//   }
// }
