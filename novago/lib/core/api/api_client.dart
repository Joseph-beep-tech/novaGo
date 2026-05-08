import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../services/storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  Dio? _dio;
  bool _initialized = false;

  Dio get dio {
    if (!_initialized || _dio == null) {
      throw Exception('ApiClient not initialized. Call ApiClient().init() first.');
    }
    return _dio!;
  }

  void init() {
    if (_initialized && _dio != null) {
      return; // Already initialized
    }
    
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add request interceptor for auth token
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = StorageService.getUserToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle common errors
          if (error.response?.statusCode == 401) {
            // Unauthorized - clear token
            StorageService.clearUserToken();
          }
          return handler.next(error);
        },
      ),
    );

    // Add logging interceptor for development
    if (AppConfig.isDevelopment) {
      _dio!.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }
    
    _initialized = true;
  }
}
