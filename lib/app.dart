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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeAudit AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/add_repo': (context) => const AddRepositoryScreen(),
        '/select_repo': (context) => const SelectRepositoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/analyzing': (context) => const AnalyzingScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/issues': (context) => const IssuesScreen(),
        '/ai': (context) => const AiScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}