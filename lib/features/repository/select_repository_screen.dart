import 'package:flutter/material.dart';

class SelectRepositoryScreen extends StatefulWidget {
  const SelectRepositoryScreen({Key? key}) : super(key: key);

  @override
  State<SelectRepositoryScreen> createState() => _SelectRepositoryScreenState();
}

class _SelectRepositoryScreenState extends State<SelectRepositoryScreen> {
  // Dummy data simulating GitHub API response
  final List<Map<String, String>> dummyRepos = [
    {
      'name': 'codeaudit-mobile-app',
      'url': 'https://github.com/user/codeaudit-mobile-app',
      'lang': 'Dart',
      'visibility': 'Private',
      'updated': '2 hours ago',
    },
    {
      'name': 'backend-api-service',
      'url': 'https://github.com/user/backend-api-service',
      'lang': 'Python',
      'visibility': 'Private',
      'updated': '5 hours ago',
    },
    {
      'name': 'portfolio-website',
      'url': 'https://github.com/user/portfolio-website',
      'lang': 'TypeScript',
      'visibility': 'Public',
      'updated': '1 day ago',
    },
    {
      'name': 'flutter-ui-components',
      'url': 'https://github.com/user/flutter-ui-components',
      'lang': 'Dart',
      'visibility': 'Public',
      'updated': '3 days ago',
    },
  ];

  int? _selectedIndex;

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

            // Repository List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                physics: const BouncingScrollPhysics(),
                itemCount: dummyRepos.length,
                itemBuilder: (context, index) {
                  final repo = dummyRepos[index];
                  final isSelected = _selectedIndex == index;

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
                                  repo['name']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? const Color(0xFF065F46) : const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _buildBadge(repo['visibility']!),
                                    const SizedBox(width: 8),
                                    _buildBadge(repo['lang']!),
                                    const Spacer(),
                                    Text(
                                      repo['updated']!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
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
                          // Pass the selected URL to the Add Repository Screen
                          final selectedUrl = dummyRepos[_selectedIndex!]['url'];
                          Navigator.pushNamed(
                            context,
                            '/add_repo',
                            arguments: selectedUrl,
                          );
                        }
                      : null, // Disabled if nothing is selected
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

  // Small UI helper for the badges (Private/Public, Dart/Python)
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