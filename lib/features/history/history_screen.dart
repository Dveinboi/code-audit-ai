import 'package:flutter/material.dart';
import '../ai/ai_screen.dart';
import '../issues/issues_screen.dart';
import 'repository_detail_screen.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedTab = 'Recent';
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = ApiService.getHistorySummary();
  }

  @override
  Widget build(BuildContext context) {
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
          'History',
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    _buildTab('All', isDark, cardColor, textColor, subtitleColor),
                    _buildTab('Recent', isDark, cardColor, textColor, subtitleColor),
                    _buildTab('Favorites', isDark, cardColor, textColor, subtitleColor),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No history found.', style: TextStyle(color: subtitleColor)));
                  }

                  final historyItems = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: historyItems.length,
                    separatorBuilder: (context, index) => Divider(color: dividerColor, height: 1),
                    itemBuilder: (context, index) {
                      final item = historyItems[index];
                      final repoName = item['repo_name'] ?? 'Unknown';
                      final score = item['latest_score'] ?? 0;
                      final repoId = item['repository_id'] ?? '';
                      final scoreColor = score >= 80 ? const Color(0xFF10B981) : (score >= 50 ? Colors.orange : Colors.red);
                      final String dateStr = item['analyzed_at'] ?? '';
                      String formattedDate = 'Unknown date';
                      if (dateStr.isNotEmpty) {
                        try {
                          final date = DateTime.parse(dateStr).toLocal();
                          formattedDate = 'Analyzed on ${DateFormat('dd MMM yyyy, hh:mm a').format(date)}';
                        } catch (e) {}
                      }

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RepositoryDetailScreen(
                                repoName: repoName,
                                repositoryId: repoId,
                                score: score,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.folder,
                                  color: Colors.blue,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      repoName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${historyItems.length} Analyses', // You can change this to a real count if you group differently
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: subtitleColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: subtitleColor,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
          currentIndex: 4,
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
              // Do nothing
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

  Widget _buildTab(String title, bool isDark, Color cardColor, Color textColor, Color subtitleColor) {
    final isSelected = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? textColor : subtitleColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required String repoName,
    required String date,
    required int score,
    required Color scoreColor,
    required VoidCallback onTap,
    required Color textColor,
    required Color subtitleColor,
    required Color dividerColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 4,
                    backgroundColor: dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                Text(
                  score.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    repoName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}