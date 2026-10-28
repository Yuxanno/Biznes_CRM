import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';

class CustomerProvider extends ChangeNotifier {
  final _service = CustomerService();

  List<Customer> _items = [];
  bool _loading = false;
  String? _error;
  int _total = 0;
  int _totalPages = 1;
  int _page = 1;
  String? filterSearch;

  List<Customer> get items => _items;
  bool get loading => _loading;
  String? get error => _error;
  int get total => _total;
  bool get hasMore => _page < _totalPages;

  Future<void> load({bool reset = true}) async {
    if (reset) { _page = 1; _items = []; }
    _loading = true; _error = null;
    notifyListeners();
    try {
      final result = await _service.getCustomers(search: filterSearch, page: _page);
      if (reset) {
        _items = result['customers'] as List<Customer>;
      } else {
        _items.addAll(result['customers'] as List<Customer>);
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

  Future<bool> create({required String name, String? phone, String? notes}) async {
    try {
      final c = await _service.createCustomer(name: name, phone: phone, notes: notes);
      _items.insert(0, c);
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
      final updated = await _service.updateCustomer(id, updates);
      final idx = _items.indexWhere((c) => c.id == id);
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
      await _service.deleteCustomer(id);
      _items.removeWhere((c) => c.id == id);
      _total--;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setSearch(String? search) { filterSearch = search; }
  void clearError() { _error = null; notifyListeners(); }
}
