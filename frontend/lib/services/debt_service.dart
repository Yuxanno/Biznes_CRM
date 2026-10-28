import '../models/debt.dart';
import 'api_service.dart';

class DebtService {
  final _api = ApiService();

  Future<Map<String, dynamic>> getDebts({
    String? type,
    String? status,
    String? search,
  }) async {
    final query = <String, String>{};
    if (type != null) query['type'] = type;
    if (status != null) query['status'] = status;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final data = await _api.get('/debts', query: query.isEmpty ? null : query);
    // backend: { success, data: { debts: [...], summary: {...} } }
    final payload = data['data'] as Map<String, dynamic>? ?? data;
    final list = (payload['debts'] as List? ?? [])
        .map((e) => Debt.fromJson(e as Map<String, dynamic>))
        .toList();
    return {
      'debts': list,
      'summary': payload['summary'],
    };
  }

  Future<Debt> createDebt({
    required String type,
    required String personName,
    String? phone,
    required double amount,
    double? paidAmount,
    String? description,
    String? dueDate,
    String? customerId,
  }) async {
    final body = <String, dynamic>{
      'type': type,
      'personName': personName,
      'amount': amount,
    };
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (paidAmount != null) body['paidAmount'] = paidAmount;
    if (description != null && description.isNotEmpty) body['description'] = description;
    if (dueDate != null) body['dueDate'] = dueDate;
    if (customerId != null) body['customerId'] = customerId;

    final data = await _api.post('/debts', body);
    return Debt.fromJson(data);
  }

  Future<Debt> updateDebt(String id, Map<String, dynamic> updates) async {
    final data = await _api.put('/debts/$id', updates);
    return Debt.fromJson(data);
  }

  Future<void> deleteDebt(String id) async {
    await _api.delete('/debts/$id');
  }
}
