import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../services/debt_service.dart';

class DebtProvider extends ChangeNotifier {
  final _service = DebtService();

  List<Debt> _items = [];
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _summary;

  String? filterType;
  String? filterStatus;
  String? filterSearch;

  List<Debt> get items => _items;
  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get summary => _summary;

  Future<void> load() async {
    _loading = true; _error = null;
    notifyListeners();
    try {
      final result = await _service.getDebts(
        type: filterType,
        status: filterStatus,
        search: filterSearch,
      );
      _items = result['debts'] as List<Debt>;
      _summary = result['summary'] as Map<String, dynamic>?;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required String type,
    required String personName,
    String? phone,
    required double amount,
    double? paidAmount,
    String? description,
    String? dueDate,
    String? customerId,
  }) async {
    try {
      final d = await _service.createDebt(
        type: type,
        personName: personName,
        phone: phone,
        amount: amount,
        paidAmount: paidAmount,
        description: description,
        dueDate: dueDate,
        customerId: customerId,
      );
      _items.insert(0, d);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(String id, Map<String, dynamic> updates) async {
    try {
      final updated = await _service.updateDebt(id, updates);
      final idx = _items.indexWhere((d) => d.id == id);
      if (idx != -1) _items[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _service.deleteDebt(id);
      _items.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setFilters({String? type, String? status, String? search}) {
    filterType = type;
    filterStatus = status;
    filterSearch = search;
  }

  void clearError() { _error = null; notifyListeners(); }
}
