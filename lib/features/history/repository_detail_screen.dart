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
  static const List<String> _filters = ['Day', 'Week', 'Month', 'Year', 'All'];
  String _timeFilter = 'All'; // Default: show every analysis ever made

  /// Look-back window for each filter; null means no limit ("All").
  static Duration? _periodFor(String filter) {
    switch (filter) {
      case 'Day':
        return const Duration(days: 1);
      case 'Week':
        return const Duration(days: 7);
      case 'Month':
        return const Duration(days: 30);
      case 'Year':
        return const Duration(days: 365);
      default:
        return null;
    }
  }

  static Color _scoreColor(double score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
            
            // Build chart points (date + score) for the selected period
            final now = DateTime.now();
            final period = _periodFor(_timeFilter);
            final List<_ScorePoint> chartPoints = [];
            for (final r in reports) {
              final raw = r['created_at'];
              if (raw == null) continue;
              final date = DateTime.tryParse(raw.toString())?.toLocal();
              if (date == null) continue;
              if (period != null && date.isBefore(now.subtract(period))) continue;
              chartPoints.add(_ScorePoint(date, ((r['overall_score'] ?? 0) as num).toDouble()));
            }
            chartPoints.sort((a, b) => a.date.compareTo(b.date));

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
                            _buildTrendSummary(chartPoints, subtitleColor),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 34,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: _filters.map((filter) {
                              final isSelected = _timeFilter == filter;
                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(() => _timeFilter = filter),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
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
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 210,
                          width: double.infinity,
                          child: chartPoints.isEmpty
                            ? Center(
                                child: Text(
                                  _timeFilter == 'All'
                                      ? 'No analyses yet'
                                      : 'No analyses in the last ${_timeFilter.toLowerCase()}',
                                  style: TextStyle(color: subtitleColor),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: _buildFlChart(chartPoints, now, isDark, subtitleColor),
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

  /// "N analyses · ▲ +12" shown next to the chart title.
  Widget _buildTrendSummary(List<_ScorePoint> points, Color subtitleColor) {
    if (points.isEmpty) return const SizedBox.shrink();
    final count = '${points.length} ${points.length == 1 ? 'analysis' : 'analyses'}';
    if (points.length < 2) {
      return Text(count, style: TextStyle(fontSize: 12, color: subtitleColor));
    }
    final delta = (points.last.score - points.first.score).round();
    final deltaColor = delta > 0
        ? const Color(0xFF10B981)
        : (delta < 0 ? Colors.red : subtitleColor);
    final deltaText = delta > 0 ? '▲ +$delta' : (delta < 0 ? '▼ $delta' : '— 0');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(deltaText,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: deltaColor)),
        const SizedBox(height: 2),
        Text(count, style: TextStyle(fontSize: 11, color: subtitleColor)),
      ],
    );
  }

  /// Picks an x-axis date format that suits the visible time span.
  static DateFormat _axisFormat(Duration span) {
    if (span <= const Duration(days: 2)) return DateFormat('h:mm a');
    if (span <= const Duration(days: 14)) return DateFormat('EEE d');
    if (span <= const Duration(days: 120)) return DateFormat('d MMM');
    if (span <= const Duration(days: 730)) return DateFormat("MMM ''yy");
    return DateFormat('yyyy');
  }

  Widget _buildFlChart(List<_ScorePoint> points, DateTime now, bool isDark, Color subtitleColor) {
    const lineColor = Color(0xFF3B82F6);
    final gridColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    // X axis is real time (ms since epoch), so gaps between analyses are to scale.
    final spots = points
        .map((p) => FlSpot(p.date.millisecondsSinceEpoch.toDouble(), p.score))
        .toList();

    double minX;
    double maxX;
    final period = _periodFor(_timeFilter);
    if (period != null) {
      // Fixed window: e.g. "Week" always spans the last 7 days up to now.
      minX = now.subtract(period).millisecondsSinceEpoch.toDouble();
      maxX = now.millisecondsSinceEpoch.toDouble();
    } else {
      // "All": from the first analysis to the latest one.
      minX = spots.first.x;
      maxX = spots.last.x;
      if (maxX - minX < const Duration(hours: 1).inMilliseconds) {
        // Single analysis (or several within an hour): center them in a 1-day window.
        final mid = (minX + maxX) / 2;
        final half = const Duration(hours: 12).inMilliseconds.toDouble();
        minX = mid - half;
        maxX = mid + half;
      }
    }
    // A little breathing room so the end dots aren't cut off.
    final pad = (maxX - minX) * 0.04;
    minX -= pad;
    maxX += pad;

    final span = Duration(milliseconds: (maxX - minX).round());
    final fmt = _axisFormat(span);

    // fl_chart places ticks at multiples of `interval` counted from 0, plus it
    // always adds labels at min and max. Shift the axis so it starts at 0 —
    // ticks then land exactly at 0, ⅓, ⅔ and the end of the range.
    final origin = minX;
    final spanX = maxX - minX;
    final xInterval = spanX / 3; // 4 date labels across the axis
    final chartSpots = spots.map((s) => FlSpot(s.x - origin, s.y)).toList();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: spanX,
        minY: 0,
        maxY: 100,
        clipData: const FlClipData.none(),
        borderData: FlBorderData(
          show: true,
          border: Border(bottom: BorderSide(color: gridColor, width: 1)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: gridColor,
            strokeWidth: 1,
            dashArray: value == 0 ? null : [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 34,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                space: 8,
                child: Text(
                  value.toInt().toString(),
                  style: TextStyle(color: subtitleColor, fontSize: 11),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: xInterval,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                // Drop any tick that sits too close to the forced min/max labels
                // (rounding can produce a near-duplicate of the last tick).
                final nearMax = value != meta.max && (meta.max - value) < xInterval * 0.5;
                final nearMin = value != meta.min && (value - meta.min) < xInterval * 0.5;
                if (nearMax || nearMin) return const SizedBox.shrink();
                final date = DateTime.fromMillisecondsSinceEpoch((value + origin).round());
                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  fitInside: SideTitleFitInsideData.fromTitleMeta(meta, distanceFromEdge: 0),
                  child: Text(
                    fmt.format(date),
                    style: TextStyle(color: subtitleColor, fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: chartSpots,
            isCurved: spots.length > 2,
            curveSmoothness: 0.25,
            preventCurveOverShooting: true,
            color: lineColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: spots.length > 40 ? 2.5 : 4.5,
                color: _scoreColor(spot.y),
                strokeWidth: 2,
                strokeColor: isDark ? const Color(0xFF111111) : Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: spots.length > 1,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.25),
                  lineColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          getTouchedSpotIndicator: (barData, indexes) => indexes
              .map((_) => TouchedSpotIndicatorData(
                    FlLine(color: subtitleColor.withValues(alpha: 0.5), strokeWidth: 1, dashArray: [3, 3]),
                    FlDotData(
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 6,
                        color: _scoreColor(spot.y),
                        strokeWidth: 2.5,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ))
              .toList(),
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (touchedSpot) =>
                isDark ? const Color(0xFF334155) : const Color(0xFF1E293B),
            getTooltipItems: (touchedSpots) => touchedSpots.map((touchedSpot) {
              final point = points[touchedSpot.spotIndex];
              return LineTooltipItem(
                '${point.score.toInt()} / 100\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                children: [
                  TextSpan(
                    text: DateFormat('dd MMM yyyy, hh:mm a').format(point.date),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ScorePoint {
  final DateTime date;
  final double score;
  const _ScorePoint(this.date, this.score);
}
