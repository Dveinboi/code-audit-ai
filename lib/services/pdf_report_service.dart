import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class PdfReportService {
  static Future<void> generateAndSaveReport(Map<String, dynamic>? reportData, String repoName) async {
    final pdf = pw.Document();

    // Load the logo
    final ByteData logoData = await rootBundle.load('assets/images/logo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final logoImage = pw.MemoryImage(logoBytes);

    // Extract data
    final aiSummary = reportData?['ai_summary'] ?? 'No AI summary available.';
    final detailedFindings = reportData?['detailed_findings'] as List<dynamic>? ?? [];

    // Only chart categories that were actually measured (null = not measured).
    final allScores = {
      'Security': reportData?['score_security'],
      'Quality': reportData?['score_quality'],
      'Performance': reportData?['score_performance'],
      'Maintainability': reportData?['score_maintainability'],
      'Dependencies': reportData?['score_dependencies'],
      'Testing': reportData?['score_testing'],
    };
    final scores = Map.fromEntries(allScores.entries.where((e) => e.value != null));

    final labels = scores.keys.toList();
    final currentValues = scores.values.map((e) => (e as num).toInt()).toList();
    final futureValues = List.filled(labels.length, 100);

    // Header builder for all pages
    pw.Widget buildHeader(pw.Context context) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 20),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Image(logoImage, width: 40, height: 40),
            pw.SizedBox(width: 10),
            pw.Text('CodeAudit AI', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
            pw.Spacer(),
            pw.Text(repoName, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
          ],
        ),
      );
    }

    // Single MultiPage with maxPages: 2
    pdf.addPage(
      pw.MultiPage(
        maxPages: 2,
        build: (context) {
          List<pw.Widget> widgets = [];

          // Document Header
          widgets.add(buildHeader(context));

          // Executive Summary
          widgets.add(pw.Header(level: 0, child: pw.Text('Executive Summary')));
          widgets.add(pw.Paragraph(text: aiSummary, style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5)));
          widgets.add(pw.SizedBox(height: 15));

          // Current State Graph
          widgets.add(pw.Header(level: 0, child: pw.Text('Current State - Category Scores')));
          widgets.add(pw.SizedBox(height: 15));
          widgets.add(_buildBarChart(labels, currentValues, PdfColors.teal600)); // Using teal as requested implicitly by user's screenshot
          widgets.add(pw.SizedBox(height: 15));

          // Detailed Findings
          if (detailedFindings.isNotEmpty) {
            widgets.add(pw.Header(level: 0, child: pw.Text('Detailed Findings')));
            for (var finding in detailedFindings) {
              widgets.add(
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(finding['title'] ?? 'Unknown Issue', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      pw.SizedBox(height: 4),
                      pw.Text('Severity: ${finding['severity']} | Category: ${finding['category']}', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
                      pw.SizedBox(height: 4),
                      pw.Text('Impact: ${finding['impact'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 4),
                      pw.Text('Recommendation: ${finding['recommendation'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              );
            }
          }

          return widgets;
        },
      ),
    );

    // Save PDF
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final sanitizedRepoName = repoName.replaceAll('/', '_');
    final file = File('${dir.path}/CodeAudit_Report_$sanitizedRepoName.pdf');
    await file.writeAsBytes(bytes);

    // Open PDF
    await OpenFilex.open(file.path);
  }

  static pw.Widget _buildBarChart(List<String> labels, List<int> values, PdfColor color) {
    return pw.Column(
      children: List.generate(labels.length, (index) {
        final val = values[index];
        final label = labels[index];
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(width: 80, child: pw.Text(label, style: const pw.TextStyle(fontSize: 10))),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    if (val > 0)
                      pw.Expanded(
                        flex: val,
                        child: pw.Container(height: 14, color: color),
                      ),
                    if (val < 100)
                      pw.Expanded(
                        flex: 100 - val,
                        child: pw.Container(height: 14, color: PdfColors.grey200),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Container(width: 45, child: pw.Text('$val/100', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
            ],
          ),
        );
      }),
    );
  }
}
