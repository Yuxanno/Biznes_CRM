import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final _service = NotificationService();

  List<AppNotification> _items = [];
  bool _loading = false;
  String? _error;

  List<AppNotification> get items => _items;
  bool get loading => _loading;
  String? get error => _error;
  int get unreadCount => _items.where((n) => !n.read).length;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _service.getNotifications();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      _items = _items.map((n) => AppNotification(
        id: n.id,
        type: n.type,
        title: n.title,
        message: n.message,
        read: true,
        relatedId: n.relatedId,
        relatedType: n.relatedType,
        createdAt: n.createdAt,
      )).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
