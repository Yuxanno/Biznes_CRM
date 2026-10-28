import 'dart:io';
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final _service = OrderService();

  List<Order> _items = [];
  Order? _selected;
  bool _loading = false;
  String? _error;
  int _total = 0;
  int _page = 1;
  int _totalPages = 1;

  String? filterStatus;
  String? filterPeriodId;
  String? filterSearch;

  List<Order> get items => _items;
  Order? get selected => _selected;
  bool get loading => _loading;
  String? get error => _error;
  int get total => _total;
  bool get hasMore => _page < _totalPages;

  Future<void> load({bool reset = true}) async {
    if (reset) { _page = 1; _items = []; }
    _loading = true; _error = null;
    notifyListeners();
    try {
      final result = await _service.getOrders(
        status: filterStatus,
        periodId: filterPeriodId,
        search: filterSearch,
        page: _page,
      );
      if (reset) {
        _items = result['orders'] as List<Order>;
      } else {
        _items.addAll(result['orders'] as List<Order>);
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

  Future<void> loadOne(String id) async {
    _loading = true; notifyListeners();
    try {
      _selected = await _service.getOrder(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required String title,
    required String clientName,
    String? clientPhone,
    String? description,
    double? amount,
    String? deadline,
    String? customerId,
  }) async {
    try {
      final o = await _service.createOrder(
        title: title,
        clientName: clientName,
        clientPhone: clientPhone,
        description: description,
        amount: amount,
        deadline: deadline,
        customerId: customerId,
      );
      _items.insert(0, o);
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
      final updated = await _service.updateOrder(id, updates);
      final idx = _items.indexWhere((o) => o.id == id);
      if (idx != -1) _items[idx] = updated;
      if (_selected?.id == id) _selected = updated;
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
      await _service.deleteOrder(id);
      _items.removeWhere((o) => o.id == id);
      if (_selected?.id == id) _selected = null;
      _total--;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadPhoto(String orderId, File photo) async {
    try {
      final updated = await _service.uploadPhoto(orderId, photo);
      _updateLocal(updated);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePhoto(String orderId, String fileId) async {
    try {
      final updated = await _service.deletePhoto(orderId, fileId);
      _updateLocal(updated);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadAudio(String orderId, File audio) async {
    try {
      final updated = await _service.uploadAudio(orderId, audio);
      _updateLocal(updated);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAudio(String orderId) async {
    try {
      final updated = await _service.deleteAudio(orderId);
      _updateLocal(updated);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _updateLocal(Order updated) {
    final idx = _items.indexWhere((o) => o.id == updated.id);
    if (idx != -1) _items[idx] = updated;
    if (_selected?.id == updated.id) _selected = updated;
    notifyListeners();
  }

  void setFilters({String? status, String? periodId, String? search}) {
    filterStatus = status;
    filterPeriodId = periodId;
    filterSearch = search;
  }

  void clearError() { _error = null; notifyListeners(); }
}
