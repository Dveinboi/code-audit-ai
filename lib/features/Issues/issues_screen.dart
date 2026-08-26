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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF111111) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
          },
        ),
        title: Text(
          'Issues',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip('All', '24', isDark, textColor, subtitleColor, cardColor, borderColor),
                  const SizedBox(width: 8),
                  _buildFilterChip('Critical', '2', isDark, textColor, subtitleColor, cardColor, borderColor),
                  const SizedBox(width: 8),
                  _buildFilterChip('High', '6', isDark, textColor, subtitleColor, cardColor, borderColor),
                  const SizedBox(width: 8),
                  _buildFilterChip('Medium', '8', isDark, textColor, subtitleColor, cardColor, borderColor),
                ],
              ),
            ),
            const SizedBox(height: 8),
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
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.5),
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
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isHigh ? const Color(0xFFFEF2F2).withOpacity(isDark ? 0.1 : 1.0) : const Color(0xFFFEF3C7).withOpacity(isDark ? 0.1 : 1.0),
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
                              style: TextStyle(
                                fontSize: 13,
                                color: subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              issue['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: dividerColor, width: 1.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
            } else if (index == 1) {
              // Do nothing
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

  Widget _buildFilterChip(String label, String count, bool isDark, Color textColor, Color subtitleColor, Color cardColor, Color borderColor) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text('$label $count'),
      selected: isSelected,
      selectedColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF1E293B),
      backgroundColor: isDark ? cardColor : const Color(0xFFF8FAFC),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : subtitleColor,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Colors.transparent : borderColor),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
    );
  }
}