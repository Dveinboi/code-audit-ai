import 'package:code_audit_ai/features/Issues/issues_screen.dart';
import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';
import '../ai/ai_screen.dart';
import '../history/history_screen.dart';
import '../issues/category_issues_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String repoName;
  final bool isLoggedInWithGithub; // Controls 'New Repo' flow destination

  const DashboardScreen({
    Key? key,
    this.repoName = 'codeaudit-mobile-app',
    this.isLoggedInWithGithub = true,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentBottomNavIndex = 0;

  void _onBottomNavTapped(int index) {
    if (index == 1) {
      // Navigate to Issues Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const IssuesScreen()),
      );
      return;
    }
    if (index == 2) {
      // Navigate to AI Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AiScreen()),
      );
      return;
    }
    if (index == 3) {
      // 'New Repo' tab pressed
      if (widget.isLoggedInWithGithub) {
        Navigator.pushNamed(context, '/select_repo');
      } else {
        Navigator.pushNamed(context, '/add_repo');
      }
      return;
    }
    if (index == 4) {
      // Navigate to History Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HistoryScreen()),
      );
      return;
    }

    setState(() {
      _currentBottomNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Stack(
          alignment: Alignment.center,
          children: [
            // Left-aligned Profile Avatar with navigation to ProfileScreen
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF1E293B),
                  child: Icon(Icons.person, size: 20, color: Colors.white),
                ),
              ),
            ),
            // Centered Repository Name
            Center(
              child: Text(
                widget.repoName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: Column(
              children: [
                // Section Title
                const Text(
                  'Overall Score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),

                // Overall Score Ring
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: 0.78, // 78/100
                        strokeWidth: 10,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '78',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '/100',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                const Text(
                  'Good',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),

                const SizedBox(height: 32),

                // Metrics Row Cards mapping directly to the exact issues from the Issue page
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      // Security Card -> Passes "Hardcoded API Key" & "SQL Injection Risk"
                      _buildMetricCard(
                        icon: Icons.shield_outlined,
                        title: 'Security',
                        score: '82',
                        scoreColor: const Color(0xFF10B981),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryIssuesScreen(
                                categoryName: 'Security',
                                score: '82',
                                scoreColor: const Color(0xFF10B981),
                                categoryIssues: [
                                  {
                                    'title': 'Hardcoded API Key',
                                    'severity': 'High',
                                    'category': 'Security',
                                    'location': 'src/config/api.ts:12',
                                    'description':
                                        'Potential hardcoded API key found in the code.',
                                    'recommendation':
                                        'Move API keys to environment variables (.env).',
                                    'codeSnippet':
                                        'const apiKey = "sk_live_958173958173";\nexport default apiKey;',
                                    'line': '12',
                                  },
                                  {
                                    'title': 'SQL Injection Risk',
                                    'severity': 'High',
                                    'category': 'Security',
                                    'location': 'src/user/query.py:87',
                                    'description':
                                        'User input is concatenated into SQL query, which can lead to SQL injection.',
                                    'recommendation':
                                        'Use parameterized queries or ORM query builders.',
                                    'codeSnippet':
                                        'cursor.execute("SELECT * FROM users WHERE name = " + user_input)',
                                    'line': '87',
                                  },
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),

                      // Quality Card -> Passes "Missing Input Validation"
                      _buildMetricCard(
                        icon: Icons.account_tree_outlined,
                        title: 'Quality',
                        score: '74',
                        scoreColor: const Color(0xFFF59E0B),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryIssuesScreen(
                                categoryName: 'Quality',
                                score: '74',
                                scoreColor: const Color(0xFFF59E0B),
                                categoryIssues: [
                                  {
                                    'title': 'Missing Input Validation',
                                    'severity': 'Medium',
                                    'category': 'Quality',
                                    'location': 'src/auth/login.js:45',
                                    'description':
                                        'User input is not validated.',
                                    'recommendation':
                                        'Implement robust validation rules before processing input data.',
                                    'codeSnippet':
                                        'function handleLogin(input) { authenticate(input); }',
                                    'line': '45',
                                  },
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),

                      // Performance Card
                      _buildMetricCard(
                        icon: Icons.speed_outlined,
                        title: 'Performance',
                        score: '68',
                        scoreColor: const Color(0xFFF59E0B),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryIssuesScreen(
                                categoryName: 'Performance',
                                score: '68',
                                scoreColor: const Color(0xFFF59E0B),
                                categoryIssues: [],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),

                      // Maintainability Card
                      _buildMetricCard(
                        icon: Icons.build_outlined,
                        title: 'Maintainability',
                        score: '90',
                        scoreColor: const Color(0xFF10B981),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryIssuesScreen(
                                categoryName: 'Maintainability',
                                score: '90',
                                scoreColor: const Color(0xFF10B981),
                                categoryIssues: [],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),

                      // Deps Card -> Passes "Outdated Dependency"
                      _buildMetricCard(
                        icon: Icons.extension_outlined,
                        title: 'Deps',
                        score: '65',
                        scoreColor: const Color(0xFFF59E0B),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryIssuesScreen(
                                categoryName: 'Dependencies',
                                score: '65',
                                scoreColor: const Color(0xFFF59E0B),
                                categoryIssues: [
                                  {
                                    'title': 'Outdated Dependency',
                                    'severity': 'Medium',
                                    'category': 'Dependencies',
                                    'location': 'Package: lodash',
                                    'description':
                                        'Update lodash to v4.17.21 or higher.',
                                    'recommendation':
                                        'Update package version configuration in your project dependencies.',
                                    'codeSnippet': '"lodash": "^4.17.15"',
                                    'line': '1',
                                  },
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // AI Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'The repository is in good condition. Security and performance need improvement. Consider addressing the high priority issues.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Generate PDF Report Button UI
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // PDF generation logic will go here later
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF1E293B,
                      ), // Dark professional theme matching your AppBar avatar
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                    label: const Text(
                      'Generate PDF Report',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),

      // Custom Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentBottomNavIndex,
          onTap: _onBottomNavTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
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

  // Metric Card Builder Helper with onTap action
  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String score,
    required Color scoreColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 105,
        height: 125,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 22),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              score,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
