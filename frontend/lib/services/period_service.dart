import '../models/business_period.dart';
import 'api_service.dart';

class PeriodService {
  final _api = ApiService();

  Future<List<BusinessPeriod>> getPeriods() async {
    final data = await _api.get('/periods');
    // backend: { success, data: [...array of periods...] }
    final list = data['data'] as List? ?? [];
    return list
        .map((e) => BusinessPeriod.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getPeriod(String id) async {
    return _api.get('/periods/$id');
  }

  Future<BusinessPeriod> createPeriod(String name) async {
    final data = await _api.post('/periods', {'name': name});
    // backend: { success, data: { newPeriod: {...} } } or data is the period itself
    final payload = data['data'] as Map<String, dynamic>? ?? data;
    final periodData = payload['newPeriod'] as Map<String, dynamic>? ?? payload;
    return BusinessPeriod.fromJson(periodData);
  }
}
