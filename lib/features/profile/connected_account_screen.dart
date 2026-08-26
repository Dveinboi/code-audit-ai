import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme_provider.dart'; 

class ConnectedAccountScreen extends StatelessWidget {
  const ConnectedAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? {};
    final email = user?.email ?? metadata['email'] ?? 'Unknown Email';
    final userId = user?.id ?? 'Unknown ID';
    final userName = metadata['preferred_username'] ?? metadata['user_name'] ?? 'Unknown Username';

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
        final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
        final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final bgColor = Theme.of(context).scaffoldBackgroundColor;
        final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Connected Account',
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: bold),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      FaIcon(FontAwesomeIcons.github, size: 64, color: textColor),
                      const SizedBox(height: 16),
                      Text(
                        'GitHub',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
                            SizedBox(width: 6),
                            Text(
                              'Status: Connected',
                              style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('Account Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 16),
                _buildDetailRow('Username', userName, textColor, subtitleColor),
                const SizedBox(height: 16),
                _buildDetailRow('Email', email, textColor, subtitleColor),
                const SizedBox(height: 16),
                _buildDetailRow('Account ID', userId, textColor, subtitleColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, Color textColor, Color subtitleColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: subtitleColor, fontSize: 14)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value, 
            style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// Quick polyfill for bold
const bold = FontWeight.bold;
