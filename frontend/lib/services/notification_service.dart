import '../models/notification.dart';
import 'api_service.dart';

class NotificationService {
  final _api = ApiService();

  Future<List<AppNotification>> getNotifications() async {
    final data = await _api.get('/notifications');
    // backend: { success, data: { notifications: [...] } }
    final payload = data['data'] as Map<String, dynamic>? ?? data;
    return (payload['notifications'] as List? ?? [])
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAllAsRead() async {
    await _api.patch('/notifications');
  }
}
