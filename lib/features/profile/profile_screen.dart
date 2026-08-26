import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme_provider.dart'; // for themeNotifier
import '../issues/issues_screen.dart'; 
import '../ai/ai_screen.dart'; 
import '../history/history_screen.dart'; 
import 'connected_account_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safely get user metadata from Supabase
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? {};
    final avatarUrl = metadata['avatar_url'] as String? ?? '';
    final fullName = metadata['full_name'] ?? metadata['name'] ?? 'Unknown User';
    final userName = metadata['preferred_username'] ?? metadata['user_name'] ?? 'unknown';

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
        final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
        final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
        final bgColor = Theme.of(context).scaffoldBackgroundColor;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text(
              'Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
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
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFF1E293B),
                        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl.isEmpty
                            ? const Icon(Icons.person, size: 32, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@$userName',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: subtitleColor,
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
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ConnectedAccountScreen()),
                      );
                    },
                  ),
                  Divider(color: dividerColor, height: 1),
                  _buildProfileMenuToggle(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    value: isDark,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    onChanged: (val) async {
                      themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('is_dark_mode', val);
                    },
                  ),
                  Divider(color: dividerColor, height: 1),
                  _buildProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        foregroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: dividerColor, width: 1.5)),
            ),
            child: BottomNavigationBar(
              currentIndex: 0, 
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
                }
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: bgColor,
              elevation: 0,
              selectedItemColor: const Color(0xFF10B981),
              unselectedItemColor: subtitleColor,
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
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    String? trailingText,
    required Color textColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: subtitleColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14, color: subtitleColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuToggle({
    required IconData icon,
    required String title,
    required bool value,
    required Color textColor,
    required Color subtitleColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: subtitleColor, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }
}