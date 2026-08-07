import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'features/onboard_pages/onboarding.dart'; // Connected to onboarding

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Updated with your actual asset folder path and filename
    _controller =
        VideoPlayerController.asset('assets/animations/splash_screen_ani.mp4')
          ..initialize().then((_) {
            setState(() {});
            _controller.play(); // Start playing immediately
          });

    // Automatically navigate away when the 5-second video finishes playing
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        _navigateToDashboard();
      }
    });
  }

  void _navigateToDashboard() {
    if (!mounted) return;

    // Replace SplashScreen with OnboardingScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up memory
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF1C1C1E,
      ), // Matches your dark charcoal background
      body: Center(
        child: _controller.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit
                      .cover, // Fills the screen cleanly without distortion
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : const SizedBox.shrink(), // Keeps it clean and dark while video buffers (no default white loader)
      ),
    );
  }
}
