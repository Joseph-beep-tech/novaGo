import '../config/app_config.dart';

class Restaurant {
  final String id;
  final String name;
  final String description;
  final String cuisine;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final double deliveryFee;
  final double minOrder;
  final String imageUrl;
  final String address;
  final String phone;
  final String hours;
  final List<String> features;
  final bool isOpen;
  final bool isPromoted;
  final String? discount;
  final String? currencyCode;
  final String? currencySymbol;

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

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.cuisine,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.minOrder,
    required this.imageUrl,
    required this.address,
    required this.phone,
    required this.hours,
    required this.features,
    required this.isOpen,
    this.isPromoted = false,
    this.discount,
    this.currencyCode,
    this.currencySymbol,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    try {
      // Parse delivery time from minutes to string format
      final min = json['deliveryTimeMinutesMin'] ?? 15;
      final max = json['deliveryTimeMinutesMax'] ?? 25;
      
      // Helper to safely parse numbers
      double parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }
      
      int parseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }
      
      return Restaurant(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        cuisine: json['cuisine']?.toString() ?? '',
        rating: parseDouble(json['rating']),
        reviewCount: parseInt(json['reviewCount']),
        deliveryTime: '$min-$max min',
        deliveryFee: parseDouble(json['deliveryFee']),
        minOrder: parseDouble(json['minOrder']),
        imageUrl: json['imageUrl']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        hours: json['hours']?.toString() ?? '',
        features: json['features'] is List 
            ? List<String>.from(json['features'].map((e) => e.toString()))
            : <String>[],
        isOpen: json['isOpen'] is bool ? json['isOpen'] : (json['isOpen']?.toString().toLowerCase() == 'true'),
        isPromoted: json['isPromoted'] is bool ? json['isPromoted'] : (json['isPromoted']?.toString().toLowerCase() == 'true'),
        discount: json['discount']?.toString(),
        currencyCode: json['currencyCode']?.toString(),
        currencySymbol: json['currencySymbol']?.toString(),
      );
    } catch (e, stackTrace) {
      print('Error parsing Restaurant from JSON: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cuisine': cuisine,
      'rating': rating,
      'reviewCount': reviewCount,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'minOrder': minOrder,
      'imageUrl': imageUrl,
      'address': address,
      'phone': phone,
      'hours': hours,
      'features': features,
      'isOpen': isOpen,
      'isPromoted': isPromoted,
      'discount': discount,
    };
  }
}
