import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:faculty_evaluation_app/models/user_model.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = false;
  String _selectedRole = 'All Roles';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // READ - Fetch all users
  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('users')
          .select('id, name, role, created_at')
          .order('created_at', ascending: false);

      setState(() {
        _users = (response as List)
            .map((data) => UserModel.fromJson(data))
            .toList();
        _filteredUsers = _users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error fetching users: $e');
    }
  }

  // CREATE - Add new user
  Future<void> _addUser(UserModel user) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('users').insert(user.toJson());

      _showSuccessSnackBar('User added successfully');
      _fetchUsers();
    } catch (e) {
      _showErrorSnackBar('Error adding user: $e');
    }
  }

  // UPDATE - Edit existing user
  Future<void> _updateUser(String userId, UserModel user) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('users').update(user.toJson()).eq('id', userId);

      _showSuccessSnackBar('User updated successfully');
      _fetchUsers();
    } catch (e) {
      _showErrorSnackBar('Error updating user: $e');
    }
  }

  // DELETE - Remove user
  Future<void> _deleteUser(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('users').delete().eq('id', userId);

      _showSuccessSnackBar('User deleted successfully');
      _fetchUsers();
    } catch (e) {
      _showErrorSnackBar('Error deleting user: $e');
    }
  }

  // Filter users by search and role
  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        bool matchesSearch = user.name.toLowerCase().contains(query);
        bool matchesRole =
            _selectedRole == 'All Roles' || user.role == _selectedRole;
        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  void _showUserDialog({UserModel? user}) {
    final isEditing = user != null;
    final nameController = TextEditingController(text: user?.name ?? '');
    String selectedRole = user?.role ?? 'Faculty';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit User' : 'Add New User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Dean', child: Text('Dean')),
                    DropdownMenuItem(value: 'Faculty', child: Text('Faculty')),
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedRole = value!);
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
                if (nameController.text.isEmpty) {
                  _showErrorSnackBar('Please enter a name');
                  return;
                }

                final newUser = UserModel(
                  id: user?.id ?? '',
                  name: nameController.text,
                  role: selectedRole,
                );

                if (isEditing) {
                  _updateUser(user.id, newUser);
                } else {
                  _addUser(newUser);
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

  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteUser(user.id);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // adjust breakpoint as needed

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Management',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _showUserDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('Add User'),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _fetchUsers,
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'User Management',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _showUserDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('Add User'),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _fetchUsers,
                            ),
                          ],
                        ),
                      ],
                    ),

              const SizedBox(height: 20),

              // User Stat
              _buildUserStatCard(
                'Total Users',
                '${_users.length}',
                Icons.people,
                Colors.blue,
              ),

              const SizedBox(height: 20),

              // Search & Filter
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search users...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'All Roles',
                              child: Text('All Roles'),
                            ),
                            DropdownMenuItem(
                              value: 'Dean',
                              child: Text('Dean'),
                            ),
                            DropdownMenuItem(
                              value: 'Faculty',
                              child: Text('Faculty'),
                            ),
                            DropdownMenuItem(
                              value: 'Admin',
                              child: Text('Admin'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedRole = value!);
                            _filterUsers();
                          },
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search users...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: _selectedRole,
                          items: const [
                            DropdownMenuItem(
                              value: 'All Roles',
                              child: Text('All Roles'),
                            ),
                            DropdownMenuItem(
                              value: 'Dean',
                              child: Text('Dean'),
                            ),
                            DropdownMenuItem(
                              value: 'Faculty',
                              child: Text('Faculty'),
                            ),
                            DropdownMenuItem(
                              value: 'Admin',
                              child: Text('Admin'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedRole = value!);
                            _filterUsers();
                          },
                        ),
                      ],
                    ),

              const SizedBox(height: 20),

              // Table Section
              Expanded(
                child: Card(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredUsers.isEmpty
                      ? const Center(child: Text('No users found'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                    Colors.grey[100],
                                  ),
                                  columnSpacing: isMobile ? 20 : 40,
                                  columns: const [
                                    DataColumn(label: Text('Name')),
                                    DataColumn(label: Text('Role')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: _filteredUsers.map((user) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(user.name)),
                                        DataCell(
                                          Chip(
                                            label: Text(user.role),
                                            backgroundColor: _getRoleColor(
                                              user.role,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Wrap(
                                            alignment: WrapAlignment.center,
                                            spacing: 4,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 20,
                                                ),
                                                onPressed: () =>
                                                    _showUserDialog(user: user),
                                                tooltip: 'Edit',
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () =>
                                                    _confirmDelete(user),
                                                tooltip: 'Delete',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Dean':
        return Colors.purple.shade100;
      case 'Admin':
        return Colors.orange.shade100;
      case 'Faculty':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Widget _buildUserStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(title, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
