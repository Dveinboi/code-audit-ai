import 'package:flutter/material.dart';
import '../ai/ai_screen.dart';
import '../issues/issues_screen.dart';
import '../dashboard/dashboard_screen.dart';
import 'history_screen.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:fl_chart/fl_chart.dart';

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
  String _timeFilter = 'Month'; // Default filter

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
          widget.repoName.contains('/') ? widget.repoName.split('/').last : widget.repoName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
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
            
            // Filter reports for the chart
            final now = DateTime.now();
            List<dynamic> chartReports = reports.where((r) {
              if (r['created_at'] == null) return false;
              try {
                final date = DateTime.parse(r['created_at']).toLocal();
                if (_timeFilter == 'Day') {
                  return now.difference(date).inHours <= 24;
                } else if (_timeFilter == 'Week') {
                  return now.difference(date).inDays <= 7;
                } else {
                  return now.difference(date).inDays <= 30; // Month
                }
              } catch(e) {
                return false;
              }
            }).toList();
            
            // Sort ascending for graph
            chartReports.sort((a, b) {
              final da = DateTime.parse(a['created_at']).toLocal();
              final db = DateTime.parse(b['created_at']).toLocal();
              return da.compareTo(db);
            });

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Score Trend',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: ['Day', 'Week', 'Month'].map((filter) {
                                  final isSelected = _timeFilter == filter;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _timeFilter = filter;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          filter,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected ? Colors.white : subtitleColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: chartReports.isEmpty
                            ? Center(child: Text('No data for selected period', style: TextStyle(color: subtitleColor)))
                            : _buildFlChart(chartReports, isDark, subtitleColor),
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
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                        title: Text('Delete Analysis', style: TextStyle(color: textColor)),
                                        content: Text('Are you sure you want to delete this analysis from $reportFormattedDate?', style: TextStyle(color: subtitleColor)),
                                        actions: [
                                          TextButton(
                                            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                            onPressed: () => Navigator.of(context).pop(),
                                          ),
                                          TextButton(
                                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              try {
                                                await ApiService.deleteReport(report['id']);
                                                setState(() {
                                                  _repoFuture = ApiService.getRepositoryHistory(widget.repositoryId);
                                                });
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
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
                                      settings: const RouteSettings(name: '/dashboard'),
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

  Widget _buildFlChart(List<dynamic> reports, bool isDark, Color subtitleColor) {
    List<FlSpot> spots = [];
    for (int i = 0; i < reports.length; i++) {
      final score = (reports[i]['overall_score'] ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), score));
    }
    
    // If only one data point, duplicate it to draw a flat line segment so it's visible
    if (spots.length == 1) {
      spots.add(FlSpot(1.0, spots[0].y));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide x-axis dates
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 50,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: subtitleColor, fontSize: 11),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (spots.length - 1).toDouble().clamp(1.0, double.infinity),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false, // Straight lines
            color: const Color(0xFF3B82F6),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF3B82F6),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: false,
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => isDark ? const Color(0xFF334155) : const Color(0xFF1E293B),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                int index = touchedSpot.spotIndex;
                if (reports.length == 1) index = 0; // Prevent out of bounds if duplicated
                
                String dateStr = reports[index]['created_at'] ?? '';
                String formattedDate = '';
                if (dateStr.isNotEmpty) {
                  try {
                     final date = DateTime.parse(dateStr).toLocal();
                     formattedDate = DateFormat('MMM dd, hh:mm a').format(date);
                  } catch(e) {}
                }
                
                return LineTooltipItem(
                  '${touchedSpot.y.toInt()} / 100\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  children: [
                    TextSpan(
                      text: formattedDate,
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.normal),
                    ),
                  ],
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }
}