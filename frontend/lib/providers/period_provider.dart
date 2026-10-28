import 'package:flutter/material.dart';
import '../models/business_period.dart';
import '../services/period_service.dart';

class PeriodProvider extends ChangeNotifier {
  final _service = PeriodService();

  List<BusinessPeriod> _items = [];
  BusinessPeriod? _active;
  bool _loading = false;
  String? _error;

  List<BusinessPeriod> get items => _items;
  BusinessPeriod? get active => _active;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true; _error = null;
    notifyListeners();
    try {
      _items = await _service.getPeriods();
      _active = _items.firstWhere(
        (p) => p.isActive,
        orElse: () => _items.first,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createPeriod(String name) async {
    try {
      final newPeriod = await _service.createPeriod(name);
      // Mark previous active as closed locally
      _items = _items.map((p) => p.isActive
          ? BusinessPeriod(
              id: p.id, name: p.name, startDate: p.startDate,
              endDate: DateTime.now(), status: 'closed',
            )
          : p).toList();
      _items.insert(0, newPeriod);
      _active = newPeriod;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() { _error = null; notifyListeners(); }
}
