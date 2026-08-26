import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    _controller =
        VideoPlayerController.asset('assets/animations/splash_screen_ani.mp4')
          ..initialize().then((_) {
            setState(() {});
            _controller.play();
            
            // Dynamically read exact video duration and set strict timer
            final duration = _controller.value.duration;
            Future.delayed(duration, () {
              _navigateToNextScreen();
            });
          }).catchError((error) {
            print("Video failed to initialize: $error");
            _navigateToNextScreen();
          });

    // Fallback timer: forcefully navigate after 8 seconds in case video player hangs indefinitely
    Future.delayed(const Duration(seconds: 8), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() async {
    if (!mounted || _navigated) return;
    _navigated = true;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    final session = Supabase.instance.client.auth.currentSession;

    if (!mounted) return;

    if (session != null) {
      // Already logged in - skip onboarding entirely
      await prefs.setBool('has_seen_onboarding', true); 
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else if (hasSeenOnboarding) {
      // Seen onboarding, but not logged in
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      // Brand new user
      await prefs.setBool('has_seen_onboarding', true);
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Center(
        child: _controller.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
