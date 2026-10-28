import 'dart:io';
import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  final _api = ApiService();

  Future<Map<String, dynamic>> getOrders({
    String? status,
    String? periodId,
    String? search,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, String>{'page': '$page', 'limit': '$limit'};
    if (status != null) query['status'] = status;
    if (periodId != null) query['periodId'] = periodId;
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (startDate != null) query['startDate'] = startDate;
    if (endDate != null) query['endDate'] = endDate;

    final data = await _api.get('/orders', query: query);
    final list = (data['data'] as List? ?? [])
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
    return {
      'orders': list,
      'total': (data['pagination'] as Map?)?['total'] ?? list.length,
      'page': (data['pagination'] as Map?)?['page'] ?? page,
      'totalPages': (data['pagination'] as Map?)?['pages'] ?? 1,
    };
  }

  Future<Order> getOrder(String id) async {
    final data = await _api.get('/orders/$id');
    return Order.fromJson(data);
  }

  Future<Order> createOrder({
    required String title,
    required String clientName,
    String? clientPhone,
    String? description,
    double? amount,
    String? deadline,
    String? customerId,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'clientName': clientName,
    };
    if (clientPhone != null && clientPhone.isNotEmpty) body['clientPhone'] = clientPhone;
    if (description != null && description.isNotEmpty) body['description'] = description;
    if (amount != null) body['amount'] = amount;
    if (deadline != null) body['deadline'] = deadline;
    if (customerId != null) body['customerId'] = customerId;

    final data = await _api.post('/orders', body);
    return Order.fromJson(data);
  }

  Future<Order> updateOrder(String id, Map<String, dynamic> updates) async {
    final data = await _api.put('/orders/$id', updates);
    return Order.fromJson(data);
  }

  Future<void> deleteOrder(String id) async {
    await _api.delete('/orders/$id');
  }

  Future<Order> uploadPhoto(String orderId, File photo) async {
    final data = await _api.uploadFile('/orders/$orderId/photos', photo, 'photo');
    return Order.fromJson(data);
  }

  Future<Order> deletePhoto(String orderId, String fileId) async {
    final data = await _api.delete('/orders/$orderId/photos', query: {'fileId': fileId});
    return Order.fromJson(data);
  }

  Future<Order> uploadAudio(String orderId, File audio) async {
    final data = await _api.uploadFile('/orders/$orderId/audio', audio, 'audio');
    return Order.fromJson(data);
  }

  Future<Order> deleteAudio(String orderId) async {
    final data = await _api.delete('/orders/$orderId/audio');
    return Order.fromJson(data);
  }
}
