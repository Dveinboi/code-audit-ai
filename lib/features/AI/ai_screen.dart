import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';
import '../issues/issues_screen.dart';
import '../history/history_screen.dart'; // Added History screen import

class AiScreen extends StatelessWidget {
  const AiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Added the Back Arrow Button here
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () {
            // Pops all screens to return directly to the Overview (Dashboard)
            Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
            
            // Note: If you haven't set up named routes and want a simpler fallback,
            // you can replace the line above with: Navigator.pop(context);
          },
        ),
        title: const Text(
          'AI Recommendations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'The repository has security vulnerabilities and code quality issues that should be addressed to improve the overall score.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Top Recommendations Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Recommendations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecommendationItem(
                      number: '1',
                      text: 'Fix 2 high severity security issues',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Divider(color: Color(0xFFF1F5F9), height: 1),
                    ),
                    _buildRecommendationItem(
                      number: '2',
                      text: 'Update 3 outdated dependencies',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Divider(color: Color(0xFFF1F5F9), height: 1),
                    ),
                    _buildRecommendationItem(
                      number: '3',
                      text: 'Reduce code complexity in high-risk functions',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Divider(color: Color(0xFFF1F5F9), height: 1),
                    ),
                    _buildRecommendationItem(
                      number: '4',
                      text: 'Add input validation for user facing forms',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: 2, // 'AI' tab selected
          onTap: (index) {
            if (index == 0) {
              Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
            } else if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const IssuesScreen())); 
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

  // Helper widget to build the numbered recommendation rows
  Widget _buildRecommendationItem({required String number, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          // Circular Number Badge
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Recommendation Text
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Chevron Icon
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: Color(0xFFCBD5E1),
          ),
        ],
      ),
    );
  }
}