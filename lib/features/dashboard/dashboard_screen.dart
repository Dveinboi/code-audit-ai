import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Issues/issues_screen.dart';
import '../profile/profile_screen.dart';
import '../ai/ai_screen.dart';
import '../history/history_screen.dart';
import '../issues/category_issues_screen.dart';
import '../../services/api_service.dart';
import '../../services/pdf_report_service.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../auth/sign_in_wall.dart';

class DashboardScreen extends StatefulWidget {
  final String? jobId;
  final bool isLoggedInWithGithub;

  const DashboardScreen({
    Key? key,
    this.jobId,
    this.isLoggedInWithGithub = true,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentBottomNavIndex = 0;
  
  bool _isLoading = true;
  String _repoName = 'Loading...';
  String _avatarUrl = '';
  String? _repoUrl;
  bool _isReanalyzing = false;
  bool _isGeneratingPdf = false;
  
  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      // 1. Get Avatar
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && session.user.userMetadata != null) {
        _avatarUrl = session.user.userMetadata!['avatar_url'] ?? '';
      }

      // 2. Get Report
      String? activeJobId = widget.jobId;
      
      if (activeJobId == null) {
        // Fetch the most recent report 
        final latestReport = await Supabase.instance.client
            .from('reports')
            .select('job_id')
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
            
        if (latestReport != null) {
          activeJobId = latestReport['job_id'];
        }
      }

      if (activeJobId != null) {
        Map<String, dynamic>? reportResponse = await Supabase.instance.client
            .from('reports')
            .select('*')
            .eq('job_id', activeJobId)
            .maybeSingle();
            
        if (reportResponse == null) {
          // If RLS blocked it (guest report), fetch from backend
          reportResponse = await ApiService.getReportByJobId(activeJobId);
        }
            
        _reportData = reportResponse;
        if (mounted) {
          context.read<ReportProvider>().setReportData(reportResponse); // Store globally
        }
        
        // 3. Get Repo Name
        if (reportResponse != null) {
          final repoId = reportResponse['repository_id'];
          if (repoId != null) {
            final repoResponse = await Supabase.instance.client
                .from('repositories')
                .select('*')
                .eq('id', repoId)
                .maybeSingle();
            
            if (repoResponse != null) {
              _repoName = repoResponse['repo_name'] ?? 'Unknown Repository';
              _repoUrl = repoResponse['repo_url'];
            } else {
              _repoName = 'Repository not found';
            }
          }
        } else {
          _repoName = 'Report not generated yet';
        }
      } else {
        _repoName = 'No Job Selected';
      }
      
    } catch (e) {
      print("Error fetching dashboard data: $e");
      _repoName = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onBottomNavTapped(int index) {
    final isGuest = Supabase.instance.client.auth.currentSession == null;
    
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const IssuesScreen()));
      return;
    }
    if (index == 2) {
      if (isGuest) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInWallWidget(
          title: 'Sign in to unlock AI',
          description: 'Get deep insights and chat with our AI assistant about your repository.',
          icon: Icons.auto_awesome,
        )));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AiScreen()));
      }
      return;
    }
    if (index == 3) {
      if (isGuest) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInWallWidget(
          title: 'Sign in to add repositories',
          description: 'Create an account to analyze multiple repositories and save your history.',
          icon: Icons.add_circle,
        )));
      } else {
        Navigator.pushNamed(context, '/select_repo', arguments: true);
      }
      return;
    }
    if (index == 4) {
      if (isGuest) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInWallWidget(
          title: 'Sign in to view history',
          description: 'Track your repository scores over time and access past analyses.',
          icon: Icons.history,
        )));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
      }
      return;
    }
    setState(() {
      _currentBottomNavIndex = index;
    });
  }

  Color _getScoreColor(int? score) {
    if (score == null) return Colors.grey;
    if (score >= 90) return const Color(0xFF10B981); // Emerald
    if (score >= 70) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
  }

  String _getScoreRating(int score) {
    if (score >= 80) return 'Good';
    if (score >= 60) return 'Needs Work';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    final overallScore = _reportData?['overall_score'] ?? 0;
    final scoreColor = _getScoreColor(overallScore);

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
        automaticallyImplyLeading: false,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  final isGuest = Supabase.instance.client.auth.currentSession == null;
                  if (isGuest) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInWallWidget(
                          title: 'Sign in to your profile',
                          description: 'Save your settings, manage your repositories, and access all features.',
                          icon: Icons.person,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFF1E293B),
                  backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                  child: _avatarUrl.isEmpty ? const Icon(Icons.person, size: 20, color: Colors.white) : null,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  _repoName.split('/').last,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
        : SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: Column(
              children: [
                Text(
                  'Overall Score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 24),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: overallScore / 100, 
                        strokeWidth: 10,
                        backgroundColor: dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$overallScore',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          '/100',
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
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: (_reportData?['quality_gate'] == 'FAIL' || _reportData?['quality_gate'] == 'CRITICAL') 
                        ? Colors.red.withOpacity(0.1) 
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (_reportData?['quality_gate'] == 'FAIL' || _reportData?['quality_gate'] == 'CRITICAL') 
                        ? Colors.red.withOpacity(0.5) 
                        : Colors.green.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    'QUALITY GATE: ${_reportData?['quality_gate'] ?? 'UNKNOWN'}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: (_reportData?['quality_gate'] == 'FAIL' || _reportData?['quality_gate'] == 'CRITICAL') 
                        ? Colors.red 
                        : Colors.green,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildMetricCard(
                        icon: Icons.shield_outlined,
                        title: 'Security',
                        score: _reportData?['score_security'],
                        issues: _reportData?['detailed_findings']?.where((i) => i['category']?.toString().toLowerCase() == 'security' || i['line']?.toString().toLowerCase() == 'security').toList() ?? [],
                        category: 'Security',
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: subtitleColor,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        icon: Icons.account_tree_outlined,
                        title: 'Quality',
                        score: _reportData?['score_quality'],
                        issues: _reportData?['detailed_findings']?.where((i) => i['category']?.toString().toLowerCase() == 'quality' || i['line']?.toString().toLowerCase() == 'quality').toList() ?? [],
                        category: 'Quality',
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: subtitleColor,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        icon: Icons.speed_outlined,
                        title: 'Performance',
                        score: _reportData?['score_performance'],
                        issues: _reportData?['detailed_findings']?.where((i) => i['category']?.toString().toLowerCase() == 'performance' || i['line']?.toString().toLowerCase() == 'performance').toList() ?? [],
                        category: 'Performance',
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: subtitleColor,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        icon: Icons.build_outlined,
                        title: 'Maintainability',
                        score: _reportData?['score_maintainability'],
                        issues: _reportData?['detailed_findings']?.where((i) => i['category']?.toString().toLowerCase() == 'maintainability' || i['line']?.toString().toLowerCase() == 'maintainability').toList() ?? [],
                        category: 'Maintainability',
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: subtitleColor,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        icon: Icons.api_outlined,
                        title: 'Dependencies',
                        score: _reportData?['score_dependencies'],
                        issues: _reportData?['detailed_findings']?.where((i) => i['category']?.toString().toLowerCase() == 'dependencies' || i['line']?.toString().toLowerCase() == 'dependencies').toList() ?? [],
                        category: 'Dependencies',
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: subtitleColor,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        icon: Icons.architecture_outlined,
                        title: 'Architecture',
                        score: _reportData?['score_architecture'],
                        issues: _reportData?['detailed_findings']?.where((i) => i['category']?.toString().toLowerCase() == 'architecture' || i['line']?.toString().toLowerCase() == 'architecture').toList() ?? [],
                        category: 'Architecture',
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: subtitleColor,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        icon: Icons.science_outlined,
                        title: 'Testing',
                        score: _reportData?['score_testing'],
                        issues: _reportData?['detailed_findings']?.where((i) => i['category']?.toString().toLowerCase() == 'testing' || i['line']?.toString().toLowerCase() == 'testing').toList() ?? [],
                        category: 'Testing',
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: subtitleColor,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        icon: Icons.design_services_outlined,
                        title: 'UX / UI',
                        score: _reportData?['score_ux'],
                        issues: _reportData?['detailed_findings']?.where((i) => i['category']?.toString().toLowerCase() == 'ux/ui' || i['category']?.toString().toLowerCase() == 'ux' || i['line']?.toString().toLowerCase() == 'ux').toList() ?? [],
                        category: 'UX/UI',
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: subtitleColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _reportData?['ai_summary'] ?? 'No AI Summary generated.',
                        style: TextStyle(
                          fontSize: 14,
                          color: subtitleColor,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isGeneratingPdf || _reportData == null ? null : () async {
                      setState(() {
                        _isGeneratingPdf = true;
                      });
                      try {
                        await PdfReportService.generateAndSaveReport(_reportData, _repoName);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('PDF generated successfully!')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error generating PDF: $e')),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isGeneratingPdf = false;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : const Color(0xFF1E293B), 
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _isGeneratingPdf 
                      ? SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.black : Colors.white)
                        )
                      : const Icon(Icons.picture_as_pdf_outlined, size: 20),
                    label: Text(
                      _isGeneratingPdf ? 'Generating...' : 'Generate PDF Report',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _isReanalyzing || _repoUrl == null ? null : () async {
                      setState(() {
                        _isReanalyzing = true;
                      });
                      try {
                        final jobId = await ApiService.startAnalysis(_repoUrl!);
                        if (mounted) {
                          Navigator.pushNamed(
                            context,
                            '/analyzing',
                            arguments: jobId,
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isReanalyzing = false;
                          });
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
                      side: BorderSide(color: borderColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _isReanalyzing 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2)
                        )
                      : const Icon(Icons.refresh, size: 20),
                    label: Text(
                      _isReanalyzing ? 'Analyzing...' : 'Re-Analyze Latest Code',
                      style: const TextStyle(
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

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: dividerColor, width: 1.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentBottomNavIndex,
          onTap: _onBottomNavTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: bgColor,
          elevation: 0,
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: subtitleColor,
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

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required int? score,
    required List<dynamic> issues,
    required String category,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
  }) {
    final scoreColor = _getScoreColor(score);
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryIssuesScreen(
              categoryName: category,
              score: score.toString(),
              scoreColor: scoreColor,
              categoryIssues: issues.map((e) => e as Map<String, dynamic>).toList(),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 105,
        height: 125,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: textColor, size: 22),
            Text(
              title,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (score == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'N/A',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              Text(
                score.toString(),
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
