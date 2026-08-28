import 'package:flutter/material.dart';
import '../ai/ai_screen.dart';
import '../issues/issues_screen.dart';
import '../dashboard/dashboard_screen.dart';
import 'history_screen.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart' hide TextDirection;

class RepositoryDetailScreen extends StatefulWidget {
  final String repoName;
  final String repositoryId;
  final int score;

  const RepositoryDetailScreen({
    Key? key,
    required this.repoName,
    required this.repositoryId,
    required this.score,
  }) : super(key: key);

  @override
  State<RepositoryDetailScreen> createState() => _RepositoryDetailScreenState();
}

class _RepositoryDetailScreenState extends State<RepositoryDetailScreen> {
  late Future<Map<String, dynamic>> _repoFuture;

  @override
  void initState() {
    super.initState();
    _repoFuture = ApiService.getRepositoryHistory(widget.repositoryId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF111111) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.repoName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.star_border, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _repoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
            } else if (!snapshot.hasData || snapshot.data!['reports'] == null || snapshot.data!['reports'].isEmpty) {
              return Center(child: Text('No history found.', style: TextStyle(color: subtitleColor)));
            }

            final reports = List<dynamic>.from(snapshot.data!['reports']);
            final latestReport = reports.last; // Because it was sorted ascending in backend

            final String latestDateStr = latestReport['created_at'] ?? '';
            String latestFormattedDate = 'Unknown date';
            if (latestDateStr.isNotEmpty) {
              try {
                final date = DateTime.parse(latestDateStr).toLocal();
                latestFormattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
              } catch (e) {}
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Score Trend',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: _DynamicTrendChartPainter(
                              gridColor: dividerColor,
                              labelColor: subtitleColor,
                              reports: reports,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Latest Analysis',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              latestFormattedDate,
                              style: TextStyle(
                                fontSize: 13,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${latestReport['overall_score']}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            Text(
                              ' /100',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Past Analyses',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reports.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            // Reverse order for the list to show newest first
                            final report = reports[reports.length - 1 - index];
                            String reportDateStr = report['created_at'] ?? '';
                            String reportFormattedDate = '';
                            if (reportDateStr.isNotEmpty) {
                              try {
                                final date = DateTime.parse(reportDateStr).toLocal();
                                reportFormattedDate = 'Analyzed on ${DateFormat('dd MMM yyyy, hh:mm a').format(date)}';
                              } catch (e) {}
                            }
                            final sc = report['overall_score'] ?? 0;
                            final itemScoreColor = sc >= 80 ? const Color(0xFF10B981) : (sc >= 50 ? Colors.orange : Colors.red);

                            return Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor, width: 1.5),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: sc / 100,
                                        backgroundColor: itemScoreColor.withOpacity(0.2),
                                        valueColor: AlwaysStoppedAnimation<Color>(itemScoreColor),
                                        strokeWidth: 4,
                                      ),
                                      Text(
                                        sc.toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                title: Text(
                                  widget.repoName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                subtitle: Text(
                                  reportFormattedDate,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: subtitleColor,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DashboardScreen(
                                        jobId: report['job_id'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: dividerColor, width: 1.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: 4,
          onTap: (index) {
            if (index == 0) {
              Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
            } else if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const IssuesScreen()));
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AiScreen()));
            } else if (index == 3) {
              Navigator.pushNamed(context, '/select_repo');
            } else if (index == 4) {
              Navigator.pop(context);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: bgColor,
          elevation: 0,
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: subtitleColor,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Overview'),
            BottomNavigationBarItem(icon: Icon(Icons.bug_report_outlined), activeIcon: Icon(Icons.bug_report), label: 'Issues'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), activeIcon: Icon(Icons.auto_awesome), label: 'AI'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'New Repo'),
            BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'History'),
          ],
        ),
      ),
    );
  }
}

class _DynamicTrendChartPainter extends CustomPainter {
  final Color gridColor;
  final Color labelColor;
  final List<dynamic> reports;

  _DynamicTrendChartPainter({required this.gridColor, required this.labelColor, required this.reports});

  @override
  void paint(Canvas canvas, Size size) {
    if (reports.isEmpty) return;

    final Paint linePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final Paint circleFillPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.fill;

    final Paint circleBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(30, 0), Offset(size.width, 0), gridPaint);
    canvas.drawLine(Offset(30, size.height / 2), Offset(size.width, size.height / 2), gridPaint);
    canvas.drawLine(Offset(30, size.height), Offset(size.width, size.height), gridPaint);

    final TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    void drawText(String text, Offset offset) {
      tp.text = TextSpan(text: text, style: TextStyle(color: labelColor, fontSize: 11));
      tp.layout();
      tp.paint(canvas, offset);
    }
    
    drawText('100', const Offset(0, -6));
    drawText('50', Offset(8, size.height / 2 - 6));
    drawText('0', Offset(16, size.height - 6));

    // Calculate dynamic points based on report scores
    final List<Offset> points = [];
    final int count = reports.length;
    
    for (int i = 0; i < count; i++) {
      final score = (reports[i]['overall_score'] ?? 0).toDouble();
      
      // Calculate X: spaced evenly across width (starting after y-axis labels)
      final double startX = 40.0;
      final double widthRemaining = size.width - startX;
      final double x = count <= 1 ? size.width / 2 : startX + (widthRemaining / (count - 1)) * i;
      
      // Calculate Y: mapped inverted to height (100 = 0, 0 = height)
      final double y = size.height - (score / 100.0) * size.height;
      
      points.add(Offset(x, y));
    }

    if (points.length > 1) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 5, circleFillPaint);
      canvas.drawCircle(points[i], 5, circleBorderPaint);
      
      // Draw dates
      String dateStr = reports[i]['created_at'] ?? '';
      if (dateStr.isNotEmpty) {
        try {
           final date = DateTime.parse(dateStr).toLocal();
           final formattedDate = DateFormat('MMM dd').format(date);
           drawText(formattedDate, Offset(points[i].dx - 15, size.height + 10));
        } catch(e) {}
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}