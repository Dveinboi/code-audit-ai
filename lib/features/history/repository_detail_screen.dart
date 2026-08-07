import 'package:flutter/material.dart';
import '../ai/ai_screen.dart';
import '../issues/issues_screen.dart';
import 'history_screen.dart'; 

class RepositoryDetailScreen extends StatefulWidget {
  final String repoName;
  final int score;

  const RepositoryDetailScreen({
    Key? key,
    required this.repoName,
    required this.score,
  }) : super(key: key);

  @override
  State<RepositoryDetailScreen> createState() => _RepositoryDetailScreenState();
}

class _RepositoryDetailScreenState extends State<RepositoryDetailScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.repoName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score Trend Chart Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Score Trend',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Custom Line Chart Representation
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _TrendChartPainter(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Latest Analysis Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Latest Analysis',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '20 May 2025, 10:30 AM',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${widget.score}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const Text(
                          ' /100',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Report Summary Card added here
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Report Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'The repository maintains a healthy overall structure. Some security vulnerabilities were detected in outdated dependencies. It is recommended to update NPM packages and review the high-severity alerts identified during the latest code scan.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // View Full Report Button (Now tappable)
              InkWell(
                onTap: () {
                  // Navigate back to the Overview (Dashboard) page
                  Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'View Full Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
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
              // Pop back to the parent History screen instead of pushing a duplicate
              Navigator.pop(context);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: const Color(0xFF94A3B8),
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

// Custom Line Chart Painter
class _TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
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
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw horizontal grid lines (0, 50, 100)
    canvas.drawLine(Offset(30, 0), Offset(size.width, 0), gridPaint);
    canvas.drawLine(Offset(30, size.height / 2), Offset(size.width, size.height / 2), gridPaint);
    canvas.drawLine(Offset(30, size.height), Offset(size.width, size.height), gridPaint);

    // Draw Y-axis labels
    final TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    void drawText(String text, Offset offset) {
      tp.text = TextSpan(text: text, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11));
      tp.layout();
      tp.paint(canvas, offset);
    }
    
    drawText('100', const Offset(0, -6));
    drawText('50', Offset(8, size.height / 2 - 6));
    drawText('0', Offset(16, size.height - 6));

    // Data points mimicking the design curve
    final List<Offset> points = [
      Offset(40, size.height * 0.7),
      Offset(size.width * 0.35, size.height * 0.4),
      Offset(size.width * 0.55, size.height * 0.45),
      Offset(size.width * 0.75, size.height * 0.2),
      Offset(size.width * 0.95, size.height * 0.05),
    ];

    // Draw lines between points
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Draw the points
    for (var point in points) {
      canvas.drawCircle(point, 5, circleFillPaint);
      canvas.drawCircle(point, 5, circleBorderPaint);
    }

    // Draw X-axis labels
    drawText('Apr 20', Offset(30, size.height + 10));
    drawText('Apr 27', Offset(size.width * 0.25, size.height + 10));
    drawText('May 04', Offset(size.width * 0.45, size.height + 10));
    drawText('May 11', Offset(size.width * 0.65, size.height + 10));
    drawText('May 20', Offset(size.width * 0.85, size.height + 10));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}