import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';
import '../ai/ai_screen.dart'; 
import '../history/history_screen.dart'; // Added History screen import

class IssueDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> issueData;

  const IssueDetailsScreen({Key? key, required this.issueData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111111) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final snippetBgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final snippetTextColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);

    final isHigh = issueData['severity'] == 'High';

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
          'Issue Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: dividerColor, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title & Severity Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        issueData['title'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isHigh ? const Color(0xFFFEF2F2).withOpacity(isDark ? 0.1 : 1) : const Color(0xFFFEF3C7).withOpacity(isDark ? 0.1 : 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        issueData['severity'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isHigh ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // File
                Text('File', style: TextStyle(fontSize: 13, color: subtitleColor, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  issueData['location'].split(':')[0],
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 16),

                // Line
                Text('Line', style: TextStyle(fontSize: 13, color: subtitleColor, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  issueData['line'],
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 16),

                // Description
                Text('Description', style: TextStyle(fontSize: 13, color: subtitleColor, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  issueData['description'],
                  style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569), height: 1.4),
                ),
                const SizedBox(height: 16),

                // Recommendation
                Text('Recommendation', style: TextStyle(fontSize: 13, color: subtitleColor, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  issueData['recommendation'],
                  style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569), height: 1.4),
                ),
                const SizedBox(height: 20),

                // Code Snippet Box
                Text('Code Snippet', style: TextStyle(fontSize: 13, color: subtitleColor, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: snippetBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: dividerColor),
                  ),
                  child: Text(
                    issueData['codeSnippet'],
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: snippetTextColor,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: dividerColor, width: 1.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: 1, // Issues tab selected
          onTap: (index) {
            if (index == 0) {
              Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
            } else if (index == 1) {
              // Pop back to the parent Issues screen instead of pushing a duplicate
              Navigator.pop(context);
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AiScreen()));
            } else if (index == 3) {
              Navigator.pushNamed(context, '/select_repo');
            } else if (index == 4) {
              // Updated Navigation to History screen
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
}