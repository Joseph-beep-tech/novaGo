import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/menu_item.dart';

class MenuService {
  final Dio _dio = ApiClient().dio;

  Future<List<MenuItem>> getRestaurantMenu(String restaurantId) async {
    try {
      print('🍽️ Loading menu for restaurant $restaurantId...');
      final response = await _dio.get('/api/menus/restaurant/$restaurantId');
      print('✅ Menu API Response Status: ${response.statusCode}');
      print('✅ Menu API Response Data Type: ${response.data.runtimeType}');
      
      // Handle both array and object responses
      if (response.data == null) {
        print('⚠️ Warning: API returned null menu data');
        return [];
      }
      
      // If response.data is a List, use it directly
      if (response.data is List) {
        final List<dynamic> data = response.data;
        print('✅ Found ${data.length} menu items in response');
        
        final List<MenuItem> items = [];
        for (int i = 0; i < data.length; i++) {
          try {
            final item = MenuItem.fromJson(data[i] as Map<String, dynamic>);
            items.add(item);
            print('  ✅ Parsed menu item ${i + 1}: ${item.name}');
          } catch (e, stackTrace) {
            print('❌ Error parsing menu item ${i + 1}: $e');
            print('   Menu item data: ${data[i]}');
            print('   Stack trace: $stackTrace');
            // Continue parsing other items even if one fails
          }
        }
        
        print('✅ Successfully parsed ${items.length} out of ${data.length} menu items');
        return items;
      }
      
      // If response.data is an object with a data property
      if (response.data is Map) {
        final Map<String, dynamic> responseMap = response.data as Map<String, dynamic>;
        if (responseMap.containsKey('data') && responseMap['data'] is List) {
          final List<dynamic> data = responseMap['data'];
          return data.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
        }
      }
      
      print('⚠️ Warning: Unexpected menu response format: ${response.data}');
      return [];
    } on DioException catch (e) {
      print('❌ DioException in getRestaurantMenu: ${e.message}');
      print('   Response: ${e.response?.data}');
      print('   Status Code: ${e.response?.statusCode}');
      throw _handleError(e);
    } catch (e, stackTrace) {
      print('❌ Unexpected error in getRestaurantMenu: $e');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<MenuItem> getMenuItem(String id) async {
    try {
      final response = await _dio.get('/api/menus/$id');
      return MenuItem.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<MenuItem> createMenuItem(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/menus', data: data);
      return MenuItem.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<MenuItem> updateMenuItem(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/api/menus/$id', data: data);
      return MenuItem.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteMenuItem(String id) async {
    try {
      await _dio.delete('/api/menus/$id');
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
