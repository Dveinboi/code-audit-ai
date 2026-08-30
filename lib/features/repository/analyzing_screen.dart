import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyzingScreen extends StatefulWidget {
  final String jobId;

  const AnalyzingScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  int _overallProgress = 0;
  bool _stepFetching = false;
  bool _stepCloning = false;
  bool _stepCodeAnalysis = false;
  bool _stepSecurity = false;
  bool _stepDependencies = false;
  bool _stepAiReport = false;
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    if (widget.jobId.isNotEmpty) {
      _listenToJobProgress();
    } else {
      // For UI testing when no jobId is passed
      _overallProgress = 100;
      _stepFetching = true;
      _stepCloning = true;
      _stepCodeAnalysis = true;
      _stepSecurity = true;
      _stepDependencies = true;
      _stepAiReport = true;
      _status = 'completed';
    }
  }

  void _listenToJobProgress() {
    // Listen to real-time changes on this specific analysis job
    Supabase.instance.client
        .from('analysis_jobs')
        .stream(primaryKey: ['id'])
        .eq('id', widget.jobId)
        .listen((List<Map<String, dynamic>> data) {
      if (data.isNotEmpty) {
        final job = data.first;
        
        if (mounted) {
          setState(() {
            _overallProgress = job['overall_progress'] ?? 0;
            _status = job['status'] ?? 'pending';
            
            _stepFetching = job['step_fetching'] ?? false;
            _stepCloning = job['step_cloning'] ?? false;
            _stepCodeAnalysis = job['step_code_analysis'] ?? false;
            _stepSecurity = job['step_security'] ?? false;
            _stepDependencies = job['step_dependencies'] ?? false;
            _stepAiReport = job['step_ai_report'] ?? false;
          });
        }
      }
    });
  }

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                
                Text(
                  'Analyzing Repository',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This may take a few minutes',
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor,
                  ),
                ),
                
                const SizedBox(height: 48),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: _overallProgress / 100,
                        strokeWidth: 8,
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_overallProgress%',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _status == 'completed' ? 'Completed' : (_status == 'failed' ? 'Analysis Failed' : 'Running...'),
                          style: TextStyle(
                            fontSize: 14,
                            color: _status == 'failed' ? Colors.red : subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      _buildChecklistItem('Fetching repository', _stepFetching, isDark, textColor, subtitleColor),
                      const SizedBox(height: 16),
                      _buildChecklistItem('Cloning repository', _stepCloning, isDark, textColor, subtitleColor),
                      const SizedBox(height: 16),
                      _buildChecklistItem('Running code analysis', _stepCodeAnalysis, isDark, textColor, subtitleColor),
                      const SizedBox(height: 16),
                      _buildChecklistItem('Security scanning', _stepSecurity, isDark, textColor, subtitleColor),
                      const SizedBox(height: 16),
                      _buildChecklistItem('Analyzing dependencies', _stepDependencies, isDark, textColor, subtitleColor),
                      const SizedBox(height: 16),
                      _buildChecklistItem('Generating AI report', _stepAiReport, isDark, textColor, subtitleColor),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _status == 'completed' ? () {
                      Navigator.pushNamed(
                        context, 
                        '/dashboard',
                        arguments: widget.jobId,
                      );
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _status == 'completed' 
                          ? (isDark ? const Color(0xFF1E293B) : Colors.black)
                          : (isDark ? const Color(0xFF334155) : Colors.grey),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Go to Dashboard',
                          style: TextStyle(
                            color: _status == 'completed' ? Colors.white : (isDark ? const Color(0xFF94A3B8) : Colors.white70),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: _status == 'completed' ? Colors.white : (isDark ? const Color(0xFF94A3B8) : Colors.white70),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String title, bool isCompleted, bool isDark, Color textColor, Color subtitleColor) {
    return Row(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.circle_outlined,
          color: isCompleted ? const Color(0xFF10B981) : subtitleColor,
          size: 22,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
          ),
        ),
        const Spacer(),
        Text(
          isCompleted ? 'Completed' : 'Pending',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isCompleted ? const Color(0xFF10B981) : subtitleColor,
          ),
        ),
      ],
    );
  }
}