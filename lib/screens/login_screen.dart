import 'dashboards/program_chair_dashboard.dart';
import 'package:flutter/material.dart';
import 'dashboards/dean_dashboard.dart';
import 'dashboards/faculty_dashboard.dart';
import 'dashboards/admin_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;

  String _selectedRole = 'Faculty';
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final List<String> _roles = [
    'Dean',
    'Faculty',
    'Program Chairperson',
    'Admin',
  ];

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Future<void> _handleLogin() async {
  //   if (!_formKey.currentState!.validate()) {
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final customId = _idController.text.trim();
  //     final password = _passwordController.text;
  //     final hashedPassword = _hashPassword(password);

  //     // Query the users table with custom ID and hashed password
  //     final response = await _supabase
  //         .from('users')
  //         .select('custom_id, role, full_name')
  //         .eq('custom_id', customId)
  //         .eq('password_hash', hashedPassword)
  //         .maybeSingle();

  //     if (response == null) {
  //       _showErrorMessage('Invalid ID or password');
  //       return;
  //     }

  //     final userRole = response['role'] as String;

  //     // Verify selected role matches database role
  //     if (userRole.toLowerCase() != _selectedRole.toLowerCase()) {
  //       _showErrorMessage(
  //         'Access denied: Your account role does not match the selected role.',
  //       );
  //       return;
  //     }

  //     // Store user session info (you can use SharedPreferences or secure storage)
  //     await _storeUserSession(response);

  //     // Show success message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Login successful as $userRole'),
  //         backgroundColor: Colors.green,
  //         duration: const Duration(seconds: 2),
  //       ),
  //     );
  //     if (!mounted) return;

  //     // Navigate to appropriate dashboard
  //     _navigateToRoleDashboard(userRole);
  //   } catch (e) {
  //     _showErrorMessage('An unexpected error occurred. Please try again.');
  //     debugPrint('Login error: $e');
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final customId = _idController.text.trim();
      final password = _passwordController.text;
      final hashedPassword = _hashPassword(password);

      // Query the users table with custom ID and hashed password
      final response = await _supabase
          .from('users')
          .select('custom_id, role, full_name')
          .eq('custom_id', customId)
          .eq('password_hash', hashedPassword)
          .maybeSingle();

      if (response == null) {
        _showErrorMessage('Invalid ID or password');
        return;
      }

      // Add null checks for all fields
      final userRole = response['role'] as String?;
      final fullName = response['full_name'] as String?;
      final customIdFromDb = response['custom_id'] as String?;

      // Check if role is null
      if (userRole == null || userRole.isEmpty) {
        _showErrorMessage(
          'Account error: Role not assigned. Please contact administrator.',
        );
        debugPrint('User role is null for custom_id: $customId');
        return;
      }

      if (!mounted) return;

      // Verify selected role matches database role
      if (userRole.toLowerCase() != _selectedRole.toLowerCase()) {
        _showErrorMessage(
          'Access denied: Your account role does not match the selected role.',
        );
        return;
      }

      // Store user session info
      await _storeUserSession(response);

      // Show success message
      final displayName = fullName ?? userRole;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful as $displayName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      if (!mounted) return;

      // Navigate to appropriate dashboard
      _navigateToRoleDashboard(userRole);
    } catch (e) {
      _showErrorMessage('An unexpected error occurred. Please try again.');
      debugPrint('Login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _storeUserSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    // Safely handle all nullable fields
    final customId = userData['custom_id'] as String?;
    final role = userData['role'] as String?;
    final fullName = userData['full_name'] as String?;

    if (customId != null) {
      await prefs.setString('custom_id', customId);
    }

    if (role != null) {
      await prefs.setString('role', role);
    }

    if (fullName != null) {
      await prefs.setString('full_name', fullName);
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToRoleDashboard(String role) {
    Widget dashboard;
    switch (role.toLowerCase()) {
      case 'dean':
        dashboard = const DeanDashboard();
        break;
      case 'program chairperson':
      case 'program chair':
        dashboard = const ProgramChairDashboard();
        break;
      case 'faculty':
        dashboard = const FacultyDashboard();
        break;
      case 'admin':
        dashboard = const AdminDashboard();
        break;
      default:
        _showErrorMessage('Invalid role assigned to user');
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboard),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 32, 42, 68),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo and Title
                        Icon(
                          Icons.school,
                          size: 64,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Faculty Evaluation',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to your account',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Role Selection
                        Text(
                          'Select Role',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRole,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              hint: const Text('Select Role'),
                              items: _roles.map((String role) {
                                return DropdownMenuItem<String>(
                                  value: role,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getRoleIcon(role),
                                        size: 20,
                                        color: Colors.grey[700],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        role,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedRole = newValue!;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Custom ID Field
                        TextFormField(
                          controller: _idController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'ID',
                            hintText: 'Enter your ID (e.g., 2025-1111111)',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your ID';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Dean':
        return Icons.business_center;
      case 'Faculty':
        return Icons.person;
      case 'Program Chairperson':
        return Icons.rate_review;
      case 'Admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }
}
