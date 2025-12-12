import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:faculty_evaluation_app/models/academic_period_model.dart';

class AcademicPeriodManagementPage extends StatefulWidget {
  const AcademicPeriodManagementPage({super.key});

  @override
  State<AcademicPeriodManagementPage> createState() =>
      _AcademicPeriodManagementPageState();
}

class _AcademicPeriodManagementPageState
    extends State<AcademicPeriodManagementPage> {
  List<AcademicPeriodModel> _periods = [];
  AcademicPeriodModel? _activePeriod;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPeriods();
  }

  // Fetch all academic periods
  Future<void> _fetchPeriods() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('academic_periods')
          .select()
          .order('start_date', ascending: false);

      setState(() {
        _periods = (response as List)
            .map((data) => AcademicPeriodModel.fromJson(data))
            .toList();
        _activePeriod = _periods.firstWhere(
          (p) => p.isActive,
          orElse: () => _periods.isNotEmpty
              ? _periods.first
              // ignore: cast_from_null_always_fails
              : null as AcademicPeriodModel,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error fetching periods: $e');
    }
  }

  // Create new academic period
  Future<void> _addPeriod(AcademicPeriodModel period) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('academic_periods').insert(period.toJson());

      _showSuccessSnackBar('Academic period added successfully');
      _fetchPeriods();
    } catch (e) {
      _showErrorSnackBar('Error adding period: $e');
    }
  }

  // Update existing period
  Future<void> _updatePeriod(
    String periodId,
    AcademicPeriodModel period,
  ) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('academic_periods')
          .update(period.toJson())
          .eq('id', periodId);

      _showSuccessSnackBar('Academic period updated successfully');
      _fetchPeriods();
    } catch (e) {
      _showErrorSnackBar('Error updating period: $e');
    }
  }

  // Set active period (deactivates all others)
  Future<void> _setActivePeriod(String periodId) async {
    try {
      final supabase = Supabase.instance.client;

      // Deactivate all periods first
      await supabase
          .from('academic_periods')
          .update({'is_active': false})
          .neq('id', '00000000-0000-0000-0000-000000000000');

      // Activate selected period
      await supabase
          .from('academic_periods')
          .update({'is_active': true})
          .eq('id', periodId);

      _showSuccessSnackBar('Active period updated successfully');
      _fetchPeriods();
    } catch (e) {
      _showErrorSnackBar('Error setting active period: $e');
    }
  }

  // Delete period
  Future<void> _deletePeriod(String periodId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('academic_periods').delete().eq('id', periodId);

      _showSuccessSnackBar('Academic period deleted successfully');
      _fetchPeriods();
    } catch (e) {
      _showErrorSnackBar('Error deleting period: $e');
    }
  }

  void _showPeriodDialog({AcademicPeriodModel? period}) {
    final isEditing = period != null;
    String schoolYear = period?.schoolYear ?? '';
    String semester = period?.semester ?? '1st Semester';
    DateTime startDate = period?.startDate ?? DateTime.now();
    DateTime endDate =
        period?.endDate ?? DateTime.now().add(const Duration(days: 120));
    bool isActive = period?.isActive ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            isEditing ? 'Edit Academic Period' : 'Add Academic Period',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'School Year (e.g., 2024-2025)',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: schoolYear),
                  onChanged: (value) => schoolYear = value,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: semester,
                  decoration: const InputDecoration(
                    labelText: 'Semester',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '1st Semester',
                      child: Text('1st Semester'),
                    ),
                    DropdownMenuItem(
                      value: '2nd Semester',
                      child: Text('2nd Semester'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() => semester = value!);
                  },
                ),
                const SizedBox(height: 15),
                ListTile(
                  title: const Text('Start Date'),
                  subtitle: Text(
                    '${startDate.month}/${startDate.day}/${startDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() => startDate = picked);
                    }
                  },
                ),
                ListTile(
                  title: const Text('End Date'),
                  subtitle: Text(
                    '${endDate.month}/${endDate.day}/${endDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() => endDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: const Text('Set as Active Period'),
                  value: isActive,
                  onChanged: (value) {
                    setDialogState(() => isActive = value ?? false);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (schoolYear.isEmpty) {
                  _showErrorSnackBar('Please enter school year');
                  return;
                }

                final newPeriod = AcademicPeriodModel(
                  id: period?.id ?? '',
                  schoolYear: schoolYear,
                  semester: semester,
                  isActive: isActive,
                  startDate: startDate,
                  endDate: endDate,
                );

                if (isEditing) {
                  _updatePeriod(period.id, newPeriod);
                } else {
                  _addPeriod(newPeriod);
                }

                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(AcademicPeriodModel period) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete ${period.schoolYear} ${period.semester}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deletePeriod(period.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Academic Period Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showPeriodDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Period'),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _fetchPeriods,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Active Period Card
          if (_activePeriod != null)
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 40,
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active Period',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '${_activePeriod!.schoolYear} - ${_activePeriod!.semester}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _periods.isEmpty
                  ? const Center(child: Text('No academic periods found'))
                  : ListView.builder(
                      itemCount: _periods.length,
                      itemBuilder: (context, index) {
                        final period = _periods[index];
                        return ListTile(
                          leading: Icon(
                            period.isActive
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: period.isActive ? Colors.green : Colors.grey,
                          ),
                          title: Text(
                            '${period.schoolYear} - ${period.semester}',
                            style: TextStyle(
                              fontWeight: period.isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            '${period.startDate.month}/${period.startDate.day}/${period.startDate.year} - ${period.endDate.month}/${period.endDate.day}/${period.endDate.year}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!period.isActive)
                                TextButton(
                                  onPressed: () => _setActivePeriod(period.id),
                                  child: const Text('Set Active'),
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () =>
                                    _showPeriodDialog(period: period),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDelete(period),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
