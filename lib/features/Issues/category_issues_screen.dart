import 'package:flutter/material.dart';
import '../ai/ai_screen.dart';
import '../history/history_screen.dart';
import '../issues/issue_details_screen.dart';
import '../issues/issues_screen.dart';

class CategoryIssuesScreen extends StatelessWidget {
  final String categoryName;
  final String score;
  final Color scoreColor;
  final List<Map<String, dynamic>> categoryIssues;

  const CategoryIssuesScreen({
    Key? key,
    required this.categoryName,
    required this.score,
    required this.scoreColor,
    required this.categoryIssues,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF111111) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$categoryName Details',
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$categoryName Score',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Evaluated from recent code scans',
                            style: TextStyle(fontSize: 13, color: subtitleColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          score,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                        Text(
                          ' /100',
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
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Related Issues',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: categoryIssues.isEmpty
                  ? Center(
                      child: Text(
                        'No issues found in this category!',
                        style: TextStyle(color: subtitleColor, fontSize: 15),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: categoryIssues.length,
                      itemBuilder: (context, index) {
                        final issue = categoryIssues[index];
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
                                  builder: (context) {
                                    final mappedIssue = {
                                      'title': issue['title'] ?? 'Unknown Issue',
                                      'severity': issue['severity'] ?? 'Medium',
                                      'location': issue['evidence'] ?? issue['location'] ?? 'Unknown Location',
                                      'description': issue['impact'] ?? issue['description'] ?? 'No description specified',
                                      'recommendation': issue['recommendation'] ?? 'No recommendation',
                                      'codeSnippet': issue['priority'] != null ? 'Priority: ${issue['priority']}\nConfidence: ${issue['confidence']}' : 'No code snippet provided.',
                                      'line': issue['category'] ?? issue['line'] ?? 'General',
                                    };
                                    return IssueDetailsScreen(issueData: mappedIssue);
                                  },
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
                                            const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFFEF4444)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                issue['title']?.toString() ?? 'Unknown Issue',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                                maxLines: 2,
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
                                          issue['severity']?.toString() ?? 'Medium',
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
                                    'File: ${issue['evidence']?.toString() ?? issue['location']?.toString() ?? 'Unknown location'}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: subtitleColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    issue['impact']?.toString() ?? issue['description']?.toString() ?? 'No description provided',
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
    );
  }
}