import '../models/customer.dart';
import 'api_service.dart';

class CustomerService {
  final _api = ApiService();

  Future<Map<String, dynamic>> getCustomers({String? search, int page = 1, int limit = 20}) async {
    final query = <String, String>{'page': '$page', 'limit': '$limit'};
    if (search != null && search.isNotEmpty) query['search'] = search;

    final data = await _api.get('/customers', query: query);
    final list = (data['data'] as List? ?? [])
        .map((e) => Customer.fromJson(e as Map<String, dynamic>))
        .toList();
    return {
      'customers': list,
      'total': (data['pagination'] as Map?)?['total'] ?? list.length,
      'totalPages': (data['pagination'] as Map?)?['pages'] ?? 1,
    };
  }

  Future<Map<String, dynamic>> getCustomer(String id) async {
    final data = await _api.get('/customers/$id');
    return data;
  }

  Future<Customer> createCustomer({
    required String name,
    String? phone,
    String? notes,
  }) async {
    final body = <String, dynamic>{'name': name};
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;

    final data = await _api.post('/customers', body);
    return Customer.fromJson(data);
  }

  Future<Customer> updateCustomer(String id, Map<String, dynamic> updates) async {
    final data = await _api.put('/customers/$id', updates);
    return Customer.fromJson(data);
  }

  Future<void> deleteCustomer(String id) async {
    await _api.delete('/customers/$id');
  }
}
