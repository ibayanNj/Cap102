// lib/evaluation_form/widgets/comments_card.dart
// import 'package:flutter/material.dart';
// import 'package:faculty_evaluation_app/utils/comments_generator.dart';
// import 'package:faculty_evaluation_app/models/evaluation_criterion.dart';

// class CommentsCard extends StatelessWidget {
//   final TextEditingController commentsController;
//   final Map<String, int> ratings;
//   final List<EvaluationCriterion> mastery;
//   final List<EvaluationCriterion> instructional;
//   final List<EvaluationCriterion> communication;
//   final List<EvaluationCriterion> evaluation;
//   final List<EvaluationCriterion> classroom;

//   const CommentsCard({
//     super.key,
//     required this.commentsController,
//     required this.ratings,
//     required this.mastery,
//     required this.instructional,
//     required this.communication,
//     required this.evaluation,
//     required this.classroom,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Comments & Suggestions',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 TextButton.icon(
//                   onPressed: () {
//                     final text = CommentsGenerator.generateComments(
//                       masteryOfSubjectCriteria: mastery,
//                       instructionalSkillsCriteria: instructional,
//                       communicationSkillsCriteria: communication,
//                       evaluationTechniquesCriteria: evaluation,
//                       classroomManagementCriteria: classroom,
//                       ratings: ratings,
//                     );
//                     commentsController.text = text;
//                   },
//                   icon: const Icon(Icons.auto_awesome),
//                   label: const Text('Generate'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: commentsController,
//               maxLines: null,
//               minLines: 4,
//               decoration: const InputDecoration(
//                 hintText: 'Write comments and actionable suggestions...',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:faculty_evaluation_app/utils/comments_generator.dart';
// import 'package:faculty_evaluation_app/models/evaluation_criterion.dart';

// class CommentsCard extends StatefulWidget {
//   final TextEditingController commentsController;
//   final Map<String, int> ratings;
//   final List<EvaluationCriterion> mastery;
//   final List<EvaluationCriterion> instructional;
//   final List<EvaluationCriterion> communication;
//   final List<EvaluationCriterion> evaluation;
//   final List<EvaluationCriterion> classroom;

//   const CommentsCard({
//     super.key,
//     required this.commentsController,
//     required this.ratings,
//     required this.mastery,
//     required this.instructional,
//     required this.communication,
//     required this.evaluation,
//     required this.classroom,
//   });

//   @override
//   State<CommentsCard> createState() => _CommentsCardState();
// }

// class _CommentsCardState extends State<CommentsCard> {
//   Map<String, int>? _previousRatings;

//   @override
//   void initState() {
//     super.initState();
//     _previousRatings = Map.from(widget.ratings);
//   }

//   @override
//   void didUpdateWidget(CommentsCard oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     // Check if ratings have changed
//     if (_ratingsChanged()) {
//       _autoGenerateComments();
//       _previousRatings = Map.from(widget.ratings);
//     }
//   }

//   bool _ratingsChanged() {
//     if (_previousRatings == null) return false;
//     if (_previousRatings!.length != widget.ratings.length) return true;

//     for (var key in widget.ratings.keys) {
//       if (_previousRatings![key] != widget.ratings[key]) {
//         return true;
//       }
//     }
//     return false;
//   }

//   void _autoGenerateComments() {
//     final text = CommentsGenerator.generateComments(
//       masteryOfSubjectCriteria: widget.mastery,
//       instructionalSkillsCriteria: widget.instructional,
//       communicationSkillsCriteria: widget.communication,
//       evaluationTechniquesCriteria: widget.evaluation,
//       classroomManagementCriteria: widget.classroom,
//       ratings: widget.ratings,
//     );
//     widget.commentsController.text = text;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Comments & Suggestions',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 TextButton.icon(
//                   onPressed: _autoGenerateComments,
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('Regenerate'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: widget.commentsController,
//               maxLines: null,
//               minLines: 4,
//               decoration: const InputDecoration(
//                 hintText: 'Comments auto-generated based on ratings...',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:faculty_evaluation_app/utils/comments_generator.dart';
import 'package:faculty_evaluation_app/models/evaluation_criterion.dart';

class CommentsCard extends StatefulWidget {
  final TextEditingController commentsController;
  final Map<String, int> ratings;
  final List<EvaluationCriterion> mastery;
  final List<EvaluationCriterion> instructional;
  final List<EvaluationCriterion> communication;
  final List<EvaluationCriterion> evaluation;
  final List<EvaluationCriterion> classroom;

  const CommentsCard({
    super.key,
    required this.commentsController,
    required this.ratings,
    required this.mastery,
    required this.instructional,
    required this.communication,
    required this.evaluation,
    required this.classroom,
  });

  @override
  State<CommentsCard> createState() => _CommentsCardState();
}

class _CommentsCardState extends State<CommentsCard> {
  Map<String, int>? _previousRatings;

  @override
  void initState() {
    super.initState();
    _previousRatings = Map.from(widget.ratings);
    // Generate comments on initial load if ratings exist
    if (widget.ratings.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoGenerateComments();
      });
    }
  }

  @override
  void didUpdateWidget(CommentsCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if ratings have changed
    if (_ratingsChanged()) {
      _autoGenerateComments();
      _previousRatings = Map.from(widget.ratings);
    }
  }

  bool _ratingsChanged() {
    if (_previousRatings == null) return false;
    if (_previousRatings!.length != widget.ratings.length) return true;

    for (var key in widget.ratings.keys) {
      if (_previousRatings![key] != widget.ratings[key]) {
        return true;
      }
    }
    return false;
  }

  void _autoGenerateComments() {
    final text = CommentsGenerator.generateComments(
      masteryOfSubjectCriteria: widget.mastery,
      instructionalSkillsCriteria: widget.instructional,
      communicationSkillsCriteria: widget.communication,
      evaluationTechniquesCriteria: widget.evaluation,
      classroomManagementCriteria: widget.classroom,
      ratings: widget.ratings,
    );
    widget.commentsController.text = text;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Comments & Suggestions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.commentsController,
              maxLines: null,
              minLines: 4,
              decoration: const InputDecoration(
                hintText: 'Comments auto-generated based on ratings...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
