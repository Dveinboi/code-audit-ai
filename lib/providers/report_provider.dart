import 'package:flutter/material.dart';

class ReportProvider extends ChangeNotifier {
  Map<String, dynamic>? _reportData;

  Map<String, dynamic>? get reportData => _reportData;

  void setReportData(Map<String, dynamic>? data) {
    _reportData = data;
    notifyListeners();
  }
}
