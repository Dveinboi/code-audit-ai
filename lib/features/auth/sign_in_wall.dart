import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'github_login_webview.dart';
import '../../services/api_service.dart';

class SignInWallWidget extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;

  const SignInWallWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
  }) : super(key: key);

  @override
  State<SignInWallWidget> createState() => _SignInWallWidgetState();
}

class _SignInWallWidgetState extends State<SignInWallWidget> {
  bool _isLoading = false;

  Future<void> _signInWithGitHub() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance;
      
      final authResponse = await supabase.client.auth.getOAuthSignInUrl(
        provider: OAuthProvider.github,
        redirectTo: 'io.supabase.codeaudit://login-callback',
        scopes: 'repo read:user',
      );

      if (mounted) {
        final returnedUrl = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => GithubLoginWebview(
              authUrl: authResponse.url,
              redirectScheme: 'io.supabase.codeaudit://',
            ),
          ),
        );

        if (returnedUrl != null) {
          await supabase.client.auth.getSessionFromUrl(Uri.parse(returnedUrl));
          
          final session = Supabase.instance.client.auth.currentSession;
          final user = session?.user;
          
          if (session?.providerToken != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('github_provider_token', session!.providerToken!);
          }
          
          if (session != null && user != null) {
            try {
              await Supabase.instance.client.from('users').upsert({
                'id': user.id,
                'email': user.email ?? '',
                'full_name': user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'Unknown',
                'avatar_url': user.userMetadata?['avatar_url'] ?? '',
              });

              final prefs = await SharedPreferences.getInstance();
              final guestId = prefs.getString('guest_user_id');
              if (guestId != null) {
                await ApiService.linkGuestAccount(guestId, user.id);
                await prefs.remove('guest_user_id');
              }
            } catch (e) {
              debugPrint('Failed to save user to database: $e');
            }
            
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error logging in with GitHub: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111111) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final githubButtonColor = isDark ? const Color(0xFF1E293B) : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 80, color: const Color(0xFF10B981).withOpacity(0.8)),
              const SizedBox(height: 32),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: subtitleColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signInWithGitHub,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: githubButtonColor, 
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      else ...[
                        const FaIcon(
                          FontAwesomeIcons.github,
                          color: Colors.white,
                          size: 24,
                        ), 
                        const SizedBox(width: 12),
                      ],
                      const Text(
                        'Continue with GitHub',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
