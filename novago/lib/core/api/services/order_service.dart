import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/order.dart';

class OrderService {
  final Dio _dio = ApiClient().dio;

  Future<Order> createOrder({
    required String restaurantId,
    required String customerName,
    required String deliveryAddress,
    String? customerPhone,
    Map<String, dynamic>? deliveryLocation,
    Map<String, dynamic>? restaurantLocation,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      if (items.isEmpty) {
        throw ArgumentError('At least one order item is required');
      }

      final payload = {
        'restaurantId': restaurantId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'deliveryAddress': deliveryAddress,
        'deliveryLocation': deliveryLocation,
        'restaurantLocation': restaurantLocation,
        'items': items,
      }..removeWhere((key, value) => value == null);

      final response = await _dio.post('/api/orders', data: payload);
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Order>> getOrders() async {
    try {
      final response = await _dio.get('/api/orders');
      final List<dynamic> data = response.data;
      return data.map((json) => Order.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Order> getOrder(String id) async {
    try {
      final response = await _dio.get('/api/orders/$id');
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Order> updateOrderStatus(String id, String status) async {
    try {
      final response = await _dio.patch(
        '/api/orders/$id/status',
        data: {'status': status},
      );
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<OrderTracking> getOrderTracking(String id) async {
    try {
      final response = await _dio.get('/api/orders/$id/tracking');
      return OrderTracking.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['message'] ?? 'An error occurred';
    }
    return error.message ?? 'Network error occurred';
  }
}
