// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:faculty_evaluation_app/services/print_services.dart';

// class SupabaseService {
//   final client = Supabase.instance.client;

//   // static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
//   //   try {
//   //     final customId = Supabase.instance.client.auth.currentUser;

//   //     if (customId == null) {
//   //       return null;
//   //     }

//   //     final response = await Supabase.instance.client
//   //         .from('users')
//   //         .select('custom_id')
//   //         .eq('custom_id', customId)
//   //         .single();

//   //     return response;
//   //   } catch (e) {
//   //     rethrow; // Important: rethrow so FutureBuilder can catch it
//   //   }
//   // }

//   static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
//     try {
//       final userId = Supabase.instance.client.auth.currentUser?.id;
//       if (userId == null) {
//         return null;
//       }

//       // final response = await Supabase.instance.client
//       //     .from('users') // Changed to 'users' table
//       //     .select(
//       //       'id, custom_id, full_name, role',
//       //     ) // Select your actual columns
//       //     .eq('id', userId)
//       //     .single();

//       final response = await Supabase.instance.client
//           .from('users')
//           .select('id, full_name, role')
//           .eq('id', userId)
//           .single();

//       // Debug print
//       return response;
//     } catch (e) {
//       return null;
//     }
//   }

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:faculty_evaluation_app/services/print_services.dart';

class SupabaseService {
  final client = Supabase.instance.client;

  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      // Get the current authenticated user
      final currentUser = Supabase.instance.client.auth.currentUser;
      final userId = currentUser?.id;

      print('🔐 Auth User: ${currentUser?.email}');
      print('🔍 Auth User ID: $userId');

      if (userId == null) {
        print('❌ No authenticated user found');
        return null;
      }

      // First, let's see ALL users in the table
      final allUsers = await Supabase.instance.client
          .from('users')
          .select('id, custom_id, full_name, role');

      print('📋 All users in table: $allUsers');

      // Try to get user by 'id' field
      print('🔎 Searching for user with id: $userId');

      final response = await Supabase.instance.client
          .from('users')
          .select('id, custom_id, full_name, role')
          .eq('id', userId)
          .maybeSingle(); // Use maybeSingle() instead of single()

      if (response == null) {
        print('⚠️ No user found with id=$userId');
        print('💡 Trying with custom_id instead...');

        // Try with custom_id as fallback
        final customIdResponse = await Supabase.instance.client
            .from('users')
            .select('id, custom_id, full_name, role')
            .eq('custom_id', userId)
            .maybeSingle();

        if (customIdResponse == null) {
          print('❌ No user found with custom_id=$userId either');
          return null;
        }

        print('✅ User found by custom_id: $customIdResponse');
        return customIdResponse;
      }

      print('✅ User profile found: $response');
      return response;
    } catch (e, stackTrace) {
      print('❌ Error getting user profile: $e');
      print('📚 Stack trace: $stackTrace');
      return null;
    }
  }

  Future<EvaluationData?> getEvaluationById(String evaluationId) async {
    try {
      final response = await client
          .from('evaluations')
          .select()
          .eq('id', evaluationId)
          .single();

      return EvaluationData(
        facultyName: response['faculty_name'] ?? '',
        courseTaught: response['observer_topic'] ?? '',
        dateTime: response['date_time'] ?? '',
        buildingRoom: response['building_room'] ?? '',
        semester: response['semester'] ?? '',
        schoolYear: response['school_year'] ?? '',
        masteryRatings: Map<String, int>.from(
          response['mastery_ratings'] ?? {},
        ),
        instructionalRatings: Map<String, int>.from(
          response['instructional_ratings'] ?? {},
        ),
        communicationRatings: Map<String, int>.from(
          response['communication_ratings'] ?? {},
        ),
        evaluationRatings: Map<String, int>.from(
          response['evaluation_ratings'] ?? {},
        ),
        managementRatings: Map<String, int>.from(
          response['management_ratings'] ?? {},
        ),
        comments: response['comments'] ?? '',
        evaluatorName: response['evaluator_name'] ?? '',
        evaluatorSignature: response['evaluator_signature'] ?? '',
        facultySignature: response['faculty_signature'] ?? '',
        date: response['date'] ?? '',
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<EvaluationData>> getAllEvaluations() async {
    try {
      final response = await client
          .from('evaluations')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((item) {
        return EvaluationData(
          facultyName: item['faculty_name'] ?? '',
          courseTaught: item['observer_topic'] ?? '',
          dateTime: item['date_time'] ?? '',
          buildingRoom: item['building_room'] ?? '',
          semester: item['semester'] ?? '',
          schoolYear: item['school_year'] ?? '',
          masteryRatings: Map<String, int>.from(item['mastery_ratings'] ?? {}),
          instructionalRatings: Map<String, int>.from(
            item['instructional_ratings'] ?? {},
          ),
          communicationRatings: Map<String, int>.from(
            item['communication_ratings'] ?? {},
          ),
          evaluationRatings: Map<String, int>.from(
            item['evaluation_ratings'] ?? {},
          ),
          managementRatings: Map<String, int>.from(
            item['management_ratings'] ?? {},
          ),
          comments: item['comments'] ?? '',
          evaluatorName: item['evaluator_name'] ?? '',
          evaluatorSignature: item['evaluator_signature'] ?? '',
          facultySignature: item['faculty_signature'] ?? '',
          date: item['date'] ?? '',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
