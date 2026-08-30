import 'package:flutter/material.dart';
import '../ai/ai_screen.dart'; 
import '../history/history_screen.dart';
import 'issue_details_screen.dart';
import '../dashboard/dashboard_screen.dart'; // To access globalLatestReportData

class IssuesScreen extends StatefulWidget {
  final Map<String, dynamic>? reportData;

  const IssuesScreen({Key? key, this.reportData}) : super(key: key);

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _issues = [];

  final List<String> _categories = [
    'All',
    'Security',
    'Quality',
    'Architecture',
    'Performance',
    'Maintainability',
    'Testing',
    'UX'
  ];

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  void _loadIssues() {
    final reportData = widget.reportData ?? globalLatestReportData;
    if (reportData != null && reportData['detailed_findings'] != null) {
      final findings = reportData['detailed_findings'] as List<dynamic>;
      _issues = findings.map((f) {
        final finding = f as Map<String, dynamic>;
        return {
          'title': finding['title'] ?? 'Unknown Issue',
          'severity': finding['severity'] ?? 'Medium',
          'location': finding['evidence'] ?? 'Unknown Location',
          'description': finding['impact'] ?? 'No impact specified',
          'recommendation': finding['recommendation'] ?? 'No recommendation',
          'codeSnippet': finding['priority'] != null ? 'Priority: ${finding['priority']}\nConfidence: ${finding['confidence']}' : 'No code snippet provided.',
          'line': finding['category'] ?? 'General',
        };
      }).toList();
    } else {
      _issues = [
        {
          'title': 'No detailed findings found',
          'severity': 'Informational',
          'location': 'N/A',
          'description': 'This report was generated before the evidence-based analysis engine was deployed.',
          'recommendation': 'Re-analyze the repository to view detailed findings.',
          'codeSnippet': '',
          'line': '',
        }
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredIssues = _selectedFilter == 'All'
        ? _issues
        : _issues.where((i) => i['line'].toString().toLowerCase().contains(_selectedFilter.toLowerCase())).toList();

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
          'Detailed Findings',
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
                children: _categories.map((cat) {
                  int count = cat == 'All' 
                      ? _issues.length 
                      : _issues.where((i) => i['line'].toString().toLowerCase().contains(cat.toLowerCase())).length;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildFilterChip(cat, '$count', isDark, textColor, subtitleColor, cardColor, borderColor),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredIssues.length,
                itemBuilder: (context, index) {
                  final issue = filteredIssues[index];
                  final isHigh = issue['severity'] == 'High' || issue['severity'] == 'Critical';
                  
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
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, size: 18, color: isHigh ? const Color(0xFFEF4444) : const Color(0xFFD97706)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          issue['title'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isHigh ? const Color(0xFFFEF2F2).withOpacity(isDark ? 0.1 : 1.0) : const Color(0xFFFEF3C7).withOpacity(isDark ? 0.1 : 1.0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    issue['line'].toString().toUpperCase(), // Display the category here!
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isHigh ? const Color(0xFFEF4444) : const Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Evidence: ${issue['location']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: subtitleColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              issue['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AiScreen(reportData: widget.reportData ?? globalLatestReportData)));
            } else if (index == 3) {
              Navigator.pushNamed(context, '/select_repo', arguments: true);
            } else if (index == 4) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
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
