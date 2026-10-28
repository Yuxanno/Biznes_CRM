import '../models/dashboard_data.dart';
import 'api_service.dart';

class DashboardService {
  final _api = ApiService();

  Future<DashboardData> getDashboard({String? periodId}) async {
    final query = <String, String>{};
    if (periodId != null) query['periodId'] = periodId;
    final data = await _api.get('/dashboard', query: query.isEmpty ? null : query);
    // backend wraps in { success, data: { ... } }, _handleResponse returns data (the inner map)
    return DashboardData.fromJson(data);
  }
}
