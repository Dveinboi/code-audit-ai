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
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Updated with your actual asset folder path and filename
    _controller =
        VideoPlayerController.asset('assets/animations/splash_screen_ani.mp4')
          ..initialize().then((_) {
            setState(() {});
            _controller.play(); // Start playing immediately
          }).catchError((error) {
            print("Video failed to initialize: $error");
            _navigateToDashboard();
          });

    // Automatically navigate away when the 5-second video finishes playing
    _controller.addListener(() {
      if (_controller.value.isInitialized && _controller.value.position >= _controller.value.duration) {
        _navigateToDashboard();
      }
    });

    // Fallback timer: forcefully navigate after 6 seconds in case video player hangs indefinitely
    Future.delayed(const Duration(seconds: 6), () {
      _navigateToDashboard();
    });
  }

  void _navigateToDashboard() {
    if (!mounted || _navigated) return;
    _navigated = true;

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
