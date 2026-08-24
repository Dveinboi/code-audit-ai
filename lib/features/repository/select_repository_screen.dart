import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final accessToken = session?.providerToken;

    if (accessToken == null) {
      throw Exception('No GitHub provider token found. User might not be authenticated properly.');
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Force Logout',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Repository',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose a project to analyze from your connected GitHub account.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Repository List FutureBuilder
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
                    return const Center(
                      child: Text(
                        'No repositories found.',
                        style: TextStyle(color: Color(0xFF64748B)),
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
                            color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // GitHub Icon
                              Icon(
                                Icons.folder_outlined,
                                color: isSelected ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                size: 28,
                              ),
                              const SizedBox(width: 16),
                              
                              // Repo Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      repoName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? const Color(0xFF065F46) : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _buildBadge(isPrivate ? 'Private' : 'Public'),
                                        const SizedBox(width: 8),
                                        _buildBadge(language),
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

            // Bottom Confirm Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
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
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Confirm Selection',
                    style: TextStyle(
                      color: _selectedIndex != null ? Colors.white : const Color(0xFF94A3B8),
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
    );
  }

  // Small UI helper for the badges (Private/Public, Language)
  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF475569),
        ),
      ),
    );
  }
}