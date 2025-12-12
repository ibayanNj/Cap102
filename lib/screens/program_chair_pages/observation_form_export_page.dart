import 'package:flutter/material.dart';

import 'package:faculty_evaluation_app/services/print_services.dart';
import 'package:pdf/pdf.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ObservationFormExportPage extends StatefulWidget {
  final String? evaluationId; // Pass evaluation ID from previous screen

  const ObservationFormExportPage({super.key, this.evaluationId});

  @override
  State<ObservationFormExportPage> createState() =>
      _ObservationFormExportPageState();
}

const PdfPageFormat legalPageFormat = PdfPageFormat(
  8.5 * PdfPageFormat.inch,
  13 * PdfPageFormat.inch,
  marginAll: 0.7 * PdfPageFormat.inch,
);

class _ObservationFormExportPageState extends State<ObservationFormExportPage> {
  bool _isLoading = false;
  String? _savedPath;
  EvaluationData? _evaluationData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEvaluationData();
  }

  // Fetch evaluation data from Supabase
  Future<void> _fetchEvaluationData() async {
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      Map<String, dynamic> response;

      // If no evaluationId provided, fetch the latest evaluation
      if (widget.evaluationId == null || widget.evaluationId!.isEmpty) {
        final list = await supabase
            .from('evaluations')
            .select()
            .order('created_at', ascending: false)
            .limit(1);

        if (list.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No evaluations found';
          });
          return;
        }
        response = list.first;
      } else {
        // Fetch specific evaluation by ID
        response = await supabase
            .from('evaluations')
            .select()
            .eq('id', widget.evaluationId!)
            .single();
      }

      // Convert Supabase response to EvaluationData
      _evaluationData = _convertToEvaluationData(response);

      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load evaluation: $e';
      });
    }
  }

  // Convert Supabase JSON to EvaluationData object
  EvaluationData _convertToEvaluationData(Map<String, dynamic> data) {
    // Helper function to safely convert to int
    int toInt(dynamic value) =>
        value is int ? value : (value is double ? value.toInt() : 0);

    return EvaluationData(
      facultyName: data['faculty_name'] ?? '',
      courseTaught: data['course_name'] ?? '',
      dateTime: data['submitted_at'] != null
          ? _formatDateTime(data['submitted_at'])
          : '',
      buildingRoom: data['room']?.toString() ?? '',
      semester: _formatSemester(data['semester']),
      schoolYear: data['school_year']?.toString() ?? '',

      // Mastery ratings (4 items)
      masteryRatings: {
        'Presents lesson logically': toInt(data['mastery_1']),
        'Relates lesson to local/national issues': toInt(data['mastery_2']),
        'Provides explanation beyond the content of the book': toInt(
          data['mastery_3'],
        ),
        'Teaches independent of notes': toInt(data['mastery_4']),
      },

      // Instructional ratings (10 items)
      instructionalRatings: {
        'Uses motivation techniques that elicit student\'s interest': toInt(
          data['instructional_1'],
        ),
        'Links the past with the present lesson': toInt(
          data['instructional_2'],
        ),
        'Uses varied strategies suited to the student\'s needs': toInt(
          data['instructional_3'],
        ),
        'Asks varied types of questions': toInt(data['instructional_4']),
        'Anticipates difficulties of students': toInt(data['instructional_5']),
        'Provides appropriate reinforcement to student\'s responses': toInt(
          data['instructional_6'],
        ),
        'Utilizes multiple sources of information': toInt(
          data['instructional_7'],
        ),
        'Encourages maximum student\'s participation': toInt(
          data['instructional_8'],
        ),
        'Integrates values in the lesson': toInt(data['instructional_9']),
        'Provides opportunities for free expression of ideas': toInt(
          data['instructional_10'],
        ),
      },

      // Communication ratings (6 items)
      communicationRatings: {
        'Speaks in a well-modulated voice': toInt(data['communication_1']),
        'Uses language appropriate to the level of the class': toInt(
          data['communication_2'],
        ),
        'Pronounces words correctly': toInt(data['communication_3']),
        'Observes correct grammar in both speaking and writing': toInt(
          data['communication_4'],
        ),
        'Encourages students to speak and write': toInt(
          data['communication_5'],
        ),
        'Listens attentively to student\'s response': toInt(
          data['communication_6'],
        ),
      },

      // Evaluation ratings (2 items)
      evaluationRatings: {
        'Evaluates student\'s achievement based in the day\'s lesson': toInt(
          data['evaluation_1'],
        ),
        'Utilizes appropriate assessment tools and techniques': toInt(
          data['evaluation_2'],
        ),
      },

      // Classroom/Management ratings (5 items) - Section E
      managementRatings: {
        'Maintains discipline (e.g. Keeps students on task)': toInt(
          data['classroom_1'],
        ),
        'Manages time profitably through curriculum-related activities': toInt(
          data['classroom_2'],
        ),
        'Maximizes use of resources': toInt(data['classroom_3']),
        'Maintains good rapport with the students': toInt(data['classroom_4']),
        'Shows respect for individual student\'s limitations': toInt(
          data['classroom_5'],
        ),
      },

      comments: data['comments']?.toString() ?? '',
      evaluatorName: 'Evaluator', // Update if you have this field
      evaluatorSignature: '',
      facultySignature: '',
      date: data['submitted_at'] != null
          ? _formatDate(data['submitted_at'])
          : '',
    );
  }

  // Format datetime for display
  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')} -- ${dt.add(Duration(hours: 1)).hour}:${dt.add(Duration(hours: 1)).minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  // Format date for display
  String _formatDate(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
    } catch (e) {
      return dateTime;
    }
  }

  // Format semester
  String _formatSemester(dynamic semester) {
    if (semester == null) return '';
    final sem = semester.toString();
    if (sem == '1') return '1ST';
    if (sem == '2') return '2ND';
    return sem;
  }

  Future<void> _exportPDF() async {
    if (_evaluationData == null) {
      _showError('No evaluation data available');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final path = await ClassObservationPDFGenerator.savePDF(_evaluationData!);

      setState(() {
        _savedPath = path;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error saving PDF: $e');
    }
  }

  Future<void> _sharePDF() async {
    if (_evaluationData == null) {
      _showError('No evaluation data available');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ClassObservationPDFGenerator.sharePDF(_evaluationData!);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error sharing PDF: $e');
    }
  }

  Future<void> _printPDF() async {
    if (_evaluationData == null) {
      _showError('No evaluation data available');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ClassObservationPDFGenerator.printPDF(_evaluationData!);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error printing PDF: $e');
    }
  }

  Future<void> _previewPDF() async {
    if (_evaluationData == null) {
      _showError('No evaluation data available');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ClassObservationPDFGenerator.previewPDF(_evaluationData!);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error previewing PDF: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Evaluation')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _errorMessage != null
            ? Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _fetchEvaluationData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _evaluationData == null
            ? const Text('No evaluation data found')
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Classroom Observation Form',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _evaluationData!.facultyName,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Export your completed evaluation form as a PDF document',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _previewPDF,
                            icon: const Icon(Icons.preview),
                            label: const Text('Preview PDF'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _exportPDF,
                            icon: const Icon(Icons.save),
                            label: const Text('Save PDF'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _sharePDF,
                            icon: const Icon(Icons.share),
                            label: const Text('Share PDF'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _printPDF,
                            icon: const Icon(Icons.print),
                            label: const Text('Print PDF'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_savedPath != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'PDF Saved Successfully!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _savedPath!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
