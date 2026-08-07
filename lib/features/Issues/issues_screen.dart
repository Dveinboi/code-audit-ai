import 'package:flutter/material.dart';
import '../ai/ai_screen.dart'; 
import '../history/history_screen.dart'; // Added History screen import
import 'issue_details_screen.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({Key? key}) : super(key: key);

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  String _selectedFilter = 'All';

  // Dummy issues list
  final List<Map<String, dynamic>> _issues = [
    {
      'title': 'Hardcoded API Key',
      'severity': 'High',
      'location': 'src/config/api.ts:12',
      'description': 'Potential hardcoded API key found in the code.',
      'recommendation': 'Move API keys to environment variables (.env).',
      'codeSnippet': 'const apiKey = "sk_live_958173958173";\nexport default apiKey;',
      'line': '12',
    },
    {
      'title': 'SQL Injection Risk',
      'severity': 'High',
      'location': 'src/user/query.py:87',
      'description': 'User input is concatenated into SQL query, which can lead to SQL injection.',
      'recommendation': 'Use parameterized queries or ORM to prevent SQL injection.',
      'codeSnippet': '85  query = "SELECT * FROM users"\n86  WHERE id = " + user_id\n87  cursor.execute(query)',
      'line': '87',
    },
    {
      'title': 'Outdated Dependency',
      'severity': 'Medium',
      'location': 'Package: lodash',
      'description': 'Update lodash to v4.17.21 or higher.',
      'recommendation': 'Run npm install lodash@latest to patch security vulnerabilities.',
      'codeSnippet': '"dependencies": {\n  "lodash": "^4.17.15"\n}',
      'line': '4',
    },
    {
      'title': 'Missing Input Validation',
      'severity': 'Medium',
      'location': 'src/auth/login.js:45',
      'description': 'User input is not validated.',
      'recommendation': 'Implement schema validation using Joi or express-validator.',
      'codeSnippet': 'const username = req.body.username;\nauthenticate(username);',
      'line': '45',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredIssues = _selectedFilter == 'All'
        ? _issues
        : _issues.where((i) => i['severity'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // Updated Back Arrow Button to route directly back to Dashboard
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
          },
        ),
        title: const Text(
          'Issues',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip('All', '24'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Critical', '2'),
                  const SizedBox(width: 8),
                  _buildFilterChip('High', '6'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Medium', '8'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Issues List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredIssues.length,
                itemBuilder: (context, index) {
                  final issue = filteredIssues[index];
                  final isHigh = issue['severity'] == 'High';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IssueDetailsScreen(issueData: issue),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFFEF4444)),
                                    const SizedBox(width: 8),
                                    Text(
                                      issue['title'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isHigh ? const Color(0xFFFEF2F2) : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    issue['severity'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isHigh ? const Color(0xFFEF4444) : const Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'File: ${issue['location']}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              issue['description'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: 1, // 'Issues' selected
          onTap: (index) {
            if (index == 0) {
              Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
            } else if (index == 1) {
              // Do nothing, already on Issues Screen
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AiScreen()));
            } else if (index == 3) {
              Navigator.pushNamed(context, '/select_repo');
            } else if (index == 4) {
              // Updated to correctly navigate to History Screen
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
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Overview'),
            BottomNavigationBarItem(icon: Icon(Icons.bug_report_outlined), activeIcon: Icon(Icons.bug_report), label: 'Issues'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), activeIcon: Icon(Icons.auto_awesome), label: 'AI'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'New Repo'),
            BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'History'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String count) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text('$label $count'),
      selected: isSelected,
      selectedColor: const Color(0xFF1E293B),
      backgroundColor: const Color(0xFFF8FAFC),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF64748B),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
    );
  }
}