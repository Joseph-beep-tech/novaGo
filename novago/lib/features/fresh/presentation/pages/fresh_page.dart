import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FreshPage extends StatefulWidget {
  const FreshPage({super.key});

  @override
  State<FreshPage> createState() => _FreshPageState();
}

class _FreshPageState extends State<FreshPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  int _cartItemCount = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps, 'color': const Color(0xFF27AE60)},
    {'name': 'Organic', 'icon': Icons.eco, 'color': const Color(0xFF27AE60)},
    {'name': 'Farm Fresh', 'icon': Icons.agriculture, 'color': const Color(0xFF8BC34A)},
    {'name': 'Local', 'icon': Icons.location_on, 'color': const Color(0xFF4CAF50)},
    {'name': 'Seasonal', 'icon': Icons.wb_sunny, 'color': const Color(0xFFFFC107)},
    {'name': 'Premium', 'icon': Icons.diamond, 'color': const Color(0xFF9C27B0)},
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Organic Avocados',
      'price': 4.99,
      'originalPrice': 6.99,
      'image': '🥑',
      'category': 'Organic',
      'rating': 4.8,
      'reviews': 156,
      'inStock': true,
      'farm': 'Green Valley Farm',
      'distance': '2.3 km',
      'organic': true,
    },
    {
      'name': 'Farm Fresh Strawberries',
      'price': 3.49,
      'originalPrice': null,
      'image': '🍓',
      'category': 'Farm Fresh',
      'rating': 4.9,
      'reviews': 203,
      'inStock': true,
      'farm': 'Sunny Meadows',
      'distance': '5.1 km',
      'organic': false,
    },
    {
      'name': 'Local Honey',
      'price': 8.99,
      'originalPrice': null,
      'image': '🍯',
      'category': 'Local',
      'rating': 4.7,
      'reviews': 89,
      'inStock': true,
      'farm': 'Bee Happy Apiary',
      'distance': '1.8 km',
      'organic': true,
    },
    {
      'name': 'Seasonal Pumpkins',
      'price': 2.99,
      'originalPrice': null,
      'image': '🎃',
      'category': 'Seasonal',
      'rating': 4.6,
      'reviews': 67,
      'inStock': true,
      'farm': 'Harvest Hill',
      'distance': '3.7 km',
      'organic': false,
    },
    {
      'name': 'Premium Wagyu Beef',
      'price': 24.99,
      'originalPrice': 29.99,
      'image': '🥩',
      'category': 'Premium',
      'rating': 4.9,
      'reviews': 45,
      'inStock': true,
      'farm': 'Mountain View Ranch',
      'distance': '8.2 km',
      'organic': true,
    },
    {
      'name': 'Organic Kale',
      'price': 2.49,
      'originalPrice': null,
      'image': '🥬',
      'category': 'Organic',
      'rating': 4.5,
      'reviews': 134,
      'inStock': true,
      'farm': 'Green Thumb Gardens',
      'distance': '4.5 km',
      'organic': true,
    },
    {
      'name': 'Fresh Herbs Mix',
      'price': 1.99,
      'originalPrice': null,
      'image': '🌿',
      'category': 'Local',
      'rating': 4.4,
      'reviews': 78,
      'inStock': true,
      'farm': 'Herb Haven',
      'distance': '2.1 km',
      'organic': true,
    },
    {
      'name': 'Artisan Cheese',
      'price': 12.99,
      'originalPrice': null,
      'image': '🧀',
      'category': 'Premium',
      'rating': 4.8,
      'reviews': 92,
      'inStock': true,
      'farm': 'Dairy Dreams',
      'distance': '6.3 km',
      'organic': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategory == 'All') {
      return _products;
    }
    return _products.where((product) => product['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Fresh',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () => _showCart(context),
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Hero Banner
          Container(
            height: 120,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Farm to Table',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Fresh, organic, and locally sourced',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            r'Free delivery on orders over $25',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: 48,
                  ),
                ],
              ),
            ),
          ),
          
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search fresh products...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: () => _showFilters(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          
          // Categories
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['name'];
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['name'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? category['color'] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? category['color'] : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category['icon'],
                            color: isSelected ? Colors.white : category['color'],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            category['name'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : category['color'],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Products Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return _buildProductCard(product);
              },
            ),
          ),
        ],
      ),
    );

  Widget _buildProductCard(Map<String, dynamic> product) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with Badges
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: Text(
                      product['image'],
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                if (product['organic'])
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ORGANIC',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (product['originalPrice'] != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${((product['originalPrice'] - product['price']) / product['originalPrice'] * 100).round()}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Farm and Distance
                  Row(
                    children: [
                      Icon(Icons.agriculture, color: Colors.grey[600], size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product['farm'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.location_on, color: Colors.grey[600], size: 12),
                      const SizedBox(width: 2),
                      Text(
                        product['distance'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '${product['rating']} (${product['reviews']})',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Price and Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${product['price'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF27AE60),
                              fontSize: 16,
                            ),
                          ),
                          if (product['originalPrice'] != null)
                            Text(
                              '\$${product['originalPrice'].toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _cartItemCount++;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product['name']} added to cart'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: const Color(0xFF27AE60),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF27AE60),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  void _showCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fresh Cart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _cartItemCount == 0
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.eco, size: 64, color: Color(0xFF27AE60)),
                          SizedBox(height: 16),
                          Text(
                            'Your fresh cart is empty',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add some fresh, organic products!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _cartItemCount,
                      itemBuilder: (context, index) => ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF27AE60),
                          child: Icon(Icons.eco, color: Colors.white),
                        ),
                        title: Text('Fresh Item ${index + 1}'),
                        subtitle: const Text(r'$4.99'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() {
                              _cartItemCount--;
                            });
                            Navigator.pop(context);
                            _showCart(context);
                          },
                        ),
                      ),
                    ),
            ),
            if (_cartItemCount > 0)
              Container(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Fresh Filters',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const ListTile(
              title: Text('Organic Only'),
              subtitle: Text('Show organic products'),
              trailing: Switch(value: true, onChanged: null),
            ),
            const ListTile(
              title: Text('Local Farms'),
              subtitle: Text('Within 10 km radius'),
              trailing: Switch(value: true, onChanged: null),
            ),
            const ListTile(
              title: Text('Price Range'),
              subtitle: Text(r'$0 - $50'),
            ),
            const ListTile(
              title: Text('Farm Rating'),
              subtitle: Text('4+ stars'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
