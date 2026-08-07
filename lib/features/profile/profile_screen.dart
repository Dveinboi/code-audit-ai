import 'package:flutter/material.dart';
import '../issues/issues_screen.dart'; // Adjust path if needed
import '../ai/ai_screen.dart'; // Adjust path if needed
import '../history/history_screen.dart'; // Added History screen import

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Header Section
              Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFF1E293B),
                    child: Icon(
                      Icons.code, // GitHub-style placeholder icon
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '@johndoe',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Menu Options List
              _buildProfileMenuItem(
                icon: Icons.code_outlined,
                title: 'Connected Account',
                trailingText: 'GitHub',
                onTap: () {},
              ),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              _buildProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {},
              ),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              _buildProfileMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {},
              ),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              _buildProfileMenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
              ),

              // Pushes the logout button slightly lower with increased spacing
              const SizedBox(height: 48),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Pops everything and routes back to the welcome/login screen
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login', 
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF2F2), // Light red tint
                    foregroundColor: const Color(0xFFEF4444), // Red text color
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar added here
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: 0, // Profile doesn't technically map to index 0, but this keeps the nav styling consistent
          onTap: (index) {
            if (index == 0) {
              Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
            } else if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const IssuesScreen()));
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AiScreen()));
            } else if (index == 3) {
              Navigator.pushNamed(context, '/select_repo');
            } else if (index == 4) {
              // Added Navigation to History screen
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bug_report_outlined),
              activeIcon: Icon(Icons.bug_report),
              label: 'Issues',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome),
              label: 'AI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'New Repo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for list items
  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}