import 'package:code_audit_ai/features/repository/add_repository.dart';
import 'package:flutter/material.dart';
import 'features/onboard_pages/onboarding.dart';
import 'features/auth/login_screen.dart';
import 'features/repository/select_repository_screen.dart';
import 'features/repository/analyzing_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/issues/issues_screen.dart';
import 'features/ai/ai_screen.dart';
import 'features/history/history_screen.dart';
import 'splash_screen.dart';

class MyApp extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  const MyApp({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'CodeAudit AI',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1E293B),
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          themeMode: currentMode,
          // Very large system font sizes make fixed-size layouts (charts, chips,
          // cards) collide. Respect the user's setting but cap it app-wide.
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(
                textScaler: mq.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.15),
              ),
              child: child!,
            );
          },
          initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/add_repo': (context) => const AddRepositoryScreen(),
        '/select_repo': (context) => const SelectRepositoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/analyzing': (context) => AnalyzingScreen(
              jobId: ModalRoute.of(context)!.settings.arguments as String? ?? '',
            ),
        '/dashboard': (context) => DashboardScreen(
              jobId: ModalRoute.of(context)!.settings.arguments as String?,
            ),
        '/issues': (context) => const IssuesScreen(),
        '/ai': (context) => const AiScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
      },
    );
  }
}