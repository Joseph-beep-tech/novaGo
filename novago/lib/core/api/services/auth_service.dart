import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/storage_service.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'customer',
    );
  }
}

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> register({
    required String email,
    required String name,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post('/api/auth/register', data: {
        'email': email,
        'name': name,
        'password': password,
        'role': role,
      });
      
      final user = User.fromJson(response.data['user']);
      final token = response.data['token'];
      
      // Save token and user data
      await StorageService.saveUserToken(token);
      await StorageService.saveUserData(user.toJson());
      
      return {'user': user, 'token': token};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      final user = User.fromJson(response.data['user']);
      final token = response.data['token'];
      
      // Save token and user data
      await StorageService.saveUserToken(token);
      await StorageService.saveUserData(user.toJson());
      
      return {'user': user, 'token': token};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _dio.get('/api/auth/me');
      return User.fromJson(response.data);
    } on DioException {
      return null;
    }
  }

  Future<void> logout() async {
    await StorageService.clearUserToken();
    await StorageService.clearUserData();
  }

  bool get isAuthenticated {
    return StorageService.getUserToken() != null;
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['message'] ?? 'An error occurred';
    }
    return error.message ?? 'Network error occurred';
  }
}

extension UserExtension on User {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    };
  }
}
