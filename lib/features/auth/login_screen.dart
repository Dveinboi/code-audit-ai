import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'github_login_webview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget { // Converted to StatefulWidget to handle loading state
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      final user = session?.user;
      
      // Save provider token to SharedPreferences so it persists across app hot-restarts
      if (session?.providerToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('github_provider_token', session!.providerToken!);
      }
      
      if (session != null && user != null) {
        try {
          // Force store/update the user in the database every time they log in
          await Supabase.instance.client.from('users').upsert({
            'id': user.id,
            'email': user.email ?? '',
            'full_name': user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'Unknown',
            'avatar_url': user.userMetadata?['avatar_url'] ?? '',
          });

          // Link guest account if one exists
          final prefs = await SharedPreferences.getInstance();
          final guestId = prefs.getString('guest_user_id');
          if (guestId != null) {
            await ApiService.linkGuestAccount(guestId, user.id);
            await prefs.remove('guest_user_id'); // Clear it after linking
          }
        } catch (e) {
          debugPrint('Failed to save user to database: $e');
        }
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/select_repo');
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  // Supabase GitHub Sign In implementation
  Future<void> signInWithGitHub() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance;
      
      // Get the sign in URL without launching the browser automatically
      final authResponse = await supabase.client.auth.getOAuthSignInUrl(
        provider: OAuthProvider.github,
        redirectTo: 'io.supabase.codeaudit://login-callback',
        scopes: 'repo read:user',
      );

      if (mounted) {
        // Open our custom isolated WebView
        final returnedUrl = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => GithubLoginWebview(
              authUrl: authResponse.url,
              redirectScheme: 'io.supabase.codeaudit://',
            ),
          ),
        );

        // If the user didn't cancel and we got the redirect URL back
        if (returnedUrl != null) {
          // Hand the URL over to Supabase to complete the login
          await supabase.client.auth.getSessionFromUrl(Uri.parse(returnedUrl));
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
    final dividerColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;
    final githubButtonColor = isDark ? const Color(0xFF1E293B) : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Left Logo Icon (Nudged to the left)
              Align(
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: const Offset(-12, 0),
                  child: Image.asset(
                    'assets/images/logo.png', 
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              
              const Spacer(),

              // Headings
              Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Analyze any GitHub repository\nin a few clicks.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: subtitleColor,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 48),

             // GitHub Button
             SizedBox(
               width: double.infinity,
               height: 54,
               child: ElevatedButton(
                 onPressed: _isLoading ? null : signInWithGitHub, // Calls Supabase auth workflow
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
             const SizedBox(height: 24),

              // "or" Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(color: dividerColor, thickness: 1.5),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: subtitleColor, 
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: dividerColor, thickness: 1.5),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Paste URL Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add_repo');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: dividerColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Paste repository URL',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}