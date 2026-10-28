import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final _service = TransactionService();

  List<Transaction> _items = [];
  bool _loading = false;
  String? _error;
  int _total = 0;
  int _page = 1;
  int _totalPages = 1;

  // Active filters
  String? filterType;
  String? filterCategory;
  String? filterPeriodId;
  String? filterSearch;

  List<Transaction> get items => _items;
  bool get loading => _loading;
  String? get error => _error;
  int get total => _total;
  bool get hasMore => _page < _totalPages;

  Future<void> load({bool reset = true}) async {
    if (reset) {
      _page = 1;
      _items = [];
    }
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getTransactions(
        type: filterType,
        category: filterCategory,
        periodId: filterPeriodId,
        search: filterSearch,
        page: _page,
      );
      if (reset) {
        _items = result['transactions'] as List<Transaction>;
      } else {
        _items.addAll(result['transactions'] as List<Transaction>);
      }
      _total = result['total'] as int;
      _totalPages = result['totalPages'] as int;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || _loading) return;
    _page++;
    await load(reset: false);
  }

  Future<bool> create({
    required String type,
    required double amount,
    required String category,
    String? description,
    String? date,
  }) async {
    try {
      final t = await _service.createTransaction(
        type: type,
        amount: amount,
        category: category,
        description: description,
        date: date,
      );
      _items.insert(0, t);
      _total++;
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
      final updated = await _service.updateTransaction(
        id,
        type: updates['type'],
        amount: updates['amount'],
        category: updates['category'],
        description: updates['description'],
        date: updates['date'],
      );
      final idx = _items.indexWhere((t) => t.id == id);
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
      await _service.deleteTransaction(id);
      _items.removeWhere((t) => t.id == id);
      _total--;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setFilters({String? type, String? category, String? periodId, String? search}) {
    filterType = type;
    filterCategory = category;
    filterPeriodId = periodId;
    filterSearch = search;
  }

  void clearError() { _error = null; notifyListeners(); }
}
