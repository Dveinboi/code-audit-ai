import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddRepositoryScreen extends StatefulWidget {
  const AddRepositoryScreen({Key? key}) : super(key: key);

  @override
  State<AddRepositoryScreen> createState() => _AddRepositoryScreenState();
}

class _AddRepositoryScreenState extends State<AddRepositoryScreen> {
  // State variables for the toggle switches (all default to true/ON)
  bool _securityEnabled = true;
  bool _qualityEnabled = true;
  bool _performanceEnabled = true;
  bool _maintainabilityEnabled = true;
  bool _dependenciesEnabled = true;
  late TextEditingController _urlController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Catch the URL if it was passed from the Select Repo screen
    final passedUrl = ModalRoute.of(context)?.settings.arguments as String?;
    if (passedUrl != null) {
      _urlController.text = passedUrl;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    if (_urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a repository URL')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Ask which branch to analyze (skipped when the repo has only one).
      final branches = await ApiService.getBranches(_urlController.text.trim());
      String? branch = branches.isNotEmpty ? branches.first : null;
      if (branches.length > 1) {
        if (!mounted) return;
        branch = await _pickBranch(branches);
        if (branch == null) return; // user closed the picker
      }

      // 2. Start the analysis on that branch.
      final jobId = await ApiService.startAnalysis(
        _urlController.text.trim(),
        security: _securityEnabled,
        quality: _qualityEnabled,
        performance: _performanceEnabled,
        maintainability: _maintainabilityEnabled,
        dependencies: _dependenciesEnabled,
        branch: branch,
      );

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
          SnackBar(content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Bottom sheet listing the repo's branches; the default branch is first.
  Future<String?> _pickBranch(List<String> branches) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 4),
                child: Text(
                  'Which branch should be analyzed?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  'The latest commit on that branch will be scanned.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: branches.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, i) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: const Icon(Icons.call_split, color: Color(0xFF64748B)),
                    title: Text(
                      branches[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                    trailing: i == 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('default',
                                style: TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                          )
                        : null,
                    onTap: () => Navigator.pop(context, branches[i]),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () {
            Navigator.pop(context); // Goes back to the Login Screen
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              
              // Headings
              const Text(
                'Add Repository',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter a GitHub repository URL',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
              
              const SizedBox(height: 24),

              // URL Input Field
              TextField(
                controller: _urlController,
                style: const TextStyle(color: Colors.black), // Added this line to make text visible!
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.smart_toy_outlined, color: Color(0xFF94A3B8)),
                  hintText: 'https://github.com/user/repo',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Analysis Options Heading
              const Text(
                'Analysis Options',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),

              // Toggle List
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildOptionRow(
                      icon: Icons.shield_outlined,
                      title: 'Security Analysis',
                      value: _securityEnabled,
                      onChanged: (val) => setState(() => _securityEnabled = val),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildOptionRow(
                      icon: Icons.verified_outlined,
                      title: 'Code Quality',
                      value: _qualityEnabled,
                      onChanged: (val) => setState(() => _qualityEnabled = val),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildOptionRow(
                      icon: Icons.speed_outlined,
                      title: 'Performance',
                      value: _performanceEnabled,
                      onChanged: (val) => setState(() => _performanceEnabled = val),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildOptionRow(
                      icon: Icons.build_outlined,
                      title: 'Maintainability',
                      value: _maintainabilityEnabled,
                      onChanged: (val) => setState(() => _maintainabilityEnabled = val),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildOptionRow(
                      icon: Icons.extension_outlined,
                      title: 'Dependencies',
                      value: _dependenciesEnabled,
                      onChanged: (val) => setState(() => _dependenciesEnabled = val),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ],
                ),
              ),

              // Start Analysis Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _startAnalysis,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Dark Slate Gray
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Start Analysis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
// Helper widget to build each toggle row cleanly
  Widget _buildOptionRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
          // Wrap the Switch in Transform.scale to make it smaller
          Transform.scale(
            scale: 0.75, // Adjust this number! (1.0 is default size, 0.5 is half size)
            alignment: Alignment.centerRight, // Keeps it aligned to the right edge
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white, 
              activeTrackColor: const Color(0xFF10B981), 
            ),
          ),
        ],
      ),
    );
  }
}

 