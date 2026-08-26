import 'package:flutter/material.dart';
import '../../theme_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
        final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
        final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final bgColor = Theme.of(context).scaffoldBackgroundColor;
        final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

        // Hardcoded mock notifications for now based on user request
        final notifications = [
          {
            'icon': Icons.analytics_outlined,
            'color': const Color(0xFF10B981),
            'title': 'Analysis Completed',
            'body': 'Your repository "cozycafe" scored 98/100. Great job maintaining high code quality!',
            'time': '2 hours ago',
          },
          {
            'icon': Icons.system_update_alt,
            'color': const Color(0xFF3B82F6),
            'title': 'App Update Available',
            'body': 'CodeAudit AI version 1.1 is now available with new security scanning rules.',
            'time': '1 day ago',
          },
          {
            'icon': Icons.bug_report_outlined,
            'color': const Color(0xFFEF4444),
            'title': 'New Vulnerability Detected',
            'body': 'A critical dependency issue was found in your recent branch scan.',
            'time': '3 days ago',
          },
        ];

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
              'Notifications',
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (notif['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(notif['icon'] as IconData, color: notif['color'] as Color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notif['title'] as String,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif['body'] as String,
                            style: TextStyle(color: subtitleColor, fontSize: 14, height: 1.4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notif['time'] as String,
                            style: TextStyle(color: subtitleColor.withOpacity(0.6), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
