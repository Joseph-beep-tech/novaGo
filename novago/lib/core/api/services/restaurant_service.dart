import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/restaurant.dart';

class RestaurantService {
  final Dio _dio = ApiClient().dio;

  Future<List<Restaurant>> getRestaurants() async {
    try {
      print('Making API call to /api/restaurants...');
      final response = await _dio.get('/api/restaurants');
      print('API Response Status: ${response.statusCode}');
      print('API Response Data Type: ${response.data.runtimeType}');
      
      // Handle both array and object responses
      if (response.data == null) {
        print('Warning: API returned null data');
        return [];
      }
      
      // If response.data is a List, use it directly
      if (response.data is List) {
        final List<dynamic> data = response.data;
        print('Found ${data.length} restaurants in response');
        
        final List<Restaurant> restaurants = [];
        for (int i = 0; i < data.length; i++) {
          try {
            final restaurant = Restaurant.fromJson(data[i] as Map<String, dynamic>);
            restaurants.add(restaurant);
            print('Successfully parsed restaurant ${i + 1}: ${restaurant.name}');
          } catch (e, stackTrace) {
            print('Error parsing restaurant ${i + 1}: $e');
            print('Restaurant data: ${data[i]}');
            print('Stack trace: $stackTrace');
            // Continue parsing other restaurants even if one fails
          }
        }
        
        print('Successfully parsed ${restaurants.length} out of ${data.length} restaurants');
        return restaurants;
      }
      
      // If response.data is an object with a data property
      if (response.data is Map) {
        final Map<String, dynamic> responseMap = response.data as Map<String, dynamic>;
        print('Response is a Map with keys: ${responseMap.keys.toList()}');
        
        if (responseMap.containsKey('data') && responseMap['data'] is List) {
          final List<dynamic> data = responseMap['data'];
          print('Found ${data.length} restaurants in data property');
          return data.map((json) => Restaurant.fromJson(json as Map<String, dynamic>)).toList();
        }
        
        // If the response is a single restaurant object, wrap it in a list
        if (responseMap.containsKey('id')) {
          print('Response is a single restaurant object');
          return [Restaurant.fromJson(responseMap)];
        }
      }
      
      print('Warning: Unexpected response format: ${response.data}');
      return [];
    } on DioException catch (e) {
      print('DioException in getRestaurants: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status Code: ${e.response?.statusCode}');
      print('Error Type: ${e.type}');
      throw _handleError(e);
    } catch (e, stackTrace) {
      print('Unexpected error in getRestaurants: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Restaurant> getRestaurant(String id) async {
    try {
      final response = await _dio.get('/api/restaurants/$id');
      return Restaurant.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Restaurant> createRestaurant(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/restaurants', data: data);
      return Restaurant.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Restaurant> updateRestaurant(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/api/restaurants/$id', data: data);
      return Restaurant.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteRestaurant(String id) async {
    try {
      await _dio.delete('/api/restaurants/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final message = error.response?.data['message'] ?? 
                      error.response?.data['error'] ?? 
                      'An error occurred';
      
      // Log full error details in development
      print('API Error Details:');
      print('  Status: ${error.response?.statusCode}');
      print('  Message: $message');
      print('  Response Data: ${error.response?.data}');
      
      return message;
    }
    
    // Network/connection errors
    final errorMessage = error.message ?? 'Network error occurred';
    print('Network Error: $errorMessage');
    print('Error Type: ${error.type}');
    
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    }
    
    if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please make sure the backend is running.';
    }
    
    return errorMessage;
  }
}
