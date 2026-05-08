// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Token Management
  static Future<void> saveUserToken(String token) async {
    await _prefs?.setString('user_token', token);
  }

  static String? getUserToken() => _prefs?.getString('user_token');

  static Future<void> clearUserToken() async {
    await _prefs?.remove('user_token');
  }

  // User Data Management
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs?.setString('user_data', jsonEncode(userData));
  }

  static Map<String, dynamic>? getUserData() {
    final userDataString = _prefs?.getString('user_data');
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> clearUserData() async {
    await _prefs?.remove('user_data');
  }

  // Settings Management
  static Future<void> saveSetting(String key, value) async {
    if (value is String) {
      await _prefs?.setString(key, value);
    } else if (value is int) {
      await _prefs?.setInt(key, value);
    } else if (value is double) {
      await _prefs?.setDouble(key, value);
    } else if (value is bool) {
      await _prefs?.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs?.setStringList(key, value);
    }
  }

  static T? getSetting<T>(String key) => _prefs?.get(key) as T?;

  // Cart Management
  static Future<void> saveCartData(List<Map<String, dynamic>> cartItems) async {
    await _prefs?.setString('cart_data', jsonEncode(cartItems));
  }

  static List<Map<String, dynamic>> getCartData() {
    final cartDataString = _prefs?.getString('cart_data');
    if (cartDataString != null) {
      final List<dynamic> cartList = jsonDecode(cartDataString);
      return cartList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> clearCart() async {
    await _prefs?.remove('cart_data');
  }

  // Cache Management
  static Future<void> cacheData(String key, Map<String, dynamic> data) async {
    await _prefs?.setString('cache_$key', jsonEncode(data));
  }

  static Map<String, dynamic>? getCachedData(String key) {
    final cachedDataString = _prefs?.getString('cache_$key');
    if (cachedDataString != null) {
      return jsonDecode(cachedDataString) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> clearCache() async {
    final keys = _prefs?.getKeys().where((key) => key.startsWith('cache_')).toList();
    if (keys != null) {
      for (final key in keys) {
        await _prefs?.remove(key);
      }
    }
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
