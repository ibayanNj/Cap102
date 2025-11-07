// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'dashboards/program_chair_dashboard.dart';
// import 'dashboards/dean_dashboard.dart';
// import 'dashboards/faculty_dashboard.dart';
// import 'dashboards/admin_dashboard.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _idController = TextEditingController();
//   final _passwordController = TextEditingController();

//   bool _isPasswordVisible = false;
//   bool _isLoading = false;

//   final supabase = Supabase.instance.client;

//   @override
//   void dispose() {
//     _idController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _handleLogin() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Convert ID to email format for Supabase auth
//       final email = '${_idController.text.trim()}@facultyeval.local';

//       // Sign in with Supabase
//       final response = await supabase.auth.signInWithPassword(
//         email: email,
//         password: _passwordController.text.trim(),
//       );

//       if (!mounted) return;

//       // Get user role from database
//       final userRole = await supabase
//           .from('users')
//           .select('role, employee_id, full_name')
//           .eq('id', response.user!.id)
//           .single();

//       if (!mounted) return;

//       setState(() {
//         _isLoading = false;
//       });

//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Welcome back, ${userRole['full_name'] ?? 'User'}!'),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 2),
//         ),
//       );

//       // Navigate to appropriate dashboard based on role
//       _navigateToRoleDashboard(userRole['role']);
//     } on AuthException catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _isLoading = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(_getErrorMessage(error.message)),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     } catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _isLoading = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('An unexpected error occurred: ${error.toString()}'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   String _getErrorMessage(String error) {
//     if (error.contains('Invalid login credentials')) {
//       return 'Invalid ID or password';
//     } else if (error.contains('Email not confirmed')) {
//       return 'Please verify your email address';
//     } else if (error.contains('User not found')) {
//       return 'No account found with this ID';
//     }
//     return 'Login failed. Please try again.';
//   }

//   void _navigateToRoleDashboard(String role) {
//     Widget dashboard;
//     switch (role) {
//       case 'Dean':
//         dashboard = const DeanDashboard();
//         break;
//       case 'Program Chairperson':
//         dashboard = const ProgramChairDashboard();
//         break;
//       case 'Faculty':
//         dashboard = const FacultyDashboard();
//         break;
//       case 'Admin':
//         dashboard = const AdminDashboard();
//         break;
//       default:
//         // If role is not recognized, show error and stay on login
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Invalid user role'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//     }

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => dashboard),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 32, 42, 68),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(32),
//             child: Card(
//               elevation: 8,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(32.0),
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxWidth: 400),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         // Logo and Title
//                         Icon(
//                           Icons.school,
//                           size: 64,
//                           color: Theme.of(context).primaryColor,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Faculty Evaluation',
//                           style: Theme.of(context).textTheme.headlineSmall
//                               ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Sign in to your account',
//                           style: Theme.of(context).textTheme.bodyMedium
//                               ?.copyWith(color: Colors.grey[600]),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 32),

//                         // ID Field
//                         TextFormField(
//                           controller: _idController,
//                           keyboardType: TextInputType.text,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your ID';
//                             }
//                             return null;
//                           },
//                           decoration: InputDecoration(
//                             labelText: 'Employee ID',
//                             hintText: 'e.g., 2025-12388',
//                             prefixIcon: const Icon(Icons.badge_outlined),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide(color: Colors.grey[300]!),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide(
//                                 color: Theme.of(context).primaryColor,
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),

//                         // Password Field
//                         TextFormField(
//                           controller: _passwordController,
//                           obscureText: !_isPasswordVisible,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your password';
//                             }
//                             if (value.length < 6) {
//                               return 'Password must be at least 6 characters';
//                             }
//                             return null;
//                           },
//                           decoration: InputDecoration(
//                             labelText: 'Password',
//                             hintText: 'Enter your password',
//                             prefixIcon: const Icon(Icons.lock_outline),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _isPasswordVisible
//                                     ? Icons.visibility_off
//                                     : Icons.visibility,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _isPasswordVisible = !_isPasswordVisible;
//                                 });
//                               },
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide(color: Colors.grey[300]!),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide(
//                                 color: Theme.of(context).primaryColor,
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 24),

//                         // Login Button
//                         SizedBox(
//                           height: 48,
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _handleLogin,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Theme.of(context).primaryColor,
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               elevation: 2,
//                             ),
//                             child: _isLoading
//                                 ? const SizedBox(
//                                     height: 20,
//                                     width: 20,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       valueColor: AlwaysStoppedAnimation<Color>(
//                                         Colors.white,
//                                       ),
//                                     ),
//                                   )
//                                 : const Text(
//                                     'Sign In',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),

//                         // Help Text
//                         Text(
//                           'Contact your administrator if you forgot your password',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dashboards/program_chair_dashboard.dart';
import 'package:flutter/material.dart';
import 'dashboards/dean_dashboard.dart';
import 'dashboards/faculty_dashboard.dart';
import 'dashboards/admin_dashboard.dart';
// import 'package:supabase/supabase.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

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

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login successful as $_selectedRole'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );

    // Navigate to appropriate dashboard based on role
    _navigateToRoleDashboard();
  }

  void _navigateToRoleDashboard() {
    Widget dashboard;
    switch (_selectedRole) {
      case 'Dean':
        dashboard = const DeanDashboard();
        break;
      case 'Program Chairperson':
        dashboard = const ProgramChairDashboard();
        break;
      case 'Faculty':
        dashboard = const FacultyDashboard();
        break;
      case 'Admin':
        dashboard = const AdminDashboard();
        break;
      default:
        dashboard = const LoginScreen();
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

                        // ID Field
                        TextFormField(
                          controller: _idController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'ID',
                            hintText: 'Enter your ID',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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
                        ),
                        const SizedBox(height: 24),

                        // Forgot Password
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
