import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SelectRepositoryScreen extends StatefulWidget {
  const SelectRepositoryScreen({Key? key}) : super(key: key);

  @override
  State<SelectRepositoryScreen> createState() => _SelectRepositoryScreenState();
}

class _SelectRepositoryScreenState extends State<SelectRepositoryScreen> {
  late Future<List<dynamic>> _repositoriesFuture;
  int? _selectedIndex;
  List<dynamic> _reposCache = [];

  @override
  void initState() {
    super.initState();
    _repositoriesFuture = fetchUserRepositories();
  }

  // Fetch real public and private repositories using Supabase session token
  Future<List<dynamic>> fetchUserRepositories() async {
    final session = Supabase.instance.client.auth.currentSession;
    String? accessToken = session?.providerToken;

    if (accessToken == null) {
      final prefs = await SharedPreferences.getInstance();
      accessToken = prefs.getString('github_provider_token');
    }

    if (accessToken == null) {
      // Fallback: Fetch public repositories for the username if token is lost after restart
      final user = Supabase.instance.client.auth.currentUser;
      final metadata = user?.userMetadata ?? {};
      final userName = metadata['preferred_username'] ?? metadata['user_name'];
      
      if (userName != null) {
        final response = await http.get(
          Uri.parse('https://api.github.com/users/$userName/repos?sort=updated'),
          headers: {'Accept': 'application/vnd.github+json'},
        );
        if (response.statusCode == 200) {
          List<dynamic> repos = jsonDecode(response.body);
          _reposCache = repos;
          return repos;
        }
      }
      
      // If even the username is unavailable, use mock demo repos
      final mockRepos = [
        {'name': 'broke_no_more', 'html_url': 'https://github.com/demo/broke_no_more', 'private': true, 'language': 'Dart'},
        {'name': 'ecommerce_app', 'html_url': 'https://github.com/demo/ecommerce_app', 'private': false, 'language': 'Flutter'},
        {'name': 'backend_api', 'html_url': 'https://github.com/demo/backend_api', 'private': true, 'language': 'Python'}
      ];
      _reposCache = mockRepos;
      return mockRepos;
    }

    final response = await http.get(
      Uri.parse('https://api.github.com/user/repos?visibility=all&sort=updated'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> repos = jsonDecode(response.body);
      _reposCache = repos; // Cache for selection reference
      return repos;
    } else {
      throw Exception('Failed to load repositories: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final showNavbar = ModalRoute.of(context)?.settings.arguments as bool? ?? false;
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
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Repository',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a project to analyze from your connected GitHub account.',
                    style: TextStyle(
                      fontSize: 16,
                      color: subtitleColor,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _repositoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF10B981)),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Error loading repositories:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No repositories found.',
                        style: TextStyle(color: subtitleColor),
                      ),
                    );
                  }

                  final repos = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    physics: const BouncingScrollPhysics(),
                    itemCount: repos.length,
                    itemBuilder: (context, index) {
                      final repo = repos[index];
                      final isSelected = _selectedIndex == index;

                      final repoName = repo['name'] ?? 'Unnamed';
                      final repoUrl = repo['html_url'] ?? '';
                      final isPrivate = repo['private'] ?? false;
                      final language = repo['language'] ?? 'Mixed';

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 16.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? (isDark ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFECFDF5))
                                : cardColor,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF10B981) : borderColor,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.folder_outlined,
                                color: isSelected ? const Color(0xFF10B981) : subtitleColor,
                                size: 28,
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
                                        fontWeight: FontWeight.w600,
                                        color: isSelected 
                                            ? (isDark ? const Color(0xFF34D399) : const Color(0xFF065F46))
                                            : textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _buildBadge(isPrivate ? 'Private' : 'Public', isDark, subtitleColor),
                                        const SizedBox(width: 8),
                                        _buildBadge(language, isDark, subtitleColor),
                                      ],
                                    ),
                                  ],
                                ),
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

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _selectedIndex != null
                          ? () {
                              final selectedRepo = _reposCache[_selectedIndex!];
                              final selectedUrl = selectedRepo['html_url'];
                              Navigator.pushNamed(
                                context,
                                '/add_repo',
                                arguments: selectedUrl,
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.black,
                        disabledBackgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirm Selection',
                        style: TextStyle(
                          color: _selectedIndex != null ? Colors.white : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (!showNavbar) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      },
                      child: Text(
                        'Skip for now',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: showNavbar ? Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), width: 1.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: 3,
          onTap: (index) {
            if (index == 0) {
              Navigator.pop(context); // Go back to dashboard
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/issues');
            } else if (index == 2) {
              Navigator.pushReplacementNamed(context, '/ai');
            } else if (index == 3) {
              // Already on select repo
            } else if (index == 4) {
              Navigator.pushReplacementNamed(context, '/history');
            }
          },
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
      ) : null,
    );
  }

  Widget _buildBadge(String text, bool isDark, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
        ),
      ),
    );
  }
}