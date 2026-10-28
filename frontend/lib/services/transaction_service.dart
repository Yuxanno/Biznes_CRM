import '../models/transaction.dart';
import 'api_service.dart';

class TransactionService {
  final _api = ApiService();

  Future<Map<String, dynamic>> getTransactions({
    String? type,
    String? category,
    String? periodId,
    String? search,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };
    if (type != null) query['type'] = type;
    if (category != null) query['category'] = category;
    if (periodId != null) query['periodId'] = periodId;
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (startDate != null) query['startDate'] = startDate;
    if (endDate != null) query['endDate'] = endDate;

    final data = await _api.get('/transactions', query: query);
    final list = (data['data'] as List? ?? [])
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
    return {
      'transactions': list,
      'total': (data['pagination'] as Map?)?['total'] ?? list.length,
      'page': (data['pagination'] as Map?)?['page'] ?? page,
      'totalPages': (data['pagination'] as Map?)?['pages'] ?? 1,
    };
  }

  Future<Transaction> getTransaction(String id) async {
    final data = await _api.get('/transactions/$id');
    return Transaction.fromJson(data);
  }

  Future<Transaction> createTransaction({
    required String type,
    required double amount,
    required String category,
    String? description,
    String? date,
  }) async {
    final body = <String, dynamic>{
      'type': type,
      'amount': amount,
      'category': category,
    };
    if (description != null && description.isNotEmpty) body['description'] = description;
    if (date != null) body['date'] = date;

    final data = await _api.post('/transactions', body);
    return Transaction.fromJson(data);
  }

  Future<Transaction> updateTransaction(
    String id, {
    String? type,
    double? amount,
    String? category,
    String? description,
    String? date,
  }) async {
    final body = <String, dynamic>{};
    if (type != null) body['type'] = type;
    if (amount != null) body['amount'] = amount;
    if (category != null) body['category'] = category;
    if (description != null) body['description'] = description;
    if (date != null) body['date'] = date;

    final data = await _api.put('/transactions/$id', body);
    return Transaction.fromJson(data);
  }

  Future<void> deleteTransaction(String id) async {
    await _api.delete('/transactions/$id');
  }
}
