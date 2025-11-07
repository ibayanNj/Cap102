import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

class BaseDashboard extends StatefulWidget {
  final String role;
  final String userName;
  final List<SidebarItem> sidebarItems;
  final List<Widget> pages;

  const BaseDashboard({
    super.key,
    required this.role,
    required this.userName,
    required this.sidebarItems,
    required this.pages,
  });

  @override
  State<BaseDashboard> createState() => _BaseDashboardState();
}

class _BaseDashboardState extends State<BaseDashboard> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isMobileLayout(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width < 700;
  }

  Widget _buildCurrentPage() {
    if (widget.pages.isEmpty) {
      return const Center(child: Text('No content available'));
    }
    final int safeIndex = _selectedIndex.clamp(0, widget.pages.length - 1);
    return widget.pages[safeIndex];
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              color: const Color.fromARGB(255, 32, 42, 68),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color.fromARGB(255, 32, 42, 68),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.role,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: widget.sidebarItems.length,
                itemBuilder: (context, index) {
                  final SidebarItem item = widget.sidebarItems[index];
                  final bool isSelected = index == _selectedIndex;
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? Colors.black.withValues(alpha: 0.05)
                          : null,
                    ),
                    child: ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.of(context).pop();
                  _logout(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = _isMobileLayout(context);

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(
            color: Color.fromARGB(255, 32, 42, 68),
          ),
          title: Text(
            widget.sidebarItems.isNotEmpty
                ? widget.sidebarItems[_selectedIndex].title
                : 'Menu',
            style: const TextStyle(
              color: Color.fromARGB(255, 32, 42, 68),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        drawer: _buildMobileDrawer(context),
        body: Container(color: Colors.grey[50], child: _buildCurrentPage()),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 300,
            color: const Color.fromARGB(255, 32, 42, 68),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Color.fromARGB(255, 32, 42, 68),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.role,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white30, height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: widget.sidebarItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.sidebarItems[index];
                      final isSelected = index == _selectedIndex;
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.1)
                              : null,
                        ),
                        child: ListTile(
                          leading: Icon(
                            item.icon,
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white70),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onTap: () => _logout(context),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        widget.sidebarItems[_selectedIndex].title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 32, 42, 68),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey[50],
                    child: _buildCurrentPage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class SidebarItem {
  final IconData icon;
  final String title;

  SidebarItem({required this.icon, required this.title});
}
