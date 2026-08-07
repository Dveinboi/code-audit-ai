import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // PageView takes up the main screen space dynamically
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  // PAGE 1
                  _buildOnboardingPage(
                    imagePath: 'assets/images/logo.svg', // Or logo.svg if using SVG
                    isSvg: true, // Change to true if using logo.svg
                    titleBlack1: 'Code',
                    titleGreen: 'Audit',
                    titleBlack2: '',
                    subtitle: 'AI Powered GitRepo Analyzer\n\nAnalyze. Understand. Improve.',
                  ),
                  // PAGE 2
                  _buildOnboardingPage(
                    imagePath: 'assets/images/onboard2.svg',
                    isSvg: true,
                    titleBlack1: 'Smart Insights,\nClear ',
                    titleGreen: 'Actions',
                    titleBlack2: '',
                    subtitle: 'Code Audit analyzes your code\nand provides actionable insights\nto help you improve quality,\nsecurity and performance.',
                  ),
                  // PAGE 3
                  _buildOnboardingPage(
                    imagePath: 'assets/images/onboard3.svg',
                    isSvg: true,
                    titleBlack1: 'You\'re ',
                    titleGreen: 'All Set!',
                    titleBlack2: '',
                    subtitle: 'Let\'s analyze your first repository\nand discover how Code Audit\ncan make your projects better.',
                  ),
                ],
              ),
            ),
            
            // Bottom Section: Centered dots and Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Centered Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => _buildIndicator(isActive: index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Next / Get Started Button
                  SizedBox(
                    width: double.infinity, // Button takes full width for a modern look
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == 2) {
                          // Navigate to Login on the last page
                          Navigator.pushReplacementNamed(context, '/login');
                        } else {
                          // Slide to the next page
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 13, 14, 13), // Emerald Green
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == 2 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Dynamic widget builder for each page's layout
  Widget _buildOnboardingPage({
    required String imagePath,
    required bool isSvg,
    required String titleBlack1,
    required String titleGreen,
    required String titleBlack2,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          // TOP SECTION: The Image (Locked in place)
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.bottomCenter, // Aligns all images to the same baseline
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // The Green Glow Effect
                  Container(
                    width: 150, 
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          blurRadius: 80, 
                          spreadRadius: 20, 
                        ),
                      ],
                    ),
                  ),
                  
                  // The SVG Image (Forced to a consistent maximum height)
                  SizedBox(
                    height: 200, 
                    child: isSvg
                        ? SvgPicture.asset(
                            imagePath,
                            fit: BoxFit.contain,
                          )
                        : Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 48), // Strict spacing between image and text
          
          // BOTTOM SECTION: The Text (Grows downward, never pushes the image up)
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Keeps text anchored to the top of this section
              children: [
                // Dynamic RichText for the title formatting
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto', 
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(
                        text: titleBlack1,
                        style: const TextStyle(color: Color(0xFF1E293B)), 
                      ),
                      TextSpan(
                        text: titleGreen,
                        style: const TextStyle(color: Color(0xFF10B981)), 
                      ),
                      TextSpan(
                        text: titleBlack2,
                        style: const TextStyle(color: Color(0xFF1E293B)), 
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Subtitle text
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // Helper widget for the indicator lines
  Widget _buildIndicator({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 4,
      width: isActive ? 24 : 12, // Active dot is wider
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}