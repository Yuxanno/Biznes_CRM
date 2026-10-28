import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final _service = DashboardService();

  DashboardData? _data;
  bool _loading = false;
  String? _error;

  DashboardData? get data => _data;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({String? periodId, bool silent = false}) async {
    if (!silent) {
      _loading = true;
      _error = null;
      notifyListeners();
    }
    try {
      _data = await _service.getDashboard(periodId: periodId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _data = null;
    _error = null;
    notifyListeners();
  }
}
