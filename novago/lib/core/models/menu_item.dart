import '../config/app_config.dart';

class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String? description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final bool? isVegetarian;
  final double? rating;
  final int? prepTimeMinutes;
  
  // Get full image URL - handles both relative paths and absolute URLs
  String get fullImageUrl {
    if (imageUrl.isEmpty) {
      return 'https://via.placeholder.com/400x200';
    }
    
    final apiBaseUrl = AppConfig.apiBaseUrl;
    
    // If it's already a full URL, check if it's localhost and replace with correct base URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // If it's a localhost URL (won't work on Android emulator), replace with correct base URL
      if (imageUrl.contains('localhost') || imageUrl.contains('127.0.0.1')) {
        // Extract the path from the localhost URL
        final uri = Uri.parse(imageUrl);
        return '$apiBaseUrl${uri.path}';
      }
      // For external URLs (like Unsplash), return as-is
      return imageUrl;
    }
    
    // If relative path, construct full URL using API base URL
    // Ensure path starts with /
    final path = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
    return '$apiBaseUrl$path';
  }

  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isAvailable = true,
    this.isVegetarian,
    this.rating,
    this.prepTimeMinutes,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    try {
      // Helper to safely parse numbers
      double? parseDouble(dynamic value) {
        if (value == null) return null;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value);
        return null;
      }

      int? parseInt(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) return int.tryParse(value);
        return null;
      }

      return MenuItem(
        id: json['id']?.toString() ?? '',
        restaurantId: json['restaurantId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        price: parseDouble(json['price']) ?? 0.0,
        imageUrl: json['imageUrl']?.toString() ?? '',
        category: json['category']?.toString() ?? 'Popular',
        isAvailable: json['isAvailable'] is bool ? json['isAvailable'] : (json['isAvailable']?.toString().toLowerCase() == 'true'),
        isVegetarian: json['isVegetarian'] is bool ? json['isVegetarian'] : (json['isVegetarian']?.toString().toLowerCase() == 'true'),
        rating: parseDouble(json['rating']),
        prepTimeMinutes: parseInt(json['prepTimeMinutes']),
      );
    } catch (e, stackTrace) {
      print('Error parsing MenuItem from JSON: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'isVegetarian': isVegetarian,
      'rating': rating,
      'prepTimeMinutes': prepTimeMinutes,
    };
  }
}
